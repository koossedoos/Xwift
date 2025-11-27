#!/bin/bash
# Reset Xwift Local Testnet (wipe blockchain data)
# Usage: ./reset-testnet.sh [--restart]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RESTART_AFTER=false
if [ "${1:-}" == "--restart" ]; then
  RESTART_AFTER=true
fi

YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

cat <<'BANNER'
╔════════════════════════════════════════════════════════════╗
║       Xwift Local Testnet - Reset Script                   ║
╚════════════════════════════════════════════════════════════╝
BANNER

echo -e "${YELLOW}⚠️  This will STOP all containers and DELETE local blockchain data.${NC}"
read -r -p "Are you sure? (type RESET to continue): " CONFIRM

if [ "$CONFIRM" != "RESET" ]; then
  echo -e "${RED}Reset aborted.${NC}"
  exit 1
fi

echo -e "${CYAN}🛑 Stopping containers...${NC}"
if docker compose version &> /dev/null 2>&1; then
  docker compose down
else
  docker-compose down
fi

sleep 2

echo -e "${CYAN}🧹 Removing data directories...${NC}"
rm -rf data/seed1 data/seed2 data/seed3 data/mining
mkdir -p data/seed1 data/seed2 data/seed3 data/mining

cat <<'CHECKLIST'
Reset complete.
Next steps:
  1. Verify MINER_ADDRESS is set in .env
  2. Run ./start-testnet.sh to rebuild from scratch
CHECKLIST

if [ "$RESTART_AFTER" = true ]; then
  echo -e "${GREEN}🔄 Restarting testnet...${NC}"
  ./start-testnet.sh
else
  echo -e "${GREEN}✅ Reset complete. Start again with ./start-testnet.sh${NC}"
fi
