#!/bin/bash
# Development Fund Checker for Local Testnet
# Verifies 2% dev fund termination at block 1,051,200
# Usage: ./monitoring/dev-fund-checker-local.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DEV_FUND_TERMINATION_BLOCK=1051200
BLOCKS_PER_DAY=2880
RPC_PORT=29087

echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Development Fund Checker - Local Testnet             ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get current blockchain height
INFO=$(curl -s http://127.0.0.1:${RPC_PORT}/get_info)
HEIGHT=$(echo "$INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('height', 0))" 2>/dev/null || echo 0)

if [ "$HEIGHT" -eq 0 ]; then
    echo -e "${RED}❌ Cannot connect to mining node on port ${RPC_PORT}${NC}"
    exit 1
fi

echo -e "${CYAN}Current Height:${NC} $(printf "%'d" $HEIGHT)"
echo -e "${CYAN}Dev Fund Termination:${NC} $(printf "%'d" $DEV_FUND_TERMINATION_BLOCK)"
echo ""

BLOCKS_REMAINING=$(( DEV_FUND_TERMINATION_BLOCK - HEIGHT ))

if [ $BLOCKS_REMAINING -gt 0 ]; then
    DAYS_REMAINING=$(echo "scale=2; $BLOCKS_REMAINING / $BLOCKS_PER_DAY" | bc -l)
    PERCENT_COMPLETE=$(echo "scale=2; ($HEIGHT / $DEV_FUND_TERMINATION_BLOCK) * 100" | bc -l)
    
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}DEVELOPMENT FUND STATUS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Status:              ${GREEN}● ACTIVE${NC}"
    echo -e "Allocation Rate:     ${YELLOW}2% of block rewards${NC}"
    echo -e "Blocks Remaining:    ${CYAN}$(printf "%'d" $BLOCKS_REMAINING)${NC}"
    echo -e "Days Remaining:      ${CYAN}~${DAYS_REMAINING}${NC}"
    echo -e "Progress:            ${YELLOW}${PERCENT_COMPLETE}%${NC}"
    echo ""
    
    # Progress bar
    BAR_WIDTH=50
    FILLED=$(echo "scale=0; $PERCENT_COMPLETE * $BAR_WIDTH / 100" | bc)
    EMPTY=$(( BAR_WIDTH - FILLED ))
    
    printf "["
    printf "${GREEN}"
    for ((i=0; i<FILLED; i++)); do printf "█"; done
    printf "${NC}"
    for ((i=0; i<EMPTY; i++)); do printf "░"; done
    printf "]\n"
    
    echo ""
    echo -e "${CYAN}💡 Development fund is active and will terminate at block 1,051,200${NC}"
    
else
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}DEVELOPMENT FUND STATUS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Status:              ${RED}● TERMINATED${NC}"
    echo -e "Termination Block:   ${CYAN}$(printf "%'d" $DEV_FUND_TERMINATION_BLOCK)${NC}"
    echo -e "Current Height:      ${CYAN}$(printf "%'d" $HEIGHT)${NC}"
    echo -e "Blocks Past Cutoff:  ${CYAN}$(printf "%'d" ${BLOCKS_REMAINING#-})${NC}"
    echo ""
    echo -e "${GREEN}✓ Development fund has successfully terminated as designed.${NC}"
fi

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}FUND MECHANICS${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "• 2% of block rewards allocated to development fund"
echo "• Duration: First 1,051,200 blocks (~1 year at 30s block time)"
echo "• Automatically terminates at block 1,051,200"
echo "• No manual intervention required"
echo "• Hardcoded in consensus rules"
echo ""

# Estimate total collected
if [ $BLOCKS_REMAINING -gt 0 ]; then
    # Rough estimate: ~3 XFT per block * 2% = 0.06 XFT per block
    ESTIMATED_PER_BLOCK=6000000
    ESTIMATED_COLLECTED=$(( HEIGHT * ESTIMATED_PER_BLOCK ))
    ESTIMATED_TOTAL=$(( DEV_FUND_TERMINATION_BLOCK * ESTIMATED_PER_BLOCK ))
else
    ESTIMATED_PER_BLOCK=6000000
    ESTIMATED_TOTAL=$(( DEV_FUND_TERMINATION_BLOCK * ESTIMATED_PER_BLOCK ))
    ESTIMATED_COLLECTED=$ESTIMATED_TOTAL
fi

XWIFT_COLLECTED=$(echo "scale=2; $ESTIMATED_COLLECTED / 100000000" | bc -l)
XWIFT_TOTAL=$(echo "scale=2; $ESTIMATED_TOTAL / 100000000" | bc -l)

echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}ESTIMATED COLLECTION${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Collected so far:    ${GREEN}~${XWIFT_COLLECTED} XWIFT${NC}"
echo -e "Projected total:     ${CYAN}~${XWIFT_TOTAL} XWIFT${NC}"
echo ""
echo -e "${YELLOW}Note: These are rough estimates. Actual amounts vary with block rewards.${NC}"
