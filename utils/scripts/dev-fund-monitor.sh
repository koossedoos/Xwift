#!/bin/bash
# Xwift Development Fund Public Transparency Monitor
# This script tracks and displays development fund statistics in real-time

set -e

# Configuration
RPC_HOST="localhost"
RPC_PORT="18081"
DEV_FUND_ADDRESS="${1:-DEVELOPMENT_FUND_ADDRESS_TO_BE_SET}"
DEV_FUND_DURATION_BLOCKS=1051200
BLOCKS_PER_DAY=2880
DEV_FUND_PERCENTAGE=2

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

clear

echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║      XWIFT DEVELOPMENT FUND TRANSPARENCY MONITOR          ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to make RPC calls
rpc_call() {
    local method=$1
    local params=$2
    curl -s -X POST http://${RPC_HOST}:${RPC_PORT}/json_rpc \
        -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"${method}\",\"params\":${params}}" \
        -H 'Content-Type: application/json' 2>/dev/null
}

# Function to format numbers with commas
format_number() {
    printf "%'d" $1 2>/dev/null || echo $1
}

# Function to convert atomic units to XWIFT
atomic_to_xwift() {
    local atomic=$1
    echo "scale=8; $atomic / 100000000" | bc -l 2>/dev/null | sed 's/^\./0./' || echo "0"
}

# Get blockchain info
echo -e "${CYAN}📊 Fetching blockchain data...${NC}"
BLOCKCHAIN_INFO=$(rpc_call "get_info" "{}")

if [ $? -ne 0 ] || [ -z "$BLOCKCHAIN_INFO" ]; then
    echo -e "${RED}❌ Error: Cannot connect to Xwift daemon on ${RPC_HOST}:${RPC_PORT}${NC}"
    echo "Please ensure xwiftd is running and RPC is accessible."
    exit 1
fi

# Parse blockchain info
CURRENT_HEIGHT=$(echo $BLOCKCHAIN_INFO | grep -o '"height":[0-9]*' | cut -d':' -f2)
DIFFICULTY=$(echo $BLOCKCHAIN_INFO | grep -o '"difficulty":[0-9]*' | cut -d':' -f2)
NETWORK_HASHRATE=$(echo "scale=2; $DIFFICULTY / 30" | bc -l 2>/dev/null || echo "0")

if [ -z "$CURRENT_HEIGHT" ]; then
    echo -e "${RED}❌ Error: Failed to parse blockchain height${NC}"
    exit 1
fi

# Calculate dev fund status
BLOCKS_REMAINING=$((DEV_FUND_DURATION_BLOCKS - CURRENT_HEIGHT))
if [ $BLOCKS_REMAINING -lt 0 ]; then
    BLOCKS_REMAINING=0
fi

DAYS_ELAPSED=$((CURRENT_HEIGHT / BLOCKS_PER_DAY))
DAYS_REMAINING=$((BLOCKS_REMAINING / BLOCKS_PER_DAY))
FUND_ACTIVE="true"

if [ $CURRENT_HEIGHT -gt $DEV_FUND_DURATION_BLOCKS ]; then
    FUND_ACTIVE="false"
fi

# Calculate percentage complete
PERCENT_COMPLETE=$((100 * CURRENT_HEIGHT / DEV_FUND_DURATION_BLOCKS))
if [ $PERCENT_COMPLETE -gt 100 ]; then
    PERCENT_COMPLETE=100
fi

# Estimate total dev fund collected (approximate)
# Average block reward calculation (simplified for estimation)
ESTIMATED_AVG_REWARD=300000000  # 3 XWIFT in atomic units (approximate)
ESTIMATED_DEV_FUND_PER_BLOCK=$((ESTIMATED_AVG_REWARD * DEV_FUND_PERCENTAGE / 100))
ESTIMATED_TOTAL_COLLECTED=$((ESTIMATED_DEV_FUND_PER_BLOCK * CURRENT_HEIGHT))
if [ $CURRENT_HEIGHT -gt $DEV_FUND_DURATION_BLOCKS ]; then
    ESTIMATED_TOTAL_COLLECTED=$((ESTIMATED_DEV_FUND_PER_BLOCK * DEV_FUND_DURATION_BLOCKS))
fi

