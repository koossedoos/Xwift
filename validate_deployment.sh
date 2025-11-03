#!/bin/bash

# Xwift Deployment Validation Script
# Comprehensive validation of Xwift blockchain deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DAEMON_RPC="http://127.0.0.1:29081"
DATA_DIR="$HOME/.xwift/testnet"
EXPECTED_GENESIS_HASH="48ca7cd3c8de5b6a4d53d2861fbdaedca141553559f9be9520068053cda8430b"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

test_daemon_connectivity() {
    print_header "DAEMON CONNECTIVITY TEST"

    echo "Testing RPC connectivity to $DAEMON_RPC..."

    if curl -s "$DAEMON_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"1","method":"get_info"}' -H "Content-Type: application/json" > /dev/null 2>&1; then
        print_success "Daemon RPC is responding"
    else
        print_error "Daemon RPC is not responding"
        echo "Please start the daemon with: ./scripts/start_xwift_testnet.sh"
        return 1
    fi
}

test_blockchain_status() {
    print_header "BLOCKCHAIN STATUS TEST"

    echo "Retrieving blockchain information..."

    INFO=$(curl -s "$DAEMON_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"1","method":"get_info"}' -H "Content-Type: application/json" 2>/dev/null)

    if [ -n "$INFO" ]; then
        # Extract key information
        HEIGHT=$(echo "$INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('result', {}).get('height', 0))" 2>/dev/null || echo "0")
        NETTYPE=$(echo "$INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('result', {}).get('nettype', 'unknown'))" 2>/dev/null || echo "unknown")
        SYNCED=$(echo "$INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('result', {}).get('synchronized', False))" 2>/dev/null || echo "False")
        OFFLINE=$(echo "$INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('result', {}).get('offline', True))" 2>/dev/null || echo "True")
        TOP_HASH=$(echo "$INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('result', {}).get('top_block_hash', ''))" 2>/dev/null || echo "")

        echo "Blockchain Information:"
        echo "  Height: $HEIGHT"
        echo "  Network Type: $NETTYPE"
        echo "  Synchronized: $SYNCED"
        echo "  Offline: $OFFLINE"
        echo "  Top Block Hash: ${TOP_HASH:0:16}..."

        # Validate key attributes
        if [ "$HEIGHT" -ge 1 ]; then
            print_success "Blockchain height is valid ($HEIGHT)"
        else
            print_error "Blockchain height is invalid ($HEIGHT)"
        fi

        if [ "$NETTYPE" = "testnet" ]; then
            print_success "Network type is testnet"
        else
            print_error "Network type is not testnet ($NETTYPE)"
        fi

        if [ "$SYNCED" = "True" ]; then
            print_success "Blockchain is synchronized"
        else
            print_error "Blockchain is not synchronized"
        fi

        if [ "$OFFLINE" = "True" ]; then
            print_success "Daemon is running in offline mode"
        else
            print_warning "Daemon is not in offline mode (may be expected)"
        fi

    else
        print_error "Failed to retrieve blockchain information"
        return 1
    fi
}

test_genesis_block() {
    print_header "GENESIS BLOCK VALIDATION"

    echo "Validating genesis block configuration..."

    # Get genesis block hash
    if [ -n "$TOP_HASH" ]; then
        if [ "$HEIGHT" -eq 1 ]; then
            # Current top block is genesis
            CURRENT_HASH="$TOP_HASH"
        else
            # Need to fetch genesis block
            CURRENT_HASH=$(curl -s "$DAEMON_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"1","method":"get_block_header_by_height","params":{"height":0}}' -H "Content-Type: application/json" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('result', {}).get('block_header', {}).get('hash', ''))" 2>/dev/null || echo "")
        fi

        if [ -n "$CURRENT_HASH" ]; then
            echo "Genesis Block Hash: $CURRENT_HASH"

            if [ "$CURRENT_HASH" = "$EXPECTED_GENESIS_HASH" ]; then
                print_success "Genesis block hash matches expected value"
            else
                print_warning "Genesis block hash differs from expected"
                echo "  Expected: $EXPECTED_GENESIS_HASH"
                echo "  Actual:   $CURRENT_HASH"
                echo "This may indicate different genesis nonce or configuration"
            fi
        else
            print_error "Failed to retrieve genesis block hash"
        fi
    else
        print_error "No blockchain data available for genesis validation"
    fi
}

test_data_directory() {
    print_header "DATA DIRECTORY VALIDATION"

    echo "Checking data directory: $DATA_DIR"

    if [ -d "$DATA_DIR" ]; then
        print_success "Data directory exists"

        # Check permissions
        if [ -r "$DATA_DIR" ] && [ -w "$DATA_DIR" ]; then
            print_success "Data directory has proper permissions"
        else
            print_warning "Data directory permissions may be insufficient"
        fi

        # Check for key files
        if [ -f "$DATA_DIR/testnet/lmdb/data.mdb" ]; then
            print_success "Blockchain database file exists"
        else
            print_warning "Blockchain database file not found"
        fi

        if [ -f "$DATA_DIR/xwift.log" ]; then
            print_success "Log file exists"
            echo "  Recent log entries:"
            tail -3 "$DATA_DIR/xwift.log" 2>/dev/null | sed 's/^/    /' || echo "    Unable to read log file"
        else
            print_warning "Log file not found"
        fi

    else
        print_error "Data directory does not exist"
    fi
}

test_network_configuration() {
    print_header "NETWORK CONFIGURATION VALIDATION"

    echo "Validating network configuration..."

    # Check port binding
    echo "Checking port usage:"

    PORTS=("29080:P2P" "29081:RPC" "29082:ZMQ")
    for port_info in "${PORTS[@]}"; do
        port=$(echo "$port_info" | cut -d':' -f1)
        name=$(echo "$port_info" | cut -d':' -f2)

        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            print_success "$name port $port is bound"
        else
            print_error "$name port $port is not bound"
        fi
    done

    # Test RPC methods
    echo "Testing RPC methods:"
    RPC_METHODS=("get_info" "get_block_count" "get_last_block_header")

    for method in "${RPC_METHODS[@]}"; do
        if curl -s "$DAEMON_RPC/json_rpc" -d "{\"jsonrpc\":\"2.0\",\"id\":\"1\",\"method\":\"$method\"}" -H "Content-Type: application/json" > /dev/null 2>&1; then
            print_success "RPC method '$method' is working"
        else
            print_error "RPC method '$method' failed"
        fi
    done
}

test_xwift_configuration() {
    print_header "XWIFT CONFIGURATION VALIDATION"

    echo "Validating Xwift-specific configuration..."

    CONFIG_FILE="src/cryptonote_config.h"

    if [ -f "$CONFIG_FILE" ]; then
        # Check key Xwift configurations
        echo "Checking configuration constants:"

        if grep -q "DIFFICULTY_TARGET_V2.*10" "$CONFIG_FILE"; then
            print_success "10-second block target configured"
        else
            print_error "10-second block target not found"
        fi

        if grep -q "MONEY_SUPPLY.*108800000000000" "$CONFIG_FILE"; then
            print_success "108.8M XFT supply configured"
        else
            print_error "XFT supply configuration incorrect"
        fi

        if grep -q "testnet.*GENESIS_NONCE.*42" "$CONFIG_FILE"; then
            print_success "Testnet genesis nonce is non-zero (42)"
        else
            print_warning "Testnet genesis nonce may be zero"
        fi

        if grep -q "testnet.*P2P_DEFAULT_PORT.*29080" "$CONFIG_FILE" && grep -q "testnet.*RPC_DEFAULT_PORT.*29081" "$CONFIG_FILE"; then
            print_success "Testnet port configuration correct"
        else
            print_error "Testnet port configuration incorrect"
        fi

    else
        print_error "Configuration file not found"
    fi
}

test_build_system() {
    print_header "BUILD SYSTEM VALIDATION"

    echo "Checking build system components..."

    if [ -f "CMakeLists.txt" ]; then
        print_success "CMakeLists.txt exists"
    else
        print_error "CMakeLists.txt not found"
    fi

    if [ -f "Makefile" ]; then
        print_success "Makefile exists"
    else
        print_error "Makefile not found"
    fi

    if [ -d "build" ] && [ -f "build/bin/xwift-daemon" ]; then
        print_success "Daemon binary exists and appears built"
    else
        print_error "Daemon binary not found or not built"
    fi

    if [ -x "scripts/start_xwift_testnet.sh" ] && [ -x "scripts/stop_xwift.sh" ]; then
        print_success "Deployment scripts exist and are executable"
    else
        print_error "Deployment scripts missing or not executable"
    fi
}

test_mining_functionality() {
    print_header "MINING FUNCTIONALITY TEST"

    echo "Testing mining RPC methods..."

    # Test get_block_template
    TEST_ADDRESS="xwifttestaddress123456789012345678901234567890123456789012345678901234567890"

    if curl -s "$DAEMON_RPC/json_rpc" -d "{\"jsonrpc\":\"2.0\",\"id\":\"1\",\"method\":\"get_block_template\",\"params\":{\"wallet_address\":\"$TEST_ADDRESS\",\"reserve_size\":8}}" -H "Content-Type: application/json" | grep -q "blocktemplate_blob"; then
        print_success "Block template generation works"
    else
        print_error "Block template generation failed"
    fi

    # Test mining status
    if curl -s "$DAEMON_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"1","method":"mining_status"}' -H "Content-Type: application/json" | grep -q "result"; then
        print_success "Mining status query works"
    else
        print_error "Mining status query failed"
    fi
}

run_comprehensive_summary() {
    print_header "DEPLOYMENT VALIDATION SUMMARY"

    TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
    SUCCESS_RATE=0

    if [ $TOTAL_TESTS -gt 0 ]; then
        SUCCESS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    fi

    echo -e "${BLUE}Validation Results:${NC}"
    echo -e "  Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  Tests Failed: ${RED}$TESTS_FAILED${NC}"
    echo -e "  Total Tests:  $TOTAL_TESTS"
    echo -e "  Success Rate: ${BLUE}$SUCCESS_RATE%${NC}"
    echo

    if [ $SUCCESS_RATE -ge 90 ]; then
        echo -e "${GREEN}🎉 EXCELLENT: Xwift deployment is highly successful!${NC}"
    elif [ $SUCCESS_RATE -ge 80 ]; then
        echo -e "${YELLOW}✅ GOOD: Xwift deployment is mostly successful${NC}"
    elif [ $SUCCESS_RATE -ge 70 ]; then
        echo -e "${YELLOW}⚠️  FAIR: Xwift deployment needs some attention${NC}"
    else
        echo -e "${RED}❌ POOR: Xwift deployment requires significant fixes${NC}"
    fi

    echo
    echo -e "${BLUE}Next Steps:${NC}"
    if [ $TESTS_FAILED -gt 0 ]; then
        echo "1. Fix the failed validation items above"
        echo "2. Re-run this validation script"
    else
        echo "1. Start testing wallet functionality"
        echo "2. Test mining operations"
        echo "3. Prepare for network connectivity testing"
    fi

    echo
    echo -e "${BLUE}Quick Commands:${NC}"
    echo "  Stop daemon: ./scripts/stop_xwift.sh"
    echo "  Restart daemon: ./scripts/start_xwift_testnet.sh"
    echo "  View logs: tail -f ~/.xwift/testnet/xwift.log"
    echo "  Test RPC: curl -X POST $DAEMON_RPC/json_rpc -H \"Content-Type: application/json\" -d '{\"jsonrpc\":\"2.0\",\"id\":\"1\",\"method\":\"get_info\"}'"
}

# Main validation execution
main() {
    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${BLUE}=== XWIFT DEPLOYMENT VALIDATION SUITE ===${NC}"
    echo -e "${BLUE}======================================================================${NC}"
    echo

    echo "This script validates your Xwift blockchain deployment."
    echo "Expected Configuration:"
    echo "  Network: Testnet"
    echo "  RPC Port: 29081"
    echo "  Data Directory: $DATA_DIR"
    echo "  Genesis Hash: $EXPECTED_GENESIS_HASH"
    echo

    # Run all validation tests
    test_daemon_connectivity
    test_blockchain_status
    test_genesis_block
    test_data_directory
    test_network_configuration
    test_xwift_configuration
    test_build_system
    test_mining_functionality

    # Show comprehensive summary
    run_comprehensive_summary

    return $TESTS_FAILED
}

# Run main function and exit with appropriate code
main "$@"