#!/bin/bash
# Log viewer for Xwift Local Testnet
# Usage: ./logs-testnet.sh [node-name] [--follow]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Argument parsing
NODE="${1:-all}"
FOLLOW_FLAG=""

if [ "$2" == "--follow" ] || [ "$1" == "--follow" ]; then
    FOLLOW_FLAG="-f"
fi

echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Xwift Local Testnet - Logs                           ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$NODE" == "all" ]; then
    echo -e "${CYAN}Showing logs for ALL nodes${NC}"
    echo "To view specific node: ./logs-testnet.sh [seed1|seed2|seed3|mining]"
    echo ""
    
    if docker compose version &> /dev/null 2>&1; then
        docker compose logs $FOLLOW_FLAG --tail=50
    else
        docker-compose logs $FOLLOW_FLAG --tail=50
    fi
elif [ "$NODE" == "seed1" ]; then
    echo -e "${CYAN}Showing logs for Seed Node 1${NC}"
    docker logs $FOLLOW_FLAG --tail=100 xwift-seed-1
elif [ "$NODE" == "seed2" ]; then
    echo -e "${CYAN}Showing logs for Seed Node 2${NC}"
    docker logs $FOLLOW_FLAG --tail=100 xwift-seed-2
elif [ "$NODE" == "seed3" ]; then
    echo -e "${CYAN}Showing logs for Seed Node 3${NC}"
    docker logs $FOLLOW_FLAG --tail=100 xwift-seed-3
elif [ "$NODE" == "mining" ]; then
    echo -e "${CYAN}Showing logs for Mining Node${NC}"
    docker logs $FOLLOW_FLAG --tail=100 xwift-mining
else
    echo -e "${YELLOW}Unknown node: $NODE${NC}"
    echo "Available nodes: seed1, seed2, seed3, mining, all"
    exit 1
fi
