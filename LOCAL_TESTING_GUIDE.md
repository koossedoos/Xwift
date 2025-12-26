# Xwift Local Testing Guide - Step by Step

## Complete walkthrough for testing Xwift on your Ubuntu PC

---

## Prerequisites Check

First, let's verify your Ubuntu system is ready:

```bash
# Check Ubuntu version (should be 20.04 or newer)
lsb_release -a

# Check available disk space (need at least 50GB free)
df -h

# Check RAM (recommended 8GB+)
free -h

# Check CPU cores
nproc
```

---

## Step 1: Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install all required dependencies
sudo apt install -y \
    build-essential cmake pkg-config libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libunwind8-dev liblzma-dev \
    libreadline6-dev libexpat1-dev libpgm-dev qttools5-dev-tools \
    libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler \
    libudev-dev libboost-chrono-dev libboost-date-time-dev \
    libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev \
    libboost-regex-dev libboost-serialization-dev libboost-system-dev \
    libboost-thread-dev ccache doxygen graphviz git curl

# Verify Git is installed
git --version
```

**Expected output**: Should see version numbers for git (2.x.x)

---

## Step 2: Clone Xwift Repository

```bash
# Create workspace directory
mkdir -p ~/xwift-testing
cd ~/xwift-testing

# Clone the repository
git clone https://github.com/diamondsteel259/Xwift.git
cd Xwift

# Verify we're on the right branch
git branch -a
git checkout compyle/xwift-deploy-testnet-mainnet

# Check that our changes are there
grep "project(xwift)" CMakeLists.txt
```

**Expected output**: Should see `project(xwift)` on line 52

---

## Step 3: Build Xwift

This will take 15-30 minutes depending on your CPU.

```bash
# Initialize submodules
git submodule init
git submodule update

# Build release version
make release -j$(nproc)

# This will:
# - Configure with CMake
# - Compile all source files
# - Create binaries in build/release/bin/
```

**Watch for**: Compilation progress. Should complete without errors.

**If build fails**, common fixes:
```bash
# If out of memory during build:
make release -j2  # Use fewer cores

# If dependency error:
sudo apt --fix-broken install
```

---

## Step 4: Verify Binaries

```bash
# Check binaries were created
ls -lh build/release/bin/

# Test daemon version
./build/release/bin/xwiftd --version

# Test wallet version
./build/release/bin/xwift-wallet-cli --version
```

**Expected output**:
```
Xwift 'Fluorine Fermi' (v0.18.x.x-release)
```

**Key binaries you should see:**
- `xwiftd` - The daemon (node)
- `xwift-wallet-cli` - Command-line wallet
- `xwift-wallet-rpc` - RPC wallet for pools
- `xwift-blockchain-export` - Blockchain tools
- `xwift-blockchain-import` - Blockchain tools

---

## Step 5: Create Testnet Configuration

We'll test on **testnet** first (separate from mainnet).

```bash
# Create testnet data directory
mkdir -p ~/.xwift-testnet

# Create testnet config file
nano ~/.xwift-testnet/testnet.conf
```

**Paste this configuration:**
```ini
# Xwift Testnet Configuration
testnet=1
data-dir=/home/YOUR_USERNAME/.xwift-testnet
log-file=/home/YOUR_USERNAME/.xwift-testnet/xwift.log
log-level=1

# Network
p2p-bind-ip=0.0.0.0
p2p-bind-port=29080
rpc-bind-ip=127.0.0.1
rpc-bind-port=29081
zmq-rpc-bind-port=29082

# RPC access (for testing)
rpc-login=test:test123
confirm-external-bind=1

# Performance (adjust based on your PC)
max-concurrency=4
```

**Save and exit**: `Ctrl+X`, then `Y`, then `Enter`

**Important**: Replace `YOUR_USERNAME` with your actual username:
```bash
whoami  # This shows your username
sed -i "s/YOUR_USERNAME/$(whoami)/g" ~/.xwift-testnet/testnet.conf
```

---

## Step 6: Start Testnet Daemon

Open a new terminal window (keep this one running):

```bash
cd ~/xwift-testing/Xwift

