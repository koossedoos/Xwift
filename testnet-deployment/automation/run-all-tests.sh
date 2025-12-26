#!/bin/bash
# Master Test Orchestrator for Xwift Testnet
# Runs all validation tests continuously for 30 days

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITOR_DIR="$SCRIPT_DIR/../monitoring"
REPORT_DIR="$SCRIPT_DIR/../reports"

# Default test duration (30 days)
DURATION_DAYS=30
NODE="localhost:29081"

print_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

usage() {
    cat << EOF
Xwift Testnet Test Orchestrator

Runs all validation tests for the specified duration.

Usage: $0 [options]

Options:
  --duration DAYS    Test duration in days (default: 30)
  --node HOST:PORT   RPC endpoint (default: localhost:29081)
  --help             Show this help

Tests run:
  1. Continuous orphan rate monitoring
  2. Difficulty adjustment tracking
  3. Block propagation measurements
  4. Daily emission validation
  5. Dev fund checkpoint verification
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --duration)
            DURATION_DAYS="$2"
            shift 2
            ;;
        --node)
            NODE="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

print_info "========================================"
print_info "Xwift Testnet Validation"
print_info "Duration: $DURATION_DAYS days"
print_info "Node: $NODE"
print_info "Started: $(date)"
print_info "========================================"

# Create reports directory
mkdir -p "$REPORT_DIR"

# Calculate end time
END_TIME=$(($(date +%s) + DURATION_DAYS * 86400))

# Start background monitoring processes
print_info "Starting background monitoring..."

# 1. Orphan rate tracker (continuous)
"$MONITOR_DIR/orphan-rate-tracker.sh" \
    --node "$NODE" \
    --sample 10000 \
    --delay 60 \
    > "$REPORT_DIR/orphan-tracker-$(date +%Y%m%d).log" 2>&1 &
ORPHAN_PID=$!

print_info "Started orphan rate tracker (PID: $ORPHAN_PID)"

# 2. Difficulty monitor (continuous)
"$MONITOR_DIR/difficulty-monitor.sh" \
    --node "$NODE" \
    --duration 100000 \
    --delay 35 \
    > "$REPORT_DIR/difficulty-monitor-$(date +%Y%m%d).log" 2>&1 &
DIFF_PID=$!

print_info "Started difficulty monitor (PID: $DIFF_PID)"

# 3. Block propagation test (continuous)
"$MONITOR_DIR/block-propagation-test.sh" \
    --samples 10000 \
    --interval 10 \
    > "$REPORT_DIR/block-propagation-$(date +%Y%m%d).log" 2>&1 &
PROP_PID=$!

print_info "Started block propagation test (PID: $PROP_PID)"

# Create PID file for cleanup
echo "$ORPHAN_PID" > "$REPORT_DIR/.test_pids"
echo "$DIFF_PID" >> "$REPORT_DIR/.test_pids"
echo "$PROP_PID" >> "$REPORT_DIR/.test_pids"

# Main monitoring loop
print_info "Entering main monitoring loop..."

day_counter=1
while [ $(date +%s) -lt $END_TIME ]; do
    print_info "Day $day_counter of $DURATION_DAYS - $(date)"
    
    # Daily tasks
    print_info "Running daily checks..."
    
    # Collect metrics
    "$MONITOR_DIR/collect-metrics.sh" --daily-report || print_warning "Daily report failed"
    
    # Emission validation (daily at key checkpoints)
    python3 "$MONITOR_DIR/emission-validator.py" \
        --node "$NODE" \
        --output "$REPORT_DIR/emission-validation-day${day_counter}.json" \
        || print_warning "Emission validation failed"
    
    # Check background processes
    if ! kill -0 $ORPHAN_PID 2>/dev/null; then
        print_warning "Orphan tracker stopped, restarting..."
        "$MONITOR_DIR/orphan-rate-tracker.sh" \
            --node "$NODE" --sample 10000 \
            > "$REPORT_DIR/orphan-tracker-restart-$(date +%Y%m%d).log" 2>&1 &
        ORPHAN_PID=$!
    fi
    
    if ! kill -0 $DIFF_PID 2>/dev/null; then
        print_warning "Difficulty monitor stopped, restarting..."
        "$MONITOR_DIR/difficulty-monitor.sh" \
            --node "$NODE" --duration 100000 \
            > "$REPORT_DIR/difficulty-monitor-restart-$(date +%Y%m%d).log" 2>&1 &
        DIFF_PID=$!
    fi
    
    if ! kill -0 $PROP_PID 2>/dev/null; then
        print_warning "Block propagation test stopped, restarting..."
        "$MONITOR_DIR/block-propagation-test.sh" \
            --samples 10000 \
            > "$REPORT_DIR/block-propagation-restart-$(date +%Y%m%d).log" 2>&1 &
        PROP_PID=$!
    fi
    
    # Weekly stress tests (every 7 days)
    if [ $((day_counter % 7)) -eq 0 ]; then
        print_info "Running weekly stress tests..."
        "$SCRIPT_DIR/hashrate-variance-test.sh" || print_warning "Hashrate variance test failed"
    fi
    
    day_counter=$((day_counter + 1))
    
    # Sleep until next day (24 hours)
    sleep 86400
done

print_info "========================================"
print_info "Test duration complete!"
print_info "Stopping background processes..."

# Stop background processes
kill $ORPHAN_PID $DIFF_PID $PROP_PID 2>/dev/null || true

# Generate final report
print_info "Generating final report..."
"$SCRIPT_DIR/automated-report.sh" --final > "$REPORT_DIR/FINAL_VALIDATION_REPORT.md"

print_info "========================================"
print_info "30-Day Validation Complete!"
print_info "Final report: $REPORT_DIR/FINAL_VALIDATION_REPORT.md"
print_info "Completed: $(date)"
print_info "========================================"

# Cleanup PID file
rm -f "$REPORT_DIR/.test_pids"
