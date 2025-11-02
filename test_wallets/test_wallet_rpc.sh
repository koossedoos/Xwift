#!/bin/bash

# Xwift Wallet RPC Test Script
# Tests wallet RPC functionality

set -e

WALLET_RPC="http://127.0.0.1:19083"
WALLET_FILE="test_wallet"
WALLET_PASSWORD="test123"

echo "Testing Xwift Wallet RPC..."

# Test if wallet RPC is running
if ! curl -s "$WALLET_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"1","method":"get_version"}' -H "Content-Type: application/json" > /dev/null; then
    echo "❌ Wallet RPC not responding on $WALLET_RPC"
    echo "Start wallet RPC with: ./xwift-wallet-rpc --rpc-bind-port 19083 --testnet"
    exit 1
fi

echo "✅ Wallet RPC is responding"

# Test wallet creation
echo "Creating wallet..."
curl -s "$WALLET_RPC/json_rpc" -d "{\"jsonrpc\":\"2.0\",\"id\":\"1\",\"method\":\"create_wallet\",\"params\":{\"filename\":\"$WALLET_FILE\",\"password\":\"$WALLET_PASSWORD\",\"language\":\"English\"}}" -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result:
        print('✅ Wallet created successfully')
    else:
        print('❌ Wallet creation failed:', result)
except Exception as e:
    print('❌ Error parsing response:', e)
"

# Test opening wallet
echo "Opening wallet..."
curl -s "$WALLET_RPC/json_rpc" -d "{\"jsonrpc\":\"2.0\",\"id\":\"2\",\"method\":\"open_wallet\",\"params\":{\"filename\":\"$WALLET_FILE\",\"password\":\"$WALLET_PASSWORD\"}}" -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result:
        print('✅ Wallet opened successfully')
    else:
        print('❌ Wallet opening failed:', result)
except Exception as e:
    print('❌ Error parsing response:', e)
"

# Test getting address
echo "Getting wallet address..."
curl -s "$WALLET_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"3","method":"get_address"}' -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result and 'address' in result['result']:
        print('✅ Address retrieved:', result['result']['address'])
    else:
        print('❌ Failed to get address:', result)
except Exception as e:
    print('❌ Error parsing response:', e)
"

# Test getting balance
echo "Getting wallet balance..."
curl -s "$WALLET_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"4","method":"get_balance"}' -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result:
        balance = result['result'].get('balance', 0)
        unlocked_balance = result['result'].get('unlocked_balance', 0)
        print('✅ Balance retrieved')
        print('   Total:', balance, 'atomic units')
        print('   Unlocked:', unlocked_balance, 'atomic units')
    else:
        print('❌ Failed to get balance:', result)
except Exception as e:
    print('❌ Error parsing response:', e)
"

# Test creating subaddress
echo "Creating subaddress..."
curl -s "$WALLET_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"5","method":"create_address","params":{"account_index":0,"label":"Test subaddress"}}' -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result and 'address' in result['result']:
        print('✅ Subaddress created:', result['result']['address'])
    else:
        print('❌ Failed to create subaddress:', result)
except Exception as e:
    print('❌ Error parsing response:', e)
"

echo "✅ Wallet RPC tests completed!"