# Start testnet daemon
./build/release/bin/xwiftd --config-file ~/.xwift-testnet/testnet.conf

# You should see:
# - Xwift starting up
# - Binding to ports 29080, 29081
# - Syncing blockchain
```

**Expected behavior**:
- Daemon starts successfully
- Listens on port 29080 (P2P) and 29081 (RPC)
- Begins syncing (will be quick on testnet since it's empty)

**Leave this terminal running!** Open a new terminal for next steps.

---

## Step 7: Check Daemon Status

In a **NEW terminal window**:

```bash
cd ~/xwift-testing/Xwift

# Check if daemon is responsive
curl -X POST http://127.0.0.1:29081/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' \
  -H 'Content-Type: application/json' \
  --user test:test123 | jq

# Check blockchain height
./build/release/bin/xwiftd --testnet print_height
```

**Expected output**:
```json
{
  "id": "0",
  "jsonrpc": "2.0",
  "result": {
    "height": 1,
    "target_height": 1,
    "difficulty": 1,
    ...
  }
}
```

**Note**: Height will be 1 since testnet is fresh (no blocks yet)

---

## Step 8: Create Test Wallet

Still in the **NEW terminal**:

```bash
cd ~/xwift-testing/Xwift

# Create testnet wallet
./build/release/bin/xwift-wallet-cli \
  --testnet \
  --daemon-address 127.0.0.1:29081 \
  --daemon-login test:test123 \
  --generate-new-wallet ~/test-wallet

# You'll be prompted:
# 1. Enter wallet password (choose something simple for testing, e.g., "test123")
# 2. Confirm password
# 3. Language selection (enter "1" for English)

# Wallet will display:
# - Your 25-word seed phrase (WRITE IT DOWN!)
# - Your testnet address (starts with "X...")
```

**IMPORTANT**: Save your seed phrase somewhere. You'll need the address for mining.

**In the wallet prompt**, type:
```
address
```

Copy your address (starts with X...). You'll need it for mining.

**Exit wallet for now**:
```
exit
```

---

## Step 9: Start Mining on Testnet

Now let's mine some blocks to test everything!

```bash
cd ~/xwift-testing/Xwift

# Start mining to your wallet address
./build/release/bin/xwiftd \
  --testnet \
  --start-mining YOUR_WALLET_ADDRESS \
  --mining-threads 2 \
  --daemon-address 127.0.0.1:29081 \
  --daemon-login test:test123
```

**Replace `YOUR_WALLET_ADDRESS`** with the address from step 8.

**Alternative**: If daemon is already running, use RPC to start mining:

```bash
curl -X POST http://127.0.0.1:29081/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"start_mining","params":{"miner_address":"YOUR_WALLET_ADDRESS","threads_count":2}}' \
  -H 'Content-Type: application/json' \
  --user test:test123
```

**What to expect**:
- Mining will start
- Blocks will be mined (30 seconds per block)
- You'll see "Block found!" messages

**Monitor mining** in daemon terminal:
```bash
# Watch for:
# - "Block added to chain"
# - "Development fund allocated" (every block!)
# - Milestone messages (every 1000 blocks)
```

---

## Step 10: Verify Features While Mining

While mining is running, **open another terminal** and verify our improvements:

### Test 1: Check Project Branding
```bash
./build/release/bin/xwiftd --version
# Should say "Xwift" not "Monero"
```

### Test 2: Check Ports
```bash
sudo netstat -tlnp | grep xwiftd
# Should show:
# - 29080 (P2P)
# - 29081 (RPC)
# - 29082 (ZMQ)
```

### Test 3: Check Dev Fund Logging
```bash
tail -f ~/.xwift-testnet/xwift.log | grep -i "dev fund"
# Should see messages like:
# "Dev fund allocated: 1080000000 atomic units (10.80 XFT) at height X"
```

### Test 4: Check Milestone Logging
```bash
# After 1000 blocks mined, you'll see:
grep "MILESTONE" ~/.xwift-testnet/xwift.log
```

### Test 5: Check Network Configuration
```bash
grep "CRYPTONOTE_NAME" src/cryptonote_config.h
# Should show: "xwift"

