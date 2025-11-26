#!/bin/bash
# Development Fund Termination Checker
# Verifies that the 2% dev fund allocation stops at block 1,051,200

set -e

NODE="localhost:29081"
DEV_FUND_END_HEIGHT=1051200
OUTPUT_FILE=""

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
Dev Fund Checker

Usage: $0 [options]

Options:
  --node HOST:PORT   RPC endpoint (default: localhost:29081)
  --output FILE      Save JSON results
  --before N         Height before termination to inspect (default: 1051195)
  --after N          Height after termination to inspect (default: 1051205)
  --help             Show this help
EOF
}

# Defaults
HEIGHT_BEFORE=$((DEV_FUND_END_HEIGHT - 5))
HEIGHT_AFTER=$((DEV_FUND_END_HEIGHT + 5))

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --node)
            NODE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --before)
            HEIGHT_BEFORE="$2"
            shift 2
            ;;
        --after)
            HEIGHT_AFTER="$2"
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
print_info "Development Fund Checker"
print_info "Node: $NODE"
print_info "Dev fund end height: $DEV_FUND_END_HEIGHT"
print_info "Inspecting heights: $HEIGHT_BEFORE and $HEIGHT_AFTER"
print_info "========================================"

rpc_call() {
    local method=$1
    local params=${2:-"{}"}
    curl -s "http://$NODE/json_rpc" \
        -H 'Content-Type: application/json' \
        -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"$method\",\"params\":$params}" 2>/dev/null
}

get_block() {
    local height=$1
    rpc_call "get_block" "{\"height\":$height}"
}

parse_dev_fund_output() {
    local block_json=$1
    local outputs=$(echo "$block_json" | jq -r '.result.block_json' 2>/dev/null)
    if [ -z "$outputs" ]; then
        echo "[]"
        return
    fi
    echo "$outputs" | jq -r '.miner_tx.vout'
}

inspect_block() {
    local height=$1
    local block=$(get_block "$height")
    if [ -z "$block" ]; then
        print_error "Failed to get block $height"
        echo "{}"
        return 1
    fi
    
    local block_json=$(echo "$block" | jq -r '.result.block_json' 2>/dev/null)
    if [ -z "$block_json" ]; then
        print_error "No block_json in response"
        echo "{}"
        return 1
    fi
    
    local tx=$(echo "$block_json" | jq '.miner_tx')
    local outputs=$(echo "$tx" | jq '.vout')
    local output_count=$(echo "$outputs" | jq 'length')
    
    # Dev fund output typically second output (index 1)
    local dev_output=$(echo "$outputs" | jq '.[1] // empty')
    local reward_output=$(echo "$outputs" | jq '.[0] // empty')
    
    local result=$(cat << EOF
{
  "height": $height,
  "timestamp": $(echo "$tx" | jq '.unlock_time // 0'),
  "output_count": $output_count,
  "reward_amount": $(echo "$reward_output" | jq '.amount // 0'),
  "dev_fund_amount": $(echo "$dev_output" | jq '.amount // 0'),
  "has_dev_fund": $( [ -n "$dev_output" ] && echo "true" || echo "false" )
}
EOF
)
    echo "$result"
}

before_data=$(inspect_block "$HEIGHT_BEFORE")
after_data=$(inspect_block "$HEIGHT_AFTER")

print_info "Block $HEIGHT_BEFORE: $(echo "$before_data" | jq '.reward_amount') reward, dev fund: $(echo "$before_data" | jq '.dev_fund_amount')"
print_info "Block $HEIGHT_AFTER: $(echo "$after_data" | jq '.reward_amount') reward, dev fund: $(echo "$after_data" | jq '.dev_fund_amount')"

has_dev_before=$(echo "$before_data" | jq -r '.has_dev_fund')
has_dev_after=$(echo "$after_data" | jq -r '.has_dev_fund')

if [ "$has_dev_before" = "true" ] && [ "$has_dev_after" = "false" ]; then
    print_info "✅ PASS: Dev fund allocation ends at block $DEV_FUND_END_HEIGHT"
else
    print_warning "⚠️  WARNING: Dev fund termination mismatch"
fi

if [ -n "$OUTPUT_FILE" ]; then
    cat > "$OUTPUT_FILE" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "node": "$NODE",
  "dev_fund_end_height": $DEV_FUND_END_HEIGHT,
  "before": $before_data,
  "after": $after_data,
  "passed": $( [ "$has_dev_before" = "true" ] && [ "$has_dev_after" = "false" ] && echo "true" || echo "false" )
}
EOF
    print_info "Results saved to $OUTPUT_FILE"
fi
