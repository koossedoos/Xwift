#!/bin/bash
# Block propagation test harness
# Measures how long it takes for new blocks mined locally to reach seed nodes
# Usage: ./monitoring/block-propagation-test.sh [samples]

set -euo pipefail

SAMPLES=${1:-5}
THRESHOLD=${2:-2.0}   # seconds target for propagation
MINER_PORT=29087
SEED_PORTS=(29081 29083 29085)
SEED_NAMES=(Seed1 Seed2 Seed3)

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

cat <<'BANNER'
╔════════════════════════════════════════════════════════════╗
║       Block Propagation Test - Local Testnet               ║
╚════════════════════════════════════════════════════════════╝
BANNER

timestamp_ns() {
  date +%s%N
}

get_height() {
  local port="$1"
  curl -s --max-time 5 "http://127.0.0.1:${port}/get_info" | \
    python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('height', 0))" 2>/dev/null || echo 0
}

wait_for_height() {
  local port="$1"; local target="$2"
  local current
  while true; do
    current=$(get_height "$port")
    if [ "$current" -ge "$target" ]; then
      echo "$current"
      return
    fi
    sleep 0.5
  done
}

printf "${BOLD}%-8s %-12s %-12s %-12s %-12s${NC}\n" "Run" "Height" "Seed1 (s)" "Seed2 (s)" "Seed3 (s)"
printf "${BOLD}%-8s %-12s %-12s %-12s %-12s${NC}\n" "--------" "------------" "------------" "------------" "------------"

total_latency=(0 0 0)
passes=0

for ((sample=1; sample<=SAMPLES; sample++)); do
  base_height=$(get_height "$MINER_PORT")
  target_height=$(( base_height + 1 ))
  echo -e "${CYAN}Waiting for new block (target height: $target_height)...${NC}"

  # Wait for mining node to find next block
  while true; do
    new_height=$(get_height "$MINER_PORT")
    if [ "$new_height" -ge "$target_height" ]; then
      start_ns=$(timestamp_ns)
      break
    fi
    sleep 0.5
  done

  printf "%-8s %-12s" "$sample" "$new_height"

  for idx in "${!SEED_PORTS[@]}"; do
    port=${SEED_PORTS[$idx]}
    name=${SEED_NAMES[$idx]}
    wait_for_height "$port" "$new_height" >/dev/null
    end_ns=$(timestamp_ns)
    elapsed=$(python3 - "$start_ns" "$end_ns" <<'PY'
import sys
start=int(sys.argv[1])
end=int(sys.argv[2])
print((end-start)/1e9)
PY
)
    total_latency[$idx]=$(python3 - "${total_latency[$idx]}" "$elapsed" <<'PY'
import sys
prev=float(sys.argv[1])
value=float(sys.argv[2])
print(prev+value)
PY
)
    comparison=$(python3 - "$elapsed" "$THRESHOLD" <<'PY'
import sys
latency=float(sys.argv[1])
thresh=float(sys.argv[2])
print('OK' if latency <= thresh else 'SLOW')
PY
)
    if [ "$comparison" == "OK" ]; then
      printf " ${GREEN}%-12s${NC}" "$(printf %.2f "$elapsed")"
    else
      printf " ${RED}%-12s${NC}" "$(printf %.2f "$elapsed")"
    fi
  done
  echo ""
  passes=$((passes + 1))
done

echo ""
printf "${BOLD}AVERAGE LATENCY (seconds)${NC}\n"
for idx in "${!SEED_NAMES[@]}"; do
  avg=$(python3 - "${total_latency[$idx]}" "$passes" <<'PY'
import sys
s=float(sys.argv[1])
n=int(float(sys.argv[2])) or 1
print(s/n)
PY
)
  name=${SEED_NAMES[$idx]}
  color=$([ $(python3 - <<PY
import sys
avg=float('${avg}')
th=float('${THRESHOLD}')
print('1' if avg<=th else '0')
PY
) -eq 1 ] && echo "$GREEN" || echo "$YELLOW")
  printf "%s%-6s:%s %.2f s\n" "$color" "$name" "$NC" "$avg"
done
