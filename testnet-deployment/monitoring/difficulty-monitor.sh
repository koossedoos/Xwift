#!/bin/bash
# Difficulty Adjustment Monitor for Xwift Testnet
# Tracks difficulty changes during hashrate variance

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../reports"
mkdir -p "$OUTPUT_DIR"

NODE="localhost:29081"
DURATION=1000
DELAY=35
OUTPUT_FILE="$OUTPUT_DIR/difficulty-$(date +%Y%m%d_%H%M%S).csv"

print_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

usage() {
    cat << EOF
Difficulty Adjustment Monitor

Tracks difficulty changes over time to validate smooth adjustments.

Usage: $0 [options]

Options:
  --node HOST:PORT    RPC endpoint (default: localhost:29081)
  --duration N        Number of blocks to monitor (default: 1000)
  --delay SECONDS     Delay between polls (default: 35)
  --output FILE       Output CSV file
  --help              Show this help

Output CSV columns:
  timestamp,height,difficulty,block_time,hashrate,cumulative_time
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --node)
            NODE="$2"
            shift 2
            ;;
        --duration)
            DURATION="$2"
            shift 2
            ;;
        --delay)
            DELAY="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

print_info "========================================"
print_info "Difficulty Adjustment Monitor"
print_info "Node: $NODE"
print_info "Duration: $DURATION blocks"
print_info "Output: $OUTPUT_FILE"
print_info "========================================"

# RPC call function
rpc_call() {
    local method=$1
    local params=${2:-"{}"}
    
    curl -s "http://$NODE/json_rpc" \
        -H 'Content-Type: application/json' \
        -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"$method\",\"params\":$params}" 2>/dev/null
}

# Get current height
get_height() {
    rpc_call "get_block_count" "{}" | jq -r '.result.count // 0'
}

# Get block header by height
get_block_header() {
    local height=$1
    rpc_call "get_block_header_by_height" "{\"height\":$height}" | jq -r '.result.block_header // {}'
}

# Initialize CSV
echo "timestamp,height,difficulty,block_time,hashrate,cumulative_time" > "$OUTPUT_FILE"

start_height=$(get_height)
prev_timestamp=0
cumulative_time=0

print_info "Starting from height: $start_height"
print_info "Will monitor until height: $((start_height + DURATION))"

current_count=0

while [ $current_count -lt $DURATION ]; do
    current_height=$(get_height)
    
    if [ $current_height -le $start_height ]; then
        sleep "$DELAY"
        continue
    fi
    
    # Get block header
    header=$(get_block_header "$current_height")
    
    if [ -z "$header" ] || [ "$header" = "{}" ]; then
        print_warning "Failed to get block header for height $current_height"
        sleep "$DELAY"
        continue
    fi
    
    timestamp=$(echo "$header" | jq -r '.timestamp // 0')
    difficulty=$(echo "$header" | jq -r '.difficulty // 0')
    
    # Calculate block time
    if [ $prev_timestamp -gt 0 ]; then
        block_time=$((timestamp - prev_timestamp))
    else
        block_time=30
    fi
    
    # Calculate hashrate
    hashrate=$(echo "scale=2; $difficulty / 30" | bc)
    
    cumulative_time=$((cumulative_time + block_time))
    
    # Write to CSV
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),$current_height,$difficulty,$block_time,$hashrate,$cumulative_time" >> "$OUTPUT_FILE"
    
    print_info "Height: $current_height | Difficulty: $difficulty | Block time: ${block_time}s | Hashrate: $hashrate H/s"
    
    prev_timestamp=$timestamp
    start_height=$current_height
    current_count=$((current_count + 1))
    
    # Report progress
    if [ $((current_count % 50)) -eq 0 ]; then
        avg_time=$(echo "scale=2; $cumulative_time / $current_count" | bc)
        print_info "Progress: $current_count/$DURATION | Avg block time: ${avg_time}s"
    fi
    
    sleep "$DELAY"
done

# Calculate statistics
avg_block_time=$(echo "scale=2; $cumulative_time / $current_count" | bc)
avg_difficulty=$(awk -F',' 'NR>1 {sum+=$3; count++} END {print sum/count}' "$OUTPUT_FILE")
avg_hashrate=$(echo "scale=2; $avg_difficulty / 30" | bc)

print_info "========================================"
print_info "Monitoring Complete!"
print_info "Blocks monitored: $current_count"
print_info "Average block time: ${avg_block_time}s (target: 30s)"
print_info "Average difficulty: $avg_difficulty"
print_info "Average hashrate: $avg_hashrate H/s"
print_info "Output: $OUTPUT_FILE"
print_info "========================================"

# Assess stability
deviation=$(echo "scale=2; (($avg_block_time - 30) / 30) * 100" | bc | sed 's/-//')
if (( $(echo "$deviation < 10" | bc -l) )); then
    print_info "✅ PASS: Block time within ±10% of target"
else
    print_warning "⚠️  WARNING: Block time deviation: ${deviation}%"
fi