grep "P2P_DEFAULT_PORT = 29080" src/cryptonote_config.h
# Should show testnet port 29080
```

---

## Step 11: Test Wallet Operations

After mining at least 20 blocks (to unlock first block):

```bash
# Open wallet
./build/release/bin/xwift-wallet-cli \
  --testnet \
  --wallet-file ~/test-wallet \
  --daemon-address 127.0.0.1:29081 \
  --daemon-login test:test123

# Enter wallet password

# Inside wallet, check balance:
balance

# You should see unlocked balance (from mining)!
```

**Expected**: Balance showing XFT from mined blocks

### Test sending (to yourself):
```
# Get your address
address

# Send to yourself (test transaction)
transfer YOUR_ADDRESS 1

# Check if transaction was created
show_transfers

# Exit wallet
exit
```

---

## Step 12: Test Wallet RPC (For Pool Testing)

Stop the mining and daemon (Ctrl+C in daemon terminal).

Now test wallet RPC:

```bash
# Start wallet RPC
./build/release/bin/xwift-wallet-rpc \
  --testnet \
  --wallet-file ~/test-wallet \
  --password "test123" \
  --rpc-bind-port 29082 \
  --rpc-login wallet:wallet123 \
  --daemon-address 127.0.0.1:29081 \
  --daemon-login test:test123 \
  --trusted-daemon

# Leave running in this terminal
```

In **another terminal**, test RPC:

```bash
# Get address via RPC
curl -X POST http://127.0.0.1:29082/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_address"}' \
  -H 'Content-Type: application/json' \
  --user wallet:wallet123 | jq

# Get balance via RPC
curl -X POST http://127.0.0.1:29082/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_balance"}' \
  -H 'Content-Type: application/json' \
  --user wallet:wallet123 | jq
```

**Expected**: Should return your address and balance via RPC

---

## Step 13: Test XMRig Mining (External Miner)

Let's test with a real mining client:

```bash
# Download XMRig
cd ~/xwift-testing
wget https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-linux-x64.tar.gz
tar xf xmrig-6.21.0-linux-x64.tar.gz
cd xmrig-6.21.0

# Mine to your wallet
./xmrig \
  -o 127.0.0.1:29080 \
  -u YOUR_WALLET_ADDRESS \
  -p x \
  --coin monero \
  -k

# Note: We use --coin monero because XMRig doesn't have Xwift preset,
# but RandomX algorithm is the same
```

**Expected**:
- Connection established
- Mining starts
- Shares submitted
- Blocks found

---

## Step 14: Verify All Production Changes

Run this comprehensive check:

```bash
cd ~/xwift-testing/Xwift

# Create verification script
cat > verify_changes.sh << 'EOF'
#!/bin/bash
echo "=== Xwift Production Changes Verification ==="
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
echo "4. P2P Optimization:"
grep "P2P_DEFAULT_CONNECTIONS_COUNT.*16" src/cryptonote_config.h && echo "   ✅ PASS" || echo "   ❌ FAIL"

echo ""
echo "5. Sync Optimization:"
grep "BLOCKS_SYNCHRONIZING_DEFAULT_COUNT.*200" src/cryptonote_config.h && echo "   ✅ PASS" || echo "   ❌ FAIL"

echo ""
echo "6. Cryptonote Name:"
grep 'CRYPTONOTE_NAME.*"xwift"' src/cryptonote_config.h && echo "   ✅ PASS" || echo "   ❌ FAIL"

echo ""
echo "7. Dev Fund Logging:"
grep "Dev fund allocated" src/cryptonote_core/cryptonote_tx_utils.cpp && echo "   ✅ PASS" || echo "   ❌ FAIL"

