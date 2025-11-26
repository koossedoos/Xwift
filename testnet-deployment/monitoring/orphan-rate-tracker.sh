#!/bin/bash
# Orphan Rate Tracker for Xwift Testnet
# Measures orphan/alt-chain occurrences over a sample of blocks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../reports"
mkdir -p "$OUTPUT_DIR"

NODE="localhost:29081"
SAMPLE_BLOCKS=1000
DELAY=30
LOG_FILE="$OUTPUT_DIR/orphan-rate-$(date +%Y%m%d_%H%M%S).log"

print_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

usage() {
    cat << EOF
Orphan Rate Tracker

Usage: $0 [options]

Options:
  --node HOST:PORT    RPC endpoint (default: localhost:29081)
  --sample N          Number of blocks to sample (default: 1000)
  --delay SECONDS     Delay between checks (default: 30)
  --log FILE          Log file path (default: reports/orphan-rate-<timestamp>.log)
  --help              Show this help message
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --node)
            NODE="$2"
            shift 2
            ;;
        --sample)
            SAMPLE_BLOCKS="$2"
            shift 2
            ;;
        --delay)
            DELAY="$2"
            shift 2
            ;;
        --log)
            LOG_FILE="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

print_info "========================================"
print_info "Xwift Testnet Orphan Rate Tracker"
print_info "Node: $NODE"
print_info "Sample blocks: $SAMPLE_BLOCKS"
print_info "Delay: $DELAY seconds"
print_info "Log: $LOG_FILE"
print_info "========================================"

# Function to query JSON-RPC
rpc_call() {
    local method=$1
    local params=$2
    
    [ -z "$params" ] && params="{}"
    
    curl -s "http://$NODE/json_rpc" \
        -H 'Content-Type: application/json' \
        -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"$method\",\"params\":$params}" 2>/dev/null
}

# Initialize counters
orphans=0
valid=0
start_height=$(rpc_call "get_block_count" "{}" | jq -r '.result.count // 0')
start_height=$((start_height > SAMPLE_BLOCKS ? start_height - SAMPLE_BLOCKS : 0))
next_height=$start_height

print_info "Starting from height: $start_height" | tee "$LOG_FILE"

echo "timestamp,height,type,details" >> "$LOG_FILE"

# Main loop
while [ $((valid + orphans)) -lt $SAMPLE_BLOCKS ]; do
    current_height=$(rpc_call "get_block_count" "{}" | jq -r '.result.count // 0')
    
    if [ $current_height -le $next_height ]; then
        sleep "$DELAY"
        continue
    fi
    
    # Check for alt chains
    alt_info=$(rpc_call "get_alternate_chains" "{}")
    
    if echo "$alt_info" | jq -e '.result.chains | length > 0' >/dev/null 2>&1; then
        chain_data=$(echo "$alt_info" | jq -c '.result.chains[]')
        while IFS= read -r chain; do
            alt_height=$(echo "$chain" | jq -r '.height // 0')
            alt_length=$(echo "$chain" | jq -r '.length // 0')
            if [ $alt_height -ge $next_height ]; then
                ((orphans++))
                print_warning "Orphan detected at height $alt_height (length: $alt_length)"
                echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),$alt_height,orphan,length=$alt_length" >> "$LOG_FILE"
            fi
        done <<< "$chain_data"
    else
        ((valid++))
        print_info "Block $next_height valid"
        echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),$next_height,valid,-" >> "$LOG_FILE"
    fi
    
    next_height=$((next_height + 1))
    
    # Report progress every 50 blocks
    if [ $(( (valid + orphans) % 50 )) -eq 0 ]; then
        rate=$(echo "scale=2; ($orphans * 100) / ($valid + $orphans)" | bc)
        print_info "Progress: $((valid + orphans))/$SAMPLE_BLOCKS blocks | Orphans: $orphans | Rate: $rate%"
    fi

done

final_rate=$(echo "scale=4; ($orphans * 100) / ($valid + $orphans)" | bc)

print_info "========================================"
print_info "Sample complete!"
print_info "Total blocks: $((valid + orphans))"
print_info "Valid: $valid"
print_info "Orphans: $orphans"
print_info "Orphan rate: $final_rate%"
print_info "Log file: $LOG_FILE"
print_info "========================================"

if (( $(echo "$final_rate < 5.0" | bc -l) )); then
    print_info "✅ PASS: Orphan rate below 5% target"
else
    print_warning "⚠️  WARNING: Orphan rate above 5% target"
fi
