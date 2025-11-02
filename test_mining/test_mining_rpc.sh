#!/bin/bash

# Xwift Mining RPC Test Script
# Tests mining RPC functionality

set -e

DAEMON_RPC="http://127.0.0.1:19081"
MINING_ADDRESS="xwifttestaddress123456789012345678901234567890123456789012345678901234567890"

echo "Testing Xwift Mining RPC..."

# Test if daemon RPC is running
if ! curl -s "$DAEMON_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"1","method":"get_info"}' -H "Content-Type: application/json" > /dev/null; then
    echo "❌ Daemon RPC not responding on $DAEMON_RPC"
    echo "Start daemon with: ./xwift-daemon --testnet --rpc-bind-port 19081"
    exit 1
fi

echo "✅ Daemon RPC is responding"

# Test get_block_template
echo "Getting block template..."
curl -s "$DAEMON_RPC/json_rpc" -d "{\"jsonrpc\":\"2.0\",\"id\":\"2\",\"method\":\"get_block_template\",\"params\":{\"wallet_address\":\"$MINING_ADDRESS\",\"reserve_size\":8}}" -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result and 'blocktemplate_blob' in result['result']:
        print('✅ Block template retrieved successfully')
        print('   Difficulty:', result['result'].get('difficulty', 'N/A'))
        print('   Height:', result['result'].get('height', 'N/A'))
        print('   Reserved offset:', result['result'].get('reserved_offset', 'N/A'))
    else:
        print('❌ Failed to get block template:', result)
        if 'error' in result:
            print('   Error:', result['error'].get('message', 'Unknown error'))
except Exception as e:
    print('❌ Error parsing response:', e)
"

# Test mining status
echo "Checking mining status..."
curl -s "$DAEMON_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"3","method":"mining_status"}' -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result:
        active = result['result'].get('active', False)
        if active:
            print('✅ Mining is active')
            print('   Threads:', result['result'].get('threads_count', 0))
            print('   Hashrate:', result['result'].get('speed', 0), 'H/s')
        else:
            print('ℹ️  Mining is not currently active')
    else:
        print('❌ Failed to get mining status:', result)
        if 'error' in result:
            print('   Error:', result['error'].get('message', 'Unknown error'))
except Exception as e:
    print('❌ Error parsing response:', e)
"

# Test start_mining
echo "Starting mining..."
curl -s "$DAEMON_RPC/json_rpc" -d "{\"jsonrpc\":\"2.0\",\"id\":\"4\",\"method\":\"start_mining\",\"params\":{\"miner_address\":\"$MINING_ADDRESS\",\"threads_count\":2}}" -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result:
        print('✅ Mining started successfully')
    else:
        print('❌ Failed to start mining:', result)
        if 'error' in result:
            print('   Error:', result['error'].get('message', 'Unknown error'))
except Exception as e:
    print('❌ Error parsing response:', e)
"

# Wait a bit and check mining status again
sleep 5
echo "Checking updated mining status..."
curl -s "$DAEMON_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"5","method":"mining_status"}' -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result:
        active = result['result'].get('active', False)
        speed = result['result'].get('speed', 0)
        threads = result['result'].get('threads_count', 0)
        print('Mining Status:')
        print('   Active:', active)
        print('   Threads:', threads)
        print('   Hashrate:', speed, 'H/s')
        if speed > 0:
            print('✅ Mining is running and producing hashrate')
        else:
            print('ℹ️  Mining is active but no hashrate yet (normal for startup)')
    else:
        print('❌ Failed to get mining status:', result)
except Exception as e:
    print('❌ Error parsing response:', e)
"

# Test stop_mining
echo "Stopping mining..."
curl -s "$DAEMON_RPC/json_rpc" -d '{"jsonrpc":"2.0","id":"6","method":"stop_mining"}' -H "Content-Type: application/json" | python3 -c "
import sys, json
try:
    result = json.load(sys.stdin)
    if 'result' in result:
        print('✅ Mining stopped successfully')
    else:
        print('❌ Failed to stop mining:', result)
        if 'error' in result:
            print('   Error:', result['error'].get('message', 'Unknown error'))
except Exception as e:
    print('❌ Error parsing response:', e)
"

echo "✅ Mining RPC tests completed!"