echo ""
echo "8. Milestone Logging:"
grep "MILESTONE" src/cryptonote_core/blockchain.cpp && echo "   ✅ PASS" || echo "   ❌ FAIL"

echo ""
echo "9. Seed Node Config (Mainnet):"
grep "add-priority-node" utils/conf/xwift-mainnet.conf && echo "   ✅ PASS" || echo "   ❌ FAIL"

echo ""
echo "10. Seed Node Config (Testnet):"
grep "add-priority-node" utils/conf/xwift-testnet.conf && echo "   ✅ PASS" || echo "   ❌ FAIL"

echo ""
echo "=== Verification Complete ==="
EOF

chmod +x verify_changes.sh
./verify_changes.sh
```

**Expected**: All 10 checks should show ✅ PASS

---

## Step 15: Mine 1000+ Blocks (Dev Fund Test)

Let's verify the development fund works correctly:

```bash
# Restart daemon (if stopped)
cd ~/xwift-testing/Xwift
./build/release/bin/xwiftd --config-file ~/.xwift-testnet/testnet.conf

# Start mining with more threads for faster mining
curl -X POST http://127.0.0.1:29081/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"start_mining","params":{"miner_address":"YOUR_WALLET_ADDRESS","threads_count":4}}' \
  -H 'Content-Type: application/json' \
  --user test:test123

# Monitor progress
watch -n 30 'curl -s -X POST http://127.0.0.1:29081/json_rpc -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"get_info\"}" -H "Content-Type: application/json" --user test:test123 | jq ".result.height"'
```

**While mining, check logs**:
```bash
# Watch dev fund allocation
tail -f ~/.xwift-testnet/xwift.log | grep "Dev fund"

# Every block should show:
# "Dev fund allocated: XXXXXX atomic units (X.XX XFT) at height X (Y.YY% through dev fund period, Z blocks remaining)"
```

**At block 1000**:
```bash
# Check for milestone message
grep "MILESTONE: Block 1000" ~/.xwift-testnet/xwift.log

# Should show:
# === MILESTONE: Block 1000 ===
# Difficulty: XXXXX
# Estimated Network Hashrate: XXX H/s
# Block Reward: X.XX XFT
```

---

## Step 16: Test Multiple Wallets

Test that different wallets work:

```bash
# Create second wallet
./build/release/bin/xwift-wallet-cli \
  --testnet \
  --daemon-address 127.0.0.1:29081 \
  --daemon-login test:test123 \
  --generate-new-wallet ~/test-wallet-2

# Note the address

# Open first wallet and send to second wallet
./build/release/bin/xwift-wallet-cli \
  --testnet \
  --wallet-file ~/test-wallet \
  --daemon-address 127.0.0.1:29081 \
  --daemon-login test:test123

# Inside wallet:
transfer ADDRESS_OF_WALLET_2 10

# Wait for confirmation (next block)

# Check second wallet received it
./build/release/bin/xwift-wallet-cli \
  --testnet \
  --wallet-file ~/test-wallet-2 \
  --daemon-address 127.0.0.1:29081 \
  --daemon-login test:test123

# Check balance
balance
```

---

## Step 17: Test Documentation Files

Verify all documentation was created:

```bash
cd ~/xwift-testing/Xwift

# Check documentation files exist
ls -lh *.md

# Should see:
# - PRODUCTION_CHANGES.md
# - MINING_POOL_SETUP.md
# - EMERGENCY_FORK_GUIDE.md
# - QUICK_ANSWERS.md
# - LOCAL_TESTING_GUIDE.md

# Read the summary
cat PRODUCTION_CHANGES.md
```

---

## Step 18: Performance Benchmarks

Test sync and mining performance:

```bash
# Test sync speed (with 1000 blocks)
# Stop daemon, delete blockchain, restart and measure sync time
systemctl stop xwift-testnet  # if using systemd
rm -rf ~/.xwift-testnet/testnet
time ./build/release/bin/xwiftd --testnet --data-dir ~/.xwift-testnet

