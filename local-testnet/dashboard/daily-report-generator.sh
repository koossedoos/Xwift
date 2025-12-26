#!/bin/bash
# Generate daily validation report (Markdown)
# Usage: ./dashboard/daily-report-generator.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="$SCRIPT_DIR/reports"
mkdir -p "$REPORT_DIR"

DATE=$(date +%Y-%m-%d)
REPORT_FILE="$REPORT_DIR/daily-report-${DATE}.md"

get_info() {
  local port="$1"
  curl -s --max-time 5 "http://127.0.0.1:${port}/get_info" | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)))" 2>/dev/null || echo "{}"
}

S1=$(get_info 29081)
S2=$(get_info 29083)
S3=$(get_info 29085)
MN=$(get_info 29087)

python3 - "$REPORT_FILE" "$S1" "$S2" "$S3" "$MN" "$DATE" <<'PY'
import json, sys, datetime
path, seed1, seed2, seed3, mining, date = sys.argv[1:]
seed1 = json.loads(seed1)
seed2 = json.loads(seed2)
seed3 = json.loads(seed3)
mining = json.loads(mining)

def fmt(info):
    return {
        'height': info.get('height', 0),
        'difficulty': info.get('difficulty', 0),
        'tx_pool': info.get('tx_pool_size', 0),
        'out_peers': info.get('outgoing_connections_count', 0),
        'in_peers': info.get('incoming_connections_count', 0),
        'alt_blocks': info.get('alt_blocks_count', 0),
    }

seed1 = fmt(seed1)
seed2 = fmt(seed2)
seed3 = fmt(seed3)
mining = fmt(mining)

report = f"""# Xwift Local Testnet - Daily Report ({date})

## Summary

- Blocks mined today: TBD (use orphan-rate logs)
- Network difficulty: {mining['difficulty']:,}
- Mining node height: {mining['height']:,}
- TX pool size: {mining['tx_pool']}
- Outgoing peers: {mining['out_peers']}

## Node Status

| Node   | Height | Out Peers | Alt Blocks |
|--------|--------|-----------|------------|
| Seed 1 | {seed1['height']:,} | {seed1['out_peers']} | {seed1['alt_blocks']} |
| Seed 2 | {seed2['height']:,} | {seed2['out_peers']} | {seed2['alt_blocks']} |
| Seed 3 | {seed3['height']:,} | {seed3['out_peers']} | {seed3['alt_blocks']} |
| Mining | {mining['height']:,} | {mining['out_peers']} | {mining['alt_blocks']} |

## Observations

- Orphan rate: See latest log in `local-testnet/data/`
- Difficulty trend: Run `./monitoring/difficulty-monitor-local.sh`
- Dev fund status: `./monitoring/dev-fund-checker-local.sh`
- Block propagation: `./monitoring/block-propagation-test.sh`

## Action Items

1. [] Review orphan log
2. [] Run emission validator
3. [] Update hashrate simulator run
4. [] Archive dashboard screenshot

---

Generated automatically on {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}.
"""

with open(path, 'w', encoding='utf-8') as fh:
    fh.write(report)
PY

echo "Report generated: $REPORT_FILE"
