#!/bin/bash

# Xwift Daemon Stop Script
# Provides clean shutdown of all Xwift processes

set -e

echo "=== Stopping Xwift Daemon ==="

# Function to check and stop processes
stop_xwift_processes() {
    echo "Checking for running Xwift processes..."

    # Find all Xwift-related processes
    XWIFT_PROCESSES=$(ps aux | grep -E "xwift-daemon|xwift-wallet" | grep -v grep || true)

    if [ -n "$XWIFT_PROCESSES" ]; then
        echo "Found Xwift processes:"
        echo "$XWIFT_PROCESSES"
        echo

        echo "Attempting graceful shutdown..."
        # Send SIGTERM for graceful shutdown
        pkill -TERM -f xwift-daemon || true
        pkill -TERM -f xwift-wallet || true

        # Wait for graceful shutdown
        sleep 3

        # Check if processes are still running
        REMAINING_PROCESSES=$(ps aux | grep -E "xwift-daemon|xwift-wallet" | grep -v grep || true)

        if [ -n "$REMAINING_PROCESSES" ]; then
            echo "Some processes still running, forcing shutdown..."
            # Send SIGKILL for force shutdown
            pkill -9 -f xwift-daemon || true
            pkill -9 -f xwift-wallet || true
            sleep 1
        fi

    else
        echo "No Xwift processes found"
    fi
}

# Function to clean up port usage
cleanup_ports() {
    echo "Cleaning up Xwift port usage..."

    # Check common Xwift ports
    PORTS=(29080 29081 29082 29083)

    for port in "${PORTS[@]}"; do
        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            echo "Port $port is still in use"
            PID=$(netstat -tlnp 2>/dev/null | grep ":$port " | head -1 | awk '{print $7}' | cut -d'/' -f1)
            if [ -n "$PID" ] && [ "$PID" != "-" ]; then
                echo "Terminating process $PID using port $port"
                kill -9 "$PID" 2>/dev/null || true
            fi
        fi
    done
}

# Function to verify clean shutdown
verify_shutdown() {
    echo "Verifying clean shutdown..."

    # Check for any remaining Xwift processes
    REMAINING=$(ps aux | grep -E "xwift-daemon|xwift-wallet" | grep -v grep || true)

    if [ -n "$REMAINING" ]; then
        echo "⚠️  Warning: Some Xwift processes may still be running:"
        echo "$REMAINING"
        return 1
    else
        echo "✅ All Xwift processes stopped successfully"
        return 0
    fi
}

# Main execution
main() {
    stop_xwift_processes
    cleanup_ports

    if verify_shutdown; then
        echo
        echo "✅ Xwift daemon stopped successfully"
        echo "All processes terminated and ports cleaned up"
    else
        echo
        echo "⚠️  Some processes may still be running"
        echo "You may need to manually kill remaining processes"
        exit 1
    fi
}

# Run main function
main "$@"