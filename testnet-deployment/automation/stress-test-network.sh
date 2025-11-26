#!/bin/bash
# Network stress test for Xwift testnet
# Simulates burst of transactions and network saturation

set -e

NODE="localhost:29081"
WALLET_CLI="xwift-wallet-cli"
WALLET_FILE="/tmp/testnet-stress-wallet"
TX_COUNT=100
TX_AMOUNT=0.01
DEST_ADDRESS=""

print_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

usage() {
    cat << EOF
Network Stress Test

Usage: $0 --dest-address XWIFT_ADDR [options]

Options:
  --node HOST:PORT     RPC endpoint (default: localhost:29081)
  --dest-address ADDR  Destination testnet address (required)
  --tx-count N         Number of transactions to send (default: 100)
  --tx-amount AMOUNT   Amount per transaction (default: 0.01)
  --help               Show this help
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --node)
            NODE="$2"
            shift 2
            ;;
        --dest-address)
            DEST_ADDRESS="$2"
            shift 2
            ;;
        --tx-count)
            TX_COUNT="$2"
            shift 2
            ;;
        --tx-amount)
            TX_AMOUNT="$2"
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

if [ -z "$DEST_ADDRESS" ]; then
    print_warning "Destination address is required"
    usage
    exit 1
fi

print_info "========================================"
print_info "Xwift Testnet Network Stress Test"
print_info "Node: $NODE"
print_info "Transactions: $TX_COUNT"
print_info "Amount per TX: $TX_AMOUNT XFT"
print_info "Destination: $DEST_ADDRESS"
print_info "========================================"

# Create temporary wallet if not exists
if [ ! -f "${WALLET_FILE}.keys" ]; then
    print_info "Creating temporary wallet..."
    yes "" | $WALLET_CLI --testnet --generate-new-wallet "$WALLET_FILE" --restore-height 0 >/dev/null 2>&1
fi

# Start wallet RPC
WALLET_RPC_PORT=29200
$WALLET_CLI --testnet --wallet-file "$WALLET_FILE" --password "" --rpc-bind-port $WALLET_RPC_PORT --detach || true
sleep 5

# Refresh wallet to ensure balance
print_info "Refreshing wallet..."
curl -s http://localhost:$WALLET_RPC_PORT/json_rpc \
    -d '{"jsonrpc":"2.0","id":"0","method":"refresh"}' -H 'Content-Type: application/json' >/dev/null

# Send transactions
for i in $(seq 1 $TX_COUNT); do
    print_info "Sending transaction $i/$TX_COUNT"
    curl -s http://localhost:$WALLET_RPC_PORT/json_rpc \
        -H 'Content-Type: application/json' \
        -d '{
            "jsonrpc":"2.0",
            "id":"0",
            "method":"transfer",
            "params":{
                "destinations":[{"amount":'$((TX_AMOUNT * 100000000))',"address":"'$DEST_ADDRESS'"}],
                "mixin":11,
                "priority":0,
                "ring_size":12,
                "account_index":0
            }
        }' >/dev/null
    sleep 1

done

print_info "Transactions submitted. Monitoring pool size..."
for i in {1..10}; do
    pool=$(curl -s http://$NODE/get_transaction_pool | jq '.txs | length')
    print_info "TX pool size: $pool"
    sleep 10
done

print_info "Stress test complete"
