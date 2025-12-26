#!/bin/bash
# Orphan Rate Tracker for Local Testnet
# Target: <5% orphan rate
# Usage: ./monitoring/orphan-rate-tracker-local.sh [duration_minutes]

set -e

DURATION_MINUTES=${1:-60}
SAMPLE_INTERVAL=30

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

LOGFILE="data/orphan-rate-$(date +%Y%m%d-%H%M%S).log"

echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Orphan Rate Tracker - Local Testnet                  ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Monitoring for ${DURATION_MINUTES} minutes...${NC}"
echo -e "${CYAN}Logging to: ${LOGFILE}${NC}"
echo ""

mkdir -p data

SAMPLES=$(( DURATION_MINUTES * 60 / SAMPLE_INTERVAL ))
TOTAL_BLOCKS=0
TOTAL_ORPHANS=0

for (( i=1; i<=SAMPLES; i++ )); do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Query all nodes for alt_blocks_count
    ORPHANS_SEED1=$(curl -s http://127.0.0.1:29081/get_info 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('alt_blocks_count', 0))" 2>/dev/null || echo 0)
    ORPHANS_SEED2=$(curl -s http://127.0.0.1:29083/get_info 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('alt_blocks_count', 0))" 2>/dev/null || echo 0)
    ORPHANS_SEED3=$(curl -s http://127.0.0.1:29085/get_info 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('alt_blocks_count', 0))" 2>/dev/null || echo 0)
    ORPHANS_MINING=$(curl -s http://127.0.0.1:29087/get_info 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('alt_blocks_count', 0))" 2>/dev/null || echo 0)
    
    # Get current height from mining node
    HEIGHT=$(curl -s http://127.0.0.1:29087/get_info 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('height', 0))" 2>/dev/null || echo 0)
    
    # Average orphans across nodes
    AVG_ORPHANS=$(echo "scale=2; ($ORPHANS_SEED1 + $ORPHANS_SEED2 + $ORPHANS_SEED3 + $ORPHANS_MINING) / 4" | bc -l)
    
    # Calculate orphan rate
    if [ "$HEIGHT" -gt 0 ]; then
        ORPHAN_RATE=$(echo "scale=4; ($AVG_ORPHANS / $HEIGHT) * 100" | bc -l)
    else
        ORPHAN_RATE="0"
    fi
    
    # Log entry
    echo "$TIMESTAMP | Height: $HEIGHT | Orphans: $AVG_ORPHANS | Rate: ${ORPHAN_RATE}%" | tee -a "$LOGFILE"
    
    # Visual feedback
    ORPHAN_RATE_INT=$(echo "$ORPHAN_RATE" | cut -d'.' -f1)
    if [ "$ORPHAN_RATE_INT" -lt 5 ]; then
        COLOR=$GREEN
        STATUS="✓ GOOD"
    elif [ "$ORPHAN_RATE_INT" -lt 10 ]; then
        COLOR=$YELLOW
        STATUS="⚠ WARNING"
    else
        COLOR=$RED
        STATUS="✗ HIGH"
    fi
    
    echo -e "  ${COLOR}${STATUS}${NC} | Orphan Rate: ${COLOR}${ORPHAN_RATE}%${NC}"
    echo ""
    
    if [ $i -lt $SAMPLES ]; then
        sleep $SAMPLE_INTERVAL
    fi
done

# Final summary
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}ORPHAN RATE SUMMARY${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Duration:     ${DURATION_MINUTES} minutes"
echo "Samples:      $SAMPLES"
echo ""

FINAL_INFO=$(curl -s http://127.0.0.1:29087/get_info 2>/dev/null)
FINAL_HEIGHT=$(echo "$FINAL_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('height', 0))" 2>/dev/null || echo 0)
FINAL_ORPHANS=$(echo "$FINAL_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin).get('alt_blocks_count', 0))" 2>/dev/null || echo 0)
FINAL_RATE=$(echo "scale=4; ($FINAL_ORPHANS / $FINAL_HEIGHT) * 100" | bc -l)

echo "Final Height: $FINAL_HEIGHT"
echo "Total Orphans: $FINAL_ORPHANS"
echo ""

if (( $(echo "$FINAL_RATE < 5" | bc -l) )); then
    echo -e "${GREEN}✓ PASSED:${NC} Orphan rate ${FINAL_RATE}% < 5% target"
else
    echo -e "${RED}✗ FAILED:${NC} Orphan rate ${FINAL_RATE}% >= 5% target"
fi

echo ""
echo "Full log: $LOGFILE"