# Display blockchain status
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}BLOCKCHAIN STATUS${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "Current Block Height:    ${GREEN}$(format_number $CURRENT_HEIGHT)${NC}"
echo -e "Network Difficulty:      ${BLUE}$(format_number $DIFFICULTY)${NC}"
echo -e "Network Hashrate:        ${BLUE}~$(printf "%.2f" $NETWORK_HASHRATE) H/s${NC}"
echo -e "Days Since Genesis:      ${CYAN}$(format_number $DAYS_ELAPSED)${NC}"

# Display dev fund status
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}DEVELOPMENT FUND STATUS${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"

if [ "$FUND_ACTIVE" = "true" ]; then
    echo -e "Status:                  ${GREEN}● ACTIVE${NC}"
    echo -e "Allocation Rate:         ${YELLOW}2% of block rewards${NC}"
    echo -e "Blocks Remaining:        ${CYAN}$(format_number $BLOCKS_REMAINING)${NC} / $(format_number $DEV_FUND_DURATION_BLOCKS)"
    echo -e "Days Remaining:          ${CYAN}~$(format_number $DAYS_REMAINING)${NC} days"
    echo -e "Progress:                ${YELLOW}${PERCENT_COMPLETE}%${NC} ["

    # Progress bar
    BAR_WIDTH=40
    FILLED=$((PERCENT_COMPLETE * BAR_WIDTH / 100))
    EMPTY=$((BAR_WIDTH - FILLED))
    printf "                         ${GREEN}"
    for ((i=0; i<FILLED; i++)); do printf "█"; done
    printf "${NC}"
    for ((i=0; i<EMPTY; i++)); do printf "░"; done
    echo "]"
else
    echo -e "Status:                  ${RED}● ENDED${NC}"
    echo -e "Termination Block:       ${CYAN}$(format_number $DEV_FUND_DURATION_BLOCKS)${NC}"
    echo -e "Duration Completed:      ${GREEN}100%${NC}"
    echo -e "Current Block:           ${CYAN}$(format_number $CURRENT_HEIGHT)${NC}"
fi

# Display estimated collection
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}ESTIMATED FUND COLLECTION${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"

XWIFT_COLLECTED=$(atomic_to_xwift $ESTIMATED_TOTAL_COLLECTED)
ESTIMATED_DAILY=$((ESTIMATED_DEV_FUND_PER_BLOCK * BLOCKS_PER_DAY))
XWIFT_DAILY=$(atomic_to_xwift $ESTIMATED_DAILY)

echo -e "Per Block (estimated):   ${YELLOW}~$(atomic_to_xwift $ESTIMATED_DEV_FUND_PER_BLOCK) XWIFT${NC}"
echo -e "Per Day (estimated):     ${YELLOW}~${XWIFT_DAILY} XWIFT${NC}"
echo -e "Total Collected:         ${GREEN}~${XWIFT_COLLECTED} XWIFT${NC}"

if [ "$FUND_ACTIVE" = "true" ]; then
    ESTIMATED_FINAL_TOTAL=$((ESTIMATED_DEV_FUND_PER_BLOCK * DEV_FUND_DURATION_BLOCKS))
    XWIFT_FINAL=$(atomic_to_xwift $ESTIMATED_FINAL_TOTAL)
    echo -e "Projected Final Total:   ${CYAN}~${XWIFT_FINAL} XWIFT${NC}"
fi

# Display dev fund address
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}DEVELOPMENT FUND ADDRESS (PUBLIC)${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"

if [ "$DEV_FUND_ADDRESS" = "DEVELOPMENT_FUND_ADDRESS_TO_BE_SET" ]; then
    echo -e "${YELLOW}⚠️  Address not yet set${NC}"
    echo "Please set the development fund address in cryptonote_config.h"
else
    echo -e "${GREEN}${DEV_FUND_ADDRESS}${NC}"
    echo ""
    echo "✓ All transactions to this address are publicly visible on the blockchain"
    echo "✓ Anyone can monitor fund usage using a block explorer"
    echo "✓ Quarterly reports will be published with transaction details"
fi

# Display transparency information
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}TRANSPARENCY & ACCOUNTABILITY${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "📋 Quarterly Reports: Published with detailed expenditure breakdown"
echo "🔍 Blockchain Visibility: All transactions publicly verifiable"
echo "📊 Real-time Monitoring: Run this script anytime to check status"
echo "🔐 Multi-signature: Funds managed with multiple key holders"
echo "👥 Community Oversight: Regular updates and accountability"

# Usage categories
echo ""
echo -e "${BOLD}AUTHORIZED EXPENDITURE CATEGORIES:${NC}"
echo "  • Development & Engineering (40-50%)"
echo "  • Infrastructure & Operations (15-25%)"
echo "  • Security Audits (10-20%)"
echo "  • Team Compensation (20-30%)"
echo "  • Administrative Costs (5-10%)"

# Next reporting date
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}UPCOMING MILESTONES${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"

BLOCKS_TO_QUARTER=$((BLOCKS_PER_DAY * 90))
NEXT_QUARTER_BLOCK=$(( (CURRENT_HEIGHT / BLOCKS_TO_QUARTER + 1) * BLOCKS_TO_QUARTER ))
BLOCKS_TO_NEXT=$((NEXT_QUARTER_BLOCK - CURRENT_HEIGHT))
DAYS_TO_NEXT=$((BLOCKS_TO_NEXT / BLOCKS_PER_DAY))

if [ "$FUND_ACTIVE" = "true" ]; then
    echo -e "Next Quarterly Report:   ${CYAN}Block $(format_number $NEXT_QUARTER_BLOCK)${NC} (~${DAYS_TO_NEXT} days)"
    echo -e "Fund Termination:        ${CYAN}Block $(format_number $DEV_FUND_DURATION_BLOCKS)${NC} (~${DAYS_REMAINING} days)"
else
    echo -e "Development fund has completed its 1-year duration."
    echo -e "All funds collected: ~${XWIFT_COLLECTED} XWIFT"
fi

# Footer
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "Generated: $(date)"
echo -e "Monitor refreshes: Run this script anytime for updated data"
echo ""
echo -e "${CYAN}For detailed expenditure reports, visit:${NC}"
echo -e "https://xwift.org/transparency  ${YELLOW}(example - set your actual URL)${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
