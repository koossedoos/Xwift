#!/bin/bash
# Stop Xwift Local Testnet (4 Nodes)
# Usage: ./stop-testnet.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Xwift Local Testnet - Stop Script                   ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}🛑 Stopping all testnet nodes...${NC}"

if docker compose version &> /dev/null 2>&1; then
    docker compose down
else
    docker-compose down
fi

echo ""
echo -e "${GREEN}✅ All nodes stopped${NC}"
echo ""
echo "To start again: ./start-testnet.sh"
echo "To reset blockchain: ./reset-testnet.sh"
