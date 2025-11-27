#!/bin/bash
# Automated validation harness that stitches together all monitoring scripts
# Usage: ./test-harness.sh [--quick]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

QUICK=false
if [ "${1:-}" == "--quick" ]; then
  QUICK=true
fi

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

cat <<'BANNER'
╔════════════════════════════════════════════════════════════╗
║       Xwift Local Testnet - Validation Harness             ║
╚════════════════════════════════════════════════════════════╝
BANNER

echo -e "${CYAN}Running validation suite...${NC}"

STEP_DURATION_ORPHAN=15   # minutes
SAMPLES_PROP=5
WINDOW_DIFFICULTY=120
WINDOW_EMISSION=500

if [ "$QUICK" = true ]; then
  STEP_DURATION_ORPHAN=3
  SAMPLES_PROP=2
  WINDOW_DIFFICULTY=60
  WINDOW_EMISSION=120
  echo -e "${YELLOW}Quick mode enabled: reduced sample sizes${NC}"
fi

run_step() {
  local name="$1"
  local cmd="$2"
  echo ""
  echo -e "${BOLD}→ $name${NC}"
  eval "$cmd"
}

run_step "Node Status" "./status-testnet.sh"
run_step "Difficulty Monitor" "./monitoring/difficulty-monitor-local.sh ${WINDOW_DIFFICULTY}"
run_step "Block Propagation" "./monitoring/block-propagation-test.sh ${SAMPLES_PROP}"
run_step "Orphan Rate Tracker" "./monitoring/orphan-rate-tracker-local.sh ${STEP_DURATION_ORPHAN}"
run_step "Emission Validator" "./emission-validator-local.py --window ${WINDOW_EMISSION}"
run_step "Development Fund Checker" "./monitoring/dev-fund-checker-local.sh"
run_step "Dashboard Generation" "./dashboard/generate-local-dashboard.sh"
run_step "Daily Report" "./dashboard/daily-report-generator.sh"

cat <<SUMMARY

${GREEN}Validation complete!${NC}
Artifacts:
  - Orphan logs: local-testnet/data/orphan-rate-*.log
  - Dashboard:  local-testnet/dashboard/index.html
  - Reports:    local-testnet/dashboard/reports/

Next steps:
  1. Review dashboard HTML in a browser
  2. Check orphan log for rate <5%
  3. Attach daily report to validation records
SUMMARY