# Test mining hashrate
./build/release/bin/xwiftd --testnet print_cn
# Note connections and status

# Check block time accuracy
# Get last 100 blocks and check if average is ~30 seconds
curl -s -X POST http://127.0.0.1:29081/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' \
  -H 'Content-Type: application/json' \
  --user test:test123 | jq
```

---

## Step 19: Cleanup Test Environment

When you're done testing:

```bash
# Stop mining
curl -X POST http://127.0.0.1:29081/json_rpc \
  -d '{"jsonrpc":"2.0","id":"0","method":"stop_mining"}' \
  -H 'Content-Type: application/json' \
  --user test:test123

# Stop daemon (Ctrl+C in daemon terminal)

# Optional: Clean up testnet data to start fresh
rm -rf ~/.xwift-testnet

# Keep your wallet files backed up if you want to preserve them
cp ~/test-wallet* ~/wallet-backups/
```

---

## Step 20: Test Results Checklist

After completing all steps, verify:

- [ ] Xwift compiles successfully
- [ ] Daemon starts without errors
- [ ] Testnet ports work (29080/29081/29082)
- [ ] Wallet creation works
- [ ] Mining produces blocks
- [ ] Dev fund logging shows on every block
- [ ] Milestone logging shows at block 1000
- [ ] Wallet CLI works (send/receive)
- [ ] Wallet RPC works (API calls succeed)
- [ ] External miner (XMRig) connects successfully
- [ ] Multiple wallets can transact
- [ ] Block time averages ~30 seconds
- [ ] All documentation files exist

**If ALL boxes checked**: ✅ Ready for mainnet preparation!

---

## What's Next After Testing?

### For Production Mainnet Launch:

1. **Set Dev Fund Address** (CRITICAL)
   ```bash
   # Generate secure mainnet wallet (NOT testnet!)
   ./xwift-wallet-cli --generate-new-wallet ~/dev-fund-mainnet
   # SAVE SEED PHRASE OFFLINE!

   # Update config
   nano src/cryptonote_config.h
   # Line 230: Change DEV_FUND_ADDRESS to your address

   # Rebuild
   make clean && make release
   ```

2. **Get VPS Servers** (3-5 seed nodes)
   - Recommend: DigitalOcean, Vultr, or Hetzner
   - 4GB RAM minimum per node
   - Different geographic locations

3. **Deploy Seed Nodes**
   - Install Xwift on each VPS
   - Configure with unique IPs
   - Add to config files

4. **Optional: Setup Mining Pool**
   - Follow `MINING_POOL_SETUP.md`
   - Deploy on VPS
   - Test on testnet first

5. **Launch Mainnet**
   - Coordinate launch time
   - Start all seed nodes simultaneously
   - Announce to community
   - Monitor closely for first 48 hours

---

## Troubleshooting

### Issue: Build fails with "out of memory"
```bash
# Use fewer cores
make release -j2
```

### Issue: Can't connect to daemon
```bash
# Check if running
ps aux | grep xwiftd

# Check ports
sudo netstat -tlnp | grep 29081

# Check logs
tail -f ~/.xwift-testnet/xwift.log
```

### Issue: Wallet won't sync
```bash
# Make sure daemon is fully synced first
./build/release/bin/xwiftd --testnet print_height

# Restart wallet with correct daemon address
```

### Issue: Mining doesn't start
```bash
# Check wallet address is valid
# Check mining command syntax
# Check daemon is responsive
# Try with fewer threads
```

---

## Support

If you encounter issues during testing:

1. Check logs: `tail -f ~/.xwift-testnet/xwift.log`
2. Verify daemon status: `./xwiftd --testnet status`
3. Check all services are running
4. Review error messages carefully

**After successful testing, you're ready for production deployment!**

---

**Document Version**: 1.0
**Last Updated**: 2025-11-04
**Status**: Ready for local testing
