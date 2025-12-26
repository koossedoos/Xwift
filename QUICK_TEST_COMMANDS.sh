#!/bin/bash
# Xwift Quick Testing Commands
# Copy and paste these commands one by one

echo "=== XWIFT LOCAL TESTING - QUICK COMMANDS ==="
echo ""
echo "Follow these commands step by step."
echo "Press Enter after reading each section to continue..."
read

# ============================================================
echo "STEP 1: INSTALL DEPENDENCIES"
echo "============================================================"
cat << 'EOF'
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    build-essential cmake pkg-config libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libunwind8-dev liblzma-dev \
    libreadline6-dev libexpat1-dev libpgm-dev qttools5-dev-tools \
    libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler \
    libudev-dev libboost-chrono-dev libboost-date-time-dev \
    libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev \
    libboost-regex-dev libboost-serialization-dev libboost-system-dev \
    libboost-thread-dev ccache doxygen graphviz git curl jq
EOF
read

# ============================================================
echo ""
echo "STEP 2: CLONE REPOSITORY"
echo "============================================================"
cat << 'EOF'
mkdir -p ~/xwift-testing
cd ~/xwift-testing
git clone https://github.com/diamondsteel259/Xwift.git
cd Xwift
git checkout compyle/xwift-deploy-testnet-mainnet
git submodule init
git submodule update
EOF
read

# ============================================================
echo ""
echo "STEP 3: BUILD XWIFT (15-30 minutes)"
echo "============================================================"
cat << 'EOF'
cd ~/xwift-testing/Xwift
make release -j$(nproc)
EOF
read

# ============================================================
echo ""
echo "STEP 4: VERIFY BUILD"
echo "============================================================"
cat << 'EOF'
ls -lh build/release/bin/
./build/release/bin/xwiftd --version
./build/release/bin/xwift-wallet-cli --version
EOF
read

# ============================================================
echo ""
echo "STEP 5: CREATE TESTNET CONFIG"
echo "============================================================"
cat << 'EOF'
mkdir -p ~/.xwift-testnet

cat > ~/.xwift-testnet/testnet.conf << 'CONF'
testnet=1
data-dir=$HOME/.xwift-testnet
log-file=$HOME/.xwift-testnet/xwift.log
log-level=1
p2p-bind-ip=0.0.0.0
p2p-bind-port=29080
rpc-bind-ip=127.0.0.1
rpc-bind-port=29081
zmq-rpc-bind-port=29082
rpc-login=test:test123
confirm-external-bind=1
max-concurrency=4
CONF
EOF
read

# ============================================================
echo ""
echo "STEP 6: START DAEMON (Terminal 1)"
echo "============================================================"
echo "Open a NEW terminal and run:"
cat << 'EOF'
cd ~/xwift-testing/Xwift
./build/release/bin/xwiftd --config-file ~/.xwift-testnet/testnet.conf
EOF
echo ""
echo "Leave that terminal running! Continue here after daemon starts."
read

# ============================================================
echo ""
echo "STEP 7: CHECK DAEMON STATUS (Terminal 2)"
echo "============================================================"
cat << 'EOF'
curl -X POST http://127.0.0.1:29081/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' \
  -H 'Content-Type: application/json' \
  --user test:test123 | jq
EOF
read

# ============================================================
echo ""
echo "STEP 8: CREATE WALLET"
echo "============================================================"
cat << 'EOF'
cd ~/xwift-testing/Xwift
./build/release/bin/xwift-wallet-cli \
  --testnet \
  --daemon-address 127.0.0.1:29081 \
  --daemon-login test:test123 \
  --generate-new-wallet ~/test-wallet

# When prompted:
# - Password: test123
# - Confirm: test123
# - Language: 1 (English)
# SAVE YOUR SEED PHRASE!
# In wallet, type: address
# Copy your address
# Then type: exit
EOF
read

