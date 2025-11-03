#!/bin/bash

# Xwift Testnet Daemon Start Script
# Provides standardized startup with correct configuration

set -e

echo "=== Starting Xwift Testnet Daemon ==="

# Configuration
XWIFT_DIR="${XWIFT_DIR:-$HOME/Xwift}"
BUILD_DIR="$XWIFT_DIR/build"
DAEMON_BIN="$BUILD_DIR/bin/xwift-daemon"
DATA_DIR="$HOME/.xwift/testnet"

# Network configuration
P2P_PORT=29080
RPC_PORT=29081
ZMQ_PORT=29082

# Function to check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."

    # Check if Xwift directory exists
    if [ ! -d "$XWIFT_DIR" ]; then
        echo "❌ Xwift directory not found: $XWIFT_DIR"
        echo "Please ensure Xwift is properly installed"
        exit 1
    fi

    # Check if daemon binary exists
    if [ ! -f "$DAEMON_BIN" ]; then
        echo "❌ Xwift daemon binary not found: $DAEMON_BIN"
        echo "Please build Xwift first: cd $XWIFT_DIR && make -j\$(nproc)"
        exit 1
    fi

    # Check if binary is executable
    if [ ! -x "$DAEMON_BIN" ]; then
        echo "❌ Xwift daemon binary is not executable: $DAEMON_BIN"
        echo "Making binary executable..."
        chmod +x "$DAEMON_BIN"
    fi

    echo "✅ Prerequisites check passed"
}

# Function to clean shutdown existing daemon
cleanup_existing() {
    echo "Checking for existing daemon..."

    # Use the stop script if available
    if [ -f "$XWIFT_DIR/scripts/stop_xwift.sh" ]; then
        "$XWIFT_DIR/scripts/stop_xwift.sh"
    else
        # Manual cleanup
        pkill -f xwift-daemon || true
        sleep 2
        pkill -9 -f xwift-daemon || true
    fi

    echo "✅ Existing daemon cleanup completed"
}

# Function to create data directory
setup_data_dir() {
    echo "Setting up data directory: $DATA_DIR"

    # Create data directory if it doesn't exist
    mkdir -p "$DATA_DIR"

    # Set proper permissions
    chmod 755 "$DATA_DIR"

    # Create subdirectories if needed
    mkdir -p "$DATA_DIR/testnet" 2>/dev/null || true

    echo "✅ Data directory setup completed"
}

# Function to check port availability
check_ports() {
    echo "Checking port availability..."

    PORTS=("$P2P_PORT" "$RPC_PORT" "$ZMQ_PORT")
    for port in "${PORTS[@]}"; do
        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            echo "❌ Port $port is already in use"
            echo "Please stop the service using this port or choose different ports"
            exit 1
        fi
    done

    echo "✅ All required ports are available"
}

# Function to start the daemon
start_daemon() {
    echo "Starting Xwift daemon with testnet configuration..."

    cd "$BUILD_DIR"

    # Construct daemon command
    DAEMON_CMD=(
        "$DAEMON_BIN"
        --testnet
        --offline
        --data-dir "$DATA_DIR"
        --p2p-bind-port "$P2P_PORT"
        --rpc-bind-port "$RPC_PORT"
        --zmq-rpc-bind-port "$ZMQ_PORT"
        --log-file "$DATA_DIR/xwift.log"
        --log-level 1
    )

    echo "Command: ${DAEMON_CMD[*]}"
    echo

    # Start daemon in background
    "${DAEMON_CMD[@]}" &
    DAEMON_PID=$!

    echo "✅ Daemon started with PID: $DAEMON_PID"
    echo "PID file: $DATA_DIR/xwift.pid"

    # Write PID file
    echo "$DAEMON_PID" > "$DATA_DIR/xwift.pid"
}

# Function to wait for daemon to be ready
wait_for_daemon() {
    echo "Waiting for daemon to initialize..."

    # Wait a moment for startup
    sleep 5

    # Check if process is still running
    if ! kill -0 "$DAEMON_PID" 2>/dev/null; then
        echo "❌ Daemon failed to start or crashed"
        echo "Check log file: $DATA_DIR/xwift.log"
        exit 1
    fi

    # Test RPC connectivity
    RPC_URL="http://127.0.0.1:$RPC_PORT"
    MAX_RETRIES=12  # 60 seconds max wait
    RETRY_COUNT=0

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if curl -s "$RPC_URL/json_rpc" -d '{"jsonrpc":"2.0","id":"1","method":"get_info"}' -H "Content-Type: application/json" > /dev/null 2>&1; then
            echo "✅ RPC server is responding"
            break
        fi

        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "Waiting for RPC server... ($RETRY_COUNT/$MAX_RETRIES)"
        sleep 5

        # Check if daemon is still running
        if ! kill -0 "$DAEMON_PID" 2>/dev/null; then
            echo "❌ Daemon crashed during startup"
            echo "Check log file: $DATA_DIR/xwift.log"
            exit 1
        fi
    done

    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        echo "❌ RPC server failed to respond within timeout"
        echo "Check log file: $DATA_DIR/xwift.log"
        exit 1
    fi
}

# Function to display daemon info
show_daemon_info() {
    echo
    echo "=== Xwift Daemon Information ==="
    echo "Network: Testnet"
    echo "P2P Port: $P2P_PORT"
    echo "RPC Port: $RPC_PORT"
    echo "ZMQ Port: $ZMQ_PORT"
    echo "Data Directory: $DATA_DIR"
    echo "PID: $DAEMON_PID"
    echo "RPC URL: http://127.0.0.1:$RPC_PORT"
    echo

    # Get actual daemon info
    RPC_URL="http://127.0.0.1:$RPC_PORT"
    if INFO=$(curl -s "$RPC_URL/json_rpc" -d '{"jsonrpc":"2.0","id":"1","method":"get_info"}' -H "Content-Type: application/json" 2>/dev/null); then
        echo "=== Blockchain Status ==="
        echo "$INFO" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    result = data.get('result', {})
    print(f'Height: {result.get(\"height\", \"N/A\")}')
    print(f'Top Block Hash: {result.get(\"top_block_hash\", \"N/A\")}')
    print(f'Network Type: {result.get(\"nettype\", \"N/A\")}')
    print(f'Synchronized: {result.get(\"synchronized\", \"N/A\")}')
    print(f'Difficulty: {result.get(\"difficulty\", \"N/A\")}')
    print(f'Version: {result.get(\"version\", \"N/A\")}')
except Exception as e:
    print(f'Error parsing daemon info: {e}')
"
    else
        echo "⚠️  Could not retrieve daemon information"
    fi

    echo
    echo "=== Useful Commands ==="
    echo "Stop daemon: $XWIFT_DIR/scripts/stop_xwift.sh"
    echo "View logs: tail -f $DATA_DIR/xwift.log"
    echo "Test RPC: curl -X POST $RPC_URL/json_rpc -H \"Content-Type: application/json\" -d '{\"jsonrpc\":\"2.0\",\"id\":\"1\",\"method\":\"get_info\"}'"
    echo
    echo "✅ Xwift testnet daemon is running successfully!"
}

# Main execution
main() {
    check_prerequisites
    cleanup_existing
    setup_data_dir
    check_ports
    start_daemon
    wait_for_daemon
    show_daemon_info
}

# Handle script interruption
trap 'echo -e "\n⚠️  Startup interrupted"; kill $DAEMON_PID 2>/dev/null || true; exit 1' INT TERM

# Run main function
main "$@"