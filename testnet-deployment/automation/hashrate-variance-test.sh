#!/bin/bash
# Hashrate Variance Test for Xwift Testnet
# Simulates 50-500% hashrate swings to test difficulty adjustment

set -e

NODE="localhost:29081"
MINER_ADDRESS=""
BASE_THREADS=2
SPIKE_THREADS=8
SURGE_THREADS=16
DURATION_BLOCKS=500
LOG_FILE="$(dirname "$0")/../reports/hashrate-variance-$(date +%Y%m%d_%H%M%S).log"

print_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

usage() {
    cat << EOF
Hashrate Variance Test

Usage: $0 [options]

Options:
  --node HOST:PORT      RPC endpoint (default: localhost:29081)
  --address XWIFT_ADDR  Testnet address to mine to (required)
  --base-threads N      Base mining threads (default: 2)
  --spike-threads N     Spike threads (default: 8)
  --surge-threads N     Surge threads (default: 16)
  --duration BLOCKS     Blocks per phase (default: 500)
  --help                Show this help
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --node)
            NODE="$2"
            shift 2
            ;;
        --address)
            MINER_ADDRESS="$2"
            shift 2
            ;;
        --base-threads)
            BASE_THREADS="$2"
            shift 2
            ;;
        --spike-threads)
            SPIKE_THREADS="$2"
            shift 2
            ;;
        --surge-threads)
            SURGE_THREADS="$2"
            shift 2
            ;;
        --duration)
            DURATION_BLOCKS="$2"
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

if [ -z "$MINER_ADDRESS" ]; then
    print_warning "Testnet mining address required"
    usage
    exit 1
fi

rpc_call() {
    local method=$1
    local params=$2
    curl -s "http://$NODE/json_rpc" \
        -H 'Content-Type: application/json' \
        -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"$method\",\"params\":$params}" 2>/dev/null
}

start_mining() {
    local threads=$1
    print_info "Starting mining with $threads threads"
    rpc_call "start_mining" "{\"miner_address\":\"$MINER_ADDRESS\",\"threads_count\":$threads,\"background\":false,\"ignore_battery\":true}" >/dev/null && sleep 5
}

stop_mining() {
    print_info "Stopping mining"
    rpc_call "stop_mining" "{}" >/dev/null && sleep 5
}

wait_blocks() {
    local blocks=$1
    local start_height=$(rpc_call "get_block_count" "{}" | jq -r '.result.count // 0')
    local target_height=$((start_height + blocks))
    print_info "Waiting for $blocks blocks (target height: $target_height)"
    
    while true; do
        local current_height=$(rpc_call "get_block_count" "{}" | jq -r '.result.count // 0')
        if [ "$current_height" -ge "$target_height" ]; then
            break
        fi
        sleep 30
    done
    
    print_info "Reached height: $target_height"
}

log_difficulty() {
    local phase="$1"
    local info=$(curl -s "http://$NODE/get_info")
    local height=$(echo "$info" | jq -r '.height // 0')
    local difficulty=$(echo "$info" | jq -r '.difficulty // 0')
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),$phase,$height,$difficulty" >> "$LOG_FILE"
    print_info "[$phase] Height: $height | Difficulty: $difficulty"
}

print_info "========================================"
print_info "Hashrate Variance Test"
print_info "Node: $NODE"
print_info "Address: $MINER_ADDRESS"
print_info "Log: $LOG_FILE"
print_info "========================================"

# Phase 1: Baseline
print_info "Phase 1: Baseline mining"
start_mining "$BASE_THREADS"
wait_blocks "$DURATION_BLOCKS"
log_difficulty "baseline"
stop_mining

# Phase 2: 50% drop (stop mining)
print_info "Phase 2: Hashrate drop"
wait_blocks "$DURATION_BLOCKS"
log_difficulty "drop"

# Phase 3: 200% spike
print_info "Phase 3: Hashrate spike"
start_mining "$SPIKE_THREADS"
wait_blocks "$DURATION_BLOCKS"
log_difficulty "spike"
stop_mining

# Phase 4: 500% surge
print_info "Phase 4: Hashrate surge"
start_mining "$SURGE_THREADS"
wait_blocks "$DURATION_BLOCKS"
log_difficulty "surge"
stop_mining

# Phase 5: Return to baseline
print_info "Phase 5: Return to baseline"
start_mining "$BASE_THREADS"
wait_blocks "$DURATION_BLOCKS"
log_difficulty "recovery"
stop_mining

print_info "========================================"
print_info "Hashrate variance test complete"
print_info "Logs saved to $LOG_FILE"
print_info "========================================"