# ============================================================
echo ""
echo "STEP 9: START MINING"
echo "============================================================"
echo "Replace YOUR_WALLET_ADDRESS with the address from step 8"
cat << 'EOF'
curl -X POST http://127.0.0.1:29081/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"start_mining","params":{"miner_address":"YOUR_WALLET_ADDRESS","threads_count":2}}' \
  -H 'Content-Type: application/json' \
  --user test:test123
EOF
read

# ============================================================
echo ""
echo "STEP 10: MONITOR MINING"
echo "============================================================"
cat << 'EOF'
# Watch blockchain height increase
watch -n 10 'curl -s -X POST http://127.0.0.1:29081/json_rpc -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"get_info\"}" -H "Content-Type: application/json" --user test:test123 | jq ".result.height"'

# In another terminal, watch logs
tail -f ~/.xwift-testnet/xwift.log | grep -E "Block|Dev fund|MILESTONE"
EOF
read

# ============================================================
echo ""
echo "STEP 11: CHECK WALLET BALANCE (After 20+ blocks)"
echo "============================================================"
cat << 'EOF'
cd ~/xwift-testing/Xwift
./build/release/bin/xwift-wallet-cli \
  --testnet \
  --wallet-file ~/test-wallet \
  --daemon-address 127.0.0.1:29081 \
  --daemon-login test:test123

# Password: test123
# In wallet: balance
# In wallet: exit
EOF
read

# ============================================================
echo ""
echo "STEP 12: RUN VERIFICATION SCRIPT"
echo "============================================================"
cat << 'EOF'
cd ~/xwift-testing/Xwift

cat > verify.sh << 'VERIFY'
#!/bin/bash
echo "=== Xwift Verification ==="
echo ""
echo "1. Project Branding:"
grep "project(xwift)" CMakeLists.txt && echo "   ✅ PASS" || echo "   ❌ FAIL"
echo ""
echo "2. Mainnet Ports:"
grep "P2P_DEFAULT_PORT = 19080" src/cryptonote_config.h && echo "   ✅ PASS" || echo "   ❌ FAIL"
echo ""
echo "3. Testnet Ports:"
grep "P2P_DEFAULT_PORT = 29080" src/cryptonote_config.h && echo "   ✅ PASS" || echo "   ❌ FAIL"
echo ""
echo "4. Cryptonote Name:"
grep 'CRYPTONOTE_NAME.*"xwift"' src/cryptonote_config.h && echo "   ✅ PASS" || echo "   ❌ FAIL"
echo ""
echo "5. Dev Fund Logging:"
grep "Dev fund allocated" src/cryptonote_core/cryptonote_tx_utils.cpp && echo "   ✅ PASS" || echo "   ❌ FAIL"
echo ""
echo "=== Verification Complete ==="
VERIFY

chmod +x verify.sh
./verify.sh
EOF
read

# ============================================================
echo ""
echo "STEP 13: STOP MINING (When Done Testing)"
echo "============================================================"
cat << 'EOF'
curl -X POST http://127.0.0.1:29081/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"stop_mining"}' \
  -H 'Content-Type: application/json' \
  --user test:test123

# Then stop daemon with Ctrl+C in Terminal 1
EOF
read

# ============================================================
echo ""
echo "============================================================"
echo "TESTING COMPLETE!"
echo "============================================================"
echo ""
echo "If all steps worked, you've successfully tested:"
echo "✅ Building Xwift"
echo "✅ Running testnet daemon"
echo "✅ Creating wallets"
echo "✅ Mining blocks"
echo "✅ Dev fund logging"
echo "✅ All production improvements"
echo ""
echo "Next steps:"
echo "1. Review LOCAL_TESTING_GUIDE.md for detailed explanations"
echo "2. Set up VPS servers for mainnet seed nodes"
echo "3. Configure dev fund address for mainnet"
echo "4. Optional: Set up mining pool (see MINING_POOL_SETUP.md)"
echo ""
echo "Good luck with your launch! 🚀"
