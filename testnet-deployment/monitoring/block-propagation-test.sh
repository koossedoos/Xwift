#!/bin/bash
# Block Propagation Test for Xwift Testnet
# Measures propagation delay between seed nodes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../reports"
mkdir -p "$OUTPUT_DIR"

# Configure your seed nodes (RPC endpoints)
SEED_NODES=(
    "seed1=localhost:29081"
    # "seed2=seed2.xwift-testnet.network:29081"
    # "seed3=seed3.xwift-testnet.network:29081"
)

SAMPLE_BLOCKS=100
POLL_INTERVAL=5
OUTPUT_FILE="$OUTPUT_DIR/block-propagation-$(date +%Y%m%d_%H%M%S).csv"

print_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

usage() {
    cat << EOF
Block Propagation Test

Measures propagation delay between seed nodes.

Usage: $0 [options]

Options:
  --samples N     Number of new blocks to sample (default: 100)
  --interval SEC  Poll interval (default: 5)
  --output FILE   Output CSV file
  --help          Show this help

CSV Columns:
  block_height,block_hash,node,timestamp,delay_ms
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --samples)
            SAMPLE_BLOCKS="$2"
            shift 2
            ;;
        --interval)
            POLL_INTERVAL="$2"
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
print_info "Block Propagation Test"
print_info "Samples: $SAMPLE_BLOCKS"
print_info "Poll interval: ${POLL_INTERVAL}s"
print_info "Output: $OUTPUT_FILE"
print_info "========================================"

# Function to query node for last block header
get_last_block() {
    local endpoint=$1
    curl -s "http://${endpoint}/json_rpc" \
        -H 'Content-Type: application/json' \
        -d '{"jsonrpc":"2.0","id":"0","method":"get_last_block_header"}' 2>/dev/null
}

# Initialize CSV
echo "block_height,block_hash,node,timestamp,delay_ms" > "$OUTPUT_FILE"

# Tracking structures
declare -A last_seen_height
for node in "${SEED_NODES[@]}"; do
    name="${node%%=*}"
    last_seen_height[$name]=0
end

samples_collected=0
reference_times=()

print_info "Waiting for new blocks..."
while [ $samples_collected -lt $SAMPLE_BLOCKS ]; do
    for entry in "${SEED_NODES[@]}"; do
        name="${entry%%=*}"
        endpoint="${entry#*=}"
        
        response=$(get_last_block "$endpoint")
        height=$(echo "$response" | jq -r '.result.block_header.height // 0')
        block_hash=$(echo "$response" | jq -r '.result.block_header.hash // ""')
        timestamp=$(date -u +%s%3N)
        
        if [ -z "$block_hash" ]; then
            print_warning "Failed to fetch block info from $name"
            continue
        fi
        
        if [ ${last_seen_height[$name]} -lt $height ]; then
            # New block for this node
            last_seen_height[$name]=$height
            key="${height}_${block_hash}"
            
            if [ -z "${reference_times[$key]+x}" ]; then
                reference_times[$key]=${timestamp}
                delay=0
                print_info "New block detected on $name at height $height"
            else
                ref=${reference_times[$key]}
                delay=$((timestamp - ref))
                print_info "Block $height reached $name after ${delay}ms"
            fi
            
            echo "$height,$block_hash,$name,$timestamp,$delay" >> "$OUTPUT_FILE"
            
            # Count sample when all nodes have seen it or after first detection
            # We'll consider first detection as new sample
            if [ $delay -eq 0 ]; then
                samples_collected=$((samples_collected + 1))
                if [ $samples_collected -ge $SAMPLE_BLOCKS ]; then
                    break 2
                fi
            fi
        fi
    done
    
    sleep "$POLL_INTERVAL"
done

print_info "========================================"
print_info "Block propagation test complete"
print_info "Samples collected: $samples_collected"

# Calculate summary stats
avg_delay=$(awk -F',' 'NR>1 {if ($5>0) {sum+=$5; count++}} END {if (count>0) printf "%.2f", sum/count; else print 0}' "$OUTPUT_FILE")
max_delay=$(awk -F',' 'NR>1 {if ($5>max) max=$5} END {print max}' "$OUTPUT_FILE")

print_info "Average propagation delay: ${avg_delay}ms"
print_info "Maximum propagation delay: ${max_delay}ms"

if (( $(echo "$avg_delay < 5000" | bc -l) )); then
    print_info "✅ PASS: Average propagation under 5 seconds"
else
    print_warning "⚠️  WARNING: Average propagation exceeds 5 seconds"
fi

print_info "Results saved to: $OUTPUT_FILE"
print_info "========================================"
