#!/bin/bash
# Real-time monitoring dashboard for Xwift testnet nodes
# Usage: ./monitoring/monitor-nodes.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTNET_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Node definitions
NODES=(
    "Seed1:29081:xwift-seed-1"
    "Seed2:29083:xwift-seed-2"
    "Seed3:29085:xwift-seed-3"
    "Mining:29087:xwift-mining"
)

function format_number() {
    printf "%'d" "$1" 2>/dev/null || echo "$1"
}

function get_node_info() {
    local port=$1
    curl -s --max-time 5 http://127.0.0.1:${port}/get_info || echo "{}"
}

function json_get_many() {
    local json="$1"; shift
    python3 - "$@" <<'PY' <<< "$json"
import json, sys
raw = sys.stdin.read() or '{}'
try:
    data = json.loads(raw)
except json.JSONDecodeError:
    data = {}
fields = sys.argv[1:]
values = []
for field in fields:
    value = data
    for part in field.split('.'):
        if isinstance(value, dict) and part in value:
            value = value[part]
        else:
            value = ''
            break
    if isinstance(value, bool):
        value = int(value)
    elif isinstance(value, (list, dict)):
        value = ''
    elif value is None:
        value = ''
    values.append(str(value))
print(" ".join(values))
PY
}

function display_dashboard() {
    clear
    
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║           Xwift Local Testnet - Real-time Monitor                    ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Time: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""
    
    # Header
    printf "${BOLD}%-10s %-12s %-12s %-10s %-10s %-8s %-8s${NC}\n" \
        "NODE" "HEIGHT" "TARGET" "DIFF" "HASHRATE" "TX_POOL" "PEERS"
    printf "${BOLD}%-10s %-12s %-12s %-10s %-10s %-8s %-8s${NC}\n" \
        "----------" "------------" "------------" "----------" "----------" "--------" "--------"
    
    # Node stats
    for node in "${NODES[@]}"; do
        IFS=':' read -r NAME PORT CONTAINER <<< "$node"
        
        # Check if container is running
        if ! docker ps | grep -q "$CONTAINER"; then
            printf "%-10s ${RED}%-12s${NC} %-12s %-10s %-10s %-8s %-8s\n" \
                "$NAME" "STOPPED" "-" "-" "-" "-" "-"
            continue
        fi
        
        INFO=$(get_node_info "$PORT")
        read HEIGHT TARGET DIFF TX_POOL PEERS <<< "$(json_get_many "$INFO" height target_height difficulty tx_pool_size outgoing_connections_count)"
        
        if [ -z "$HEIGHT" ]; then
            printf "%-10s ${YELLOW}%-12s${NC} %-12s %-10s %-10s %-8s %-8s\n" \
                "$NAME" "STARTING" "-" "-" "-" "-" "-"
            continue
        fi
        
        HEIGHT=${HEIGHT:-0}
        TARGET=${TARGET:-0}
        DIFF=${DIFF:-0}
        TX_POOL=${TX_POOL:-0}
        PEERS=${PEERS:-0}
        
        # Calculate hashrate (difficulty / 30 seconds)
        HASHRATE=$(echo "scale=2; ${DIFF:-0} / 30" | bc -l 2>/dev/null || echo "0")
        
        # Sync status color
        if [ "$HEIGHT" = "$TARGET" ]; then
            HEIGHT_COLOR="${GREEN}"
        else
            HEIGHT_COLOR="${YELLOW}"
        fi
        
        printf "%-10s ${HEIGHT_COLOR}%-12s${NC} %-12s %-10s %-10s %-8s %-8s\n" \
            "$NAME" "$(format_number ${HEIGHT:-0})" "$(format_number ${TARGET:-0})" \
            "$(format_number ${DIFF:-0})" "${HASHRATE} H/s" "$TX_POOL" "$PEERS"
    done
    
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}BLOCKCHAIN METRICS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    
    # Get detailed info from mining node
    MINING_INFO=$(get_node_info "29087")
    read M_HEIGHT BLOCK_SIZE BLOCK_WEIGHT NETWORK_HASH <<< "$(json_get_many "$MINING_INFO" height block_size_limit block_weight_limit difficulty)"
    
    if [ -n "$M_HEIGHT" ]; then
        NETWORK_HASHRATE=$(echo "scale=2; ${NETWORK_HASH:-0} / 30" | bc -l 2>/dev/null || echo "0")
        
        echo -e "Current Height:          ${GREEN}$(format_number ${M_HEIGHT:-0})${NC}"
        echo -e "Network Difficulty:      ${BLUE}$(format_number ${NETWORK_HASH:-0})${NC}"
        echo -e "Network Hashrate:        ${BLUE}~${NETWORK_HASHRATE} H/s${NC}"
        echo -e "Block Size Limit:        ${CYAN}$(format_number ${BLOCK_SIZE:-0}) bytes${NC}"
        echo -e "Block Weight Limit:      ${CYAN}$(format_number ${BLOCK_WEIGHT:-0})${NC}"
        
        BLOCKS_PER_DAY=2880
        DAYS_ELAPSED=$(echo "scale=2; ${M_HEIGHT:-0} / $BLOCKS_PER_DAY" | bc -l 2>/dev/null || echo "0")
        
        echo ""
        echo -e "Days Elapsed:            ${CYAN}${DAYS_ELAPSED}${NC}"
        echo -e "Avg Blocks/Day:          ${CYAN}${BLOCKS_PER_DAY}${NC}"
    else
        echo -e "${YELLOW}Waiting for blockchain data...${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Press Ctrl+C to exit | Updates every 5 seconds${NC}"
}

# Main loop
while true; do
    display_dashboard
    sleep 5
done
