#!/bin/bash
# Status viewer for Xwift Local Testnet
# Usage: ./status-testnet.sh [--watch]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

WATCH_MODE=false
if [ "$1" == "--watch" ]; then
    WATCH_MODE=true
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Node definitions
NODES=(
    "SeedNode1:29081"
    "SeedNode2:29083"
    "SeedNode3:29085"
    "MiningNode:29087"
)

function check_status() {
    printf "${BOLD}%-12s %-10s %-10s %-10s %-12s${NC}\n" "NODE" "HEIGHT" "TARGET" "DIFF" "PEERS"
    printf "${BOLD}%-12s %-10s %-10s %-10s %-12s${NC}\n" "------------" "----------" "----------" "----------" "------------"

    for node in "${NODES[@]}"; do
        IFS=':' read -r NAME PORT <<< "$node"
        RESPONSE=$(curl -s --max-time 5 http://127.0.0.1:${PORT}/get_info || true)

        if [ -z "$RESPONSE" ]; then
            printf "%-12s ${RED}%-10s${NC} %-10s %-10s %-12s\n" "$NAME" "OFFLINE" "-" "-" "-"
            continue
        fi

        HEIGHT=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('height', 'N/A'))" 2>/dev/null)
        TARGET_HEIGHT=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('target_height', 'N/A'))" 2>/dev/null)
        DIFFICULTY=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('difficulty', 'N/A'))" 2>/dev/null)
        OUT_PEERS=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('outgoing_connections_count', 'N/A'))" 2>/dev/null)

        printf "%-12s ${GREEN}%-10s${NC} %-10s %-10s %-12s\n" "$NAME" "$HEIGHT" "$TARGET_HEIGHT" "$DIFFICULTY" "$OUT_PEERS"
    done
}

echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Xwift Local Testnet - Status                         ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

do
    check_status
    if [ "$WATCH_MODE" = false ]; then
        break
    fi
    echo ""
    echo -e "${CYAN}Refreshing in 10 seconds...${NC}"
    echo ""
    sleep 10
done
