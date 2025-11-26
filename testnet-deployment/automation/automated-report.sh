#!/bin/bash
# Automated Report Generator for Xwift Testnet Validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="$SCRIPT_DIR/../reports"
REPORT_TYPE="summary"

usage() {
    cat << EOF
Automated Report Generator

Usage: $0 [--daily|--weekly|--final]

Options:
  --daily     Generate daily summary report
  --weekly    Generate weekly summary report
  --final     Generate final 30-day validation report
  --help      Show this help
EOF
}

# Parse arguments
case "${1:-}" in
    --daily)
        REPORT_TYPE="daily"
        ;;
    --weekly)
        REPORT_TYPE="weekly"
        ;;
    --final)
        REPORT_TYPE="final"
        ;;
    --help)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
esac

generate_daily_report() {
    echo "# Xwift Testnet Daily Report - $(date +%Y-%m-%d)"
    echo ""
    echo "**Generated:** $(date)"
    echo ""
    
    # Parse latest metrics
    if [ -f "$REPORT_DIR/metrics-latest.json" ]; then
        echo "## Node Status"
        echo ""
        jq -r '.nodes[] | "- **\(.node)**: Height \(.height), Difficulty \(.difficulty), Connections: \(.outgoing_connections) out / \(.incoming_connections) in"' "$REPORT_DIR/metrics-latest.json" 2>/dev/null || echo "Metrics file parsing failed"
        echo ""
    fi
    
    # Check orphan rate logs
    echo "## Orphan Rate"
    if ls "$REPORT_DIR"/orphan-rate-*.log >/dev/null 2>&1; then
        latest_orphan=$(ls -t "$REPORT_DIR"/orphan-rate-*.log | head -1)
        orphan_rate=$(tail -20 "$latest_orphan" | grep -oP 'Orphan rate: \K[0-9.]+' | tail -1 || echo "N/A")
        echo "- Current orphan rate: ${orphan_rate}%"
        echo ""
    else
        echo "- No orphan rate data available"
        echo ""
    fi
    
    # Check difficulty stability
    echo "## Difficulty"
    if ls "$REPORT_DIR"/difficulty-*.csv >/dev/null 2>&1; then
        latest_diff=$(ls -t "$REPORT_DIR"/difficulty-*.csv | head -1)
        avg_block_time=$(tail -100 "$latest_diff" | awk -F',' 'NR>1 {sum+=$4; count++} END {printf "%.2f", sum/count}')
        echo "- Average block time (last 100): ${avg_block_time}s"
        echo ""
    else
        echo "- No difficulty data available"
        echo ""
    fi
    
    echo "## Next Actions"
    echo "- Continue monitoring"
    echo "- Review any anomalies"
    echo ""
}

generate_weekly_report() {
    echo "# Xwift Testnet Weekly Report - Week $(date +%U) of $(date +%Y)"
    echo ""
    echo "**Period:** $(date -d '7 days ago' +%Y-%m-%d) to $(date +%Y-%m-%d)"
    echo ""
    
    echo "## Summary"
    echo "- Total blocks: [Calculate from logs]"
    echo "- Average block time: [Calculate from difficulty logs]"
    echo "- Orphan rate: [Calculate from orphan logs]"
    echo "- Uptime: [Calculate from node status]"
    echo ""
    
    echo "## Key Highlights"
    echo "- [Major events this week]"
    echo ""
    
    echo "## Issues Encountered"
    echo "- [List any issues]"
    echo ""
    
    echo "## Next Week Goals"
    echo "- Continue monitoring"
    echo "- Run hashrate variance tests"
    echo ""
}

generate_final_report() {
    cat "$SCRIPT_DIR/../reports/TESTNET_VALIDATION_REPORT.md"
    
    echo ""
    echo "## Auto-Generated Statistics"
    echo ""
    
    # Aggregate orphan rate
    if ls "$REPORT_DIR"/orphan-rate-*.log >/dev/null 2>&1; then
        echo "### Orphan Rate Summary"
        for log in "$REPORT_DIR"/orphan-rate-*.log; do
            rate=$(grep "Orphan rate:" "$log" | tail -1 | grep -oP '\d+\.\d+' || echo "N/A")
            echo "- $(basename "$log"): ${rate}%"
        done
        echo ""
    fi
    
    # Aggregate difficulty data
    if ls "$REPORT_DIR"/difficulty-*.csv >/dev/null 2>&1; then
        echo "### Difficulty Statistics"
        for csv in "$REPORT_DIR"/difficulty-*.csv; do
            blocks=$(wc -l < "$csv")
            avg_time=$(awk -F',' 'NR>1 {sum+=$4; count++} END {printf "%.2f", sum/count}' "$csv")
            echo "- $(basename "$csv"): $blocks blocks, avg time ${avg_time}s"
        done
        echo ""
    fi
    
    # Block propagation stats
    if ls "$REPORT_DIR"/block-propagation-*.csv >/dev/null 2>&1; then
        echo "### Block Propagation Statistics"
        for csv in "$REPORT_DIR"/block-propagation-*.csv; do
            avg_delay=$(awk -F',' 'NR>1 && $5>0 {sum+=$5; count++} END {if (count>0) printf "%.2f", sum/count; else print "N/A"}' "$csv")
            echo "- $(basename "$csv"): avg ${avg_delay}ms"
        done
        echo ""
    fi
    
    echo "---"
    echo "**Report generated:** $(date)"
}

# Generate appropriate report
case "$REPORT_TYPE" in
    daily)
        generate_daily_report
        ;;
    weekly)
        generate_weekly_report
        ;;
    final)
        generate_final_report
        ;;
esac
