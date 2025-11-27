#!/bin/bash
# Difficulty Adjustment Monitor
# Usage: ./monitoring/difficulty-monitor-local.sh [window]

set -e

WINDOW=${1:-120}
MIN_RPC_PORT=${2:-29087}

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

cat <<'BANNER'
╔════════════════════════════════════════════════════════════╗
║       Difficulty Monitor - Local Testnet                  ║
╚════════════════════════════════════════════════════════════╝
BANNER

echo -e "${CYAN}Analyzing last ${WINDOW} blocks on RPC port ${MIN_RPC_PORT}...${NC}"

HEIGHT=$(curl -s -X POST http://127.0.0.1:${MIN_RPC_PORT}/json_rpc \
    -H 'Content-Type: application/json' \
    -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['height'])")

if [ -z "$HEIGHT" ]; then
    echo -e "${RED}Failed to get blockchain height.${NC}"
    exit 1
fi

START_HEIGHT=$(( HEIGHT - WINDOW ))
if [ $START_HEIGHT -lt 0 ]; then
    START_HEIGHT=0
fi

RESPONSE=$(curl -s -X POST http://127.0.0.1:${MIN_RPC_PORT}/json_rpc \
    -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"get_block_headers_range\",\"params\":{\"start_height\":${START_HEIGHT},\"end_height\":${HEIGHT}}}")

if [ -z "$RESPONSE" ]; then
    echo -e "${RED}Failed to retrieve block headers.${NC}"
    exit 1
fi

python3 <<PY
import json, statistics, datetime
from decimal import Decimal

data = json.loads('''${RESPONSE}''')
headers = data.get('result', {}).get('headers', [])

if not headers:
    print("No block headers returned.")
    exit()

difficulties = [h.get('difficulty', 0) for h in headers]
timestamps = [h.get('timestamp', 0) for h in headers]
heights = [h.get('height', 0) for h in headers]

median_diff = statistics.median(difficulties)
avg_diff = sum(difficulties) / len(difficulties)
min_diff = min(difficulties)
max_diff = max(difficulties)
latest_diff = difficulties[-1]
latest_height = heights[-1]

# Calculate hashrate = difficulty / target (30 seconds)
hashrates = [d / 30 for d in difficulties]
median_hashrate = statistics.median(hashrates)
avg_hashrate = sum(hashrates) / len(hashrates)

# Calculate volatility
changes = []
for i in range(1, len(difficulties)):
    if difficulties[i-1] == 0:
        continue
    change = (difficulties[i] - difficulties[i-1]) / difficulties[i-1] * 100
    changes.append(change)

volatility = statistics.pstdev(changes) if changes else 0
max_change = max(changes) if changes else 0
min_change = min(changes) if changes else 0

print("\n════════════════════════════════════════════════════════════")
print("DIFFICULTY WINDOW ANALYSIS")
print("════════════════════════════════════════════════════════════")
print(f"Blocks analyzed:    {len(difficulties)}")
print(f"Height range:       {heights[0]} - {heights[-1]}")
print(f"Time span:          {round((timestamps[-1] - timestamps[0]) / 60, 2)} minutes")
print("\nDifficulty Stats (atomic units):")
print(f"  Latest:           {latest_diff:,}")
print(f"  Median:           {median_diff:,}")
print(f"  Average:          {int(avg_diff):,}")
print(f"  Min:              {min_diff:,}")
print(f"  Max:              {max_diff:,}")
print("\nHashrate (H/s):")
print(f"  Median:           {median_hashrate:,.2f}")
print(f"  Average:          {avg_hashrate:,.2f}")
print(f"  Range:            {min(hashrates):,.2f} - {max(hashrates):,.2f}")
print("\nDifficulty Change (%):")
print(f"  Median:           {statistics.median(changes) if changes else 0:.2f}%")
print(f"  Average:          {sum(changes)/len(changes) if changes else 0:.2f}%")
print(f"  Volatility (stdev): {volatility:.2f}%")
print(f"  Largest increase: {max_change:.2f}%")
print(f"  Largest drop:     {min_change:.2f}%")

if latest_diff < median_diff * Decimal('0.5'):
    print("\nStatus: ⚠ Difficulty dropped more than 50% - investigate hashrate drop.")
elif latest_diff > median_diff * Decimal('1.5'):
    print("\nStatus: ⚠ Difficulty spiked more than 50% - possible hashrate surge.")
else:
    print("\nStatus: ✓ Difficulty within expected range.")

PY
