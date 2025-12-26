#!/bin/bash
# Simulate hashrate variance by adjusting mining threads (50% - 500%)
# Usage: ./hashrate-simulator.sh [cycles]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CYCLES=${1:-3}
RPC_PORT=29087
RPC_AUTH="testnet:testnet123"

if [ ! -f .env ]; then
  echo "Missing .env. Copy .env.example and set MINER_ADDRESS first." >&2
  exit 1
fi
source .env
BASE_THREADS=${MINING_THREADS:-4}
MINER_ADDRESS=${MINER_ADDRESS:-}

if [ -z "$MINER_ADDRESS" ]; then
  echo "MINER_ADDRESS not defined in .env" >&2
  exit 1
fi

# Profiles: percentage multiplier of base threads
PROFILES=("50" "100" "200" "500")
DURATION_PER_STAGE=120   # seconds

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

cat <<'BANNER'
╔════════════════════════════════════════════════════════════╗
║       Hashrate Simulator - Local Testnet                   ║
╚════════════════════════════════════════════════════════════╝
BANNER

echo -e "${CYAN}Base threads: ${BASE_THREADS}${NC}"
echo -e "${CYAN}Cycles: ${CYCLES}${NC}"
echo ""

rpc_call() {
  local payload="$1"
  curl -s -u "$RPC_AUTH" -H 'Content-Type: application/json' -d "$payload" "http://127.0.0.1:${RPC_PORT}/json_rpc"
}

start_stage() {
  local multiplier="$1"
  local threads=$(python3 - <<PY
import math
base = int('${BASE_THREADS}')
factor = float('${multiplier}') / 100.0
threads = max(1, int(round(base * factor)))
print(min(threads, 12))
PY
)

  echo -e "${YELLOW}→ Setting hashrate to ${multiplier}% (${threads} threads)${NC}"
  rpc_call '{"jsonrpc":"2.0","id":"0","method":"stop_mining"}' >/dev/null
  sleep 2
  response=$(rpc_call '{"jsonrpc":"2.0","id":"0","method":"start_mining","params":{"miner_address":"'"$MINER_ADDRESS"'","threads_count":'"$threads"'}}')
  echo "$response" | grep -q '"status":"OK"' && echo -e "${GREEN}✓ Mining started${NC}" || echo "⚠ Mining start may have failed"
  echo ""
}

for cycle in $(seq 1 $CYCLES); do
  echo ""
  echo -e "${GREEN}════ Cycle ${cycle}/${CYCLES} ════${NC}"
  for profile in "${PROFILES[@]}"; do
    start_stage "$profile"
    echo -e "${CYAN}Waiting ${DURATION_PER_STAGE}s for difficulty adjustment...${NC}"
    sleep "$DURATION_PER_STAGE"
  done
done

echo ""
echo -e "${GREEN}✓ Hashrate simulation complete.${NC}"
echo "Run ./monitoring/difficulty-monitor-local.sh to analyze results."
