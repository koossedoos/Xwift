# Xwift Cryptocurrency Deployment Guide
## Complete Ubuntu Setup & Testing Instructions

**Version:** 1.0
**Date:** November 2, 2025
**Platform:** Ubuntu 20.04+ / Ubuntu 22.04+

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Repository Setup](#repository-setup)
3. [Dependencies Installation](#dependencies-installation)
4. [Building Xwift](#building-xwift)
5. [Configuration](#configuration)
6. [Testnet Deployment](#testnet-deployment)
7. [Testing & Validation](#testing--validation)
8. [Troubleshooting](#troubleshooting)

---

## 🔧 Prerequisites

### System Requirements
- **OS:** Ubuntu 20.04 LTS or newer
- **RAM:** 4GB minimum, 8GB recommended
- **Storage:** 20GB minimum, 50GB recommended
- **CPU:** 64-bit processor, 2+ cores recommended
- **Network:** Internet connection for peer discovery

### Required Software
```bash
# Basic tools
sudo apt update
sudo apt install -y git build-essential cmake pkg-config

# Version control
git --version  # Should be 2.25+
```

---

## 📥 Repository Setup

### 1. Clone the Repository
```bash
# Navigate to your development directory
cd ~
git clone https://github.com/YOUR_USERNAME/Xwift.git
cd Xwift
```

### 2. Switch to the Correct Branch
```bash
# Checkout the development branch with all changes
git checkout compyle/xwift-ecosystem-testing-deployment

# Verify you're on the correct branch
git branch
# Should show: * compyle/xwift-ecosystem-testing-deployment
```

### 3. Verify Recent Changes
```bash
# Check recent commits
git log --oneline -10

# Check for uncommitted changes (should be empty)
git status
```

---

## 📦 Dependencies Installation

### 1. Install Build Dependencies
```bash
# Install all required packages
sudo apt update
sudo apt install -y \
    build-essential cmake pkg-config \
    libboost-all-dev libssl-dev \
    libzmq3-dev libsodium-dev libunbound-dev \
    libunwind-dev liblzma-dev libreadline-dev \
    libgtest-dev libminiupnpc-dev libpcap-dev \
    libprotobuf-dev protobuf-compiler \
    libcppzmq-dev libnorm-dev

# Install additional dependencies
sudo apt install -y \
    libevent-dev libcurl4-openssl-dev \
    libhiredis-dev libjsoncpp-dev \
    libgtest-dev libbenchmark-dev
```

### 2. Install Python Dependencies (for utilities)
```bash
sudo apt install -y python3 python3-pip python3-venv
pip3 install --user requests beautifulsoup4
```

### 3. Verify Dependencies
```bash
# Check critical dependencies
pkg-config --exists libzmq && echo "✅ ZeroMQ installed"
pkg-config --exists libsodium && echo "✅ Sodium installed"
pkg-config --exists libssl && echo "✅ OpenSSL installed"
cmake --version  # Should be 3.10+
```

---

## 🏗️ Building Xwift

### 1. Create Build Directory
```bash
# Navigate to Xwift directory if not already there
cd ~/Xwift

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake .. -DCMAKE_BUILD_TYPE=Release
```

### 2. Compile the Project
```bash
# Use all available CPU cores for faster compilation
make -j$(nproc)

# Compilation will take 15-30 minutes depending on your system
```

### 3. Verify Build Success
```bash
# Check that binaries were created
ls -la bin/

# Should show these files:
# - xwift-daemon
# - xwift-wallet-cli
# - xwift-wallet-rpc
# - xwift-blockchain-export
# - xwift-blockchain-import
# - xwift-blockchain-usage

# Test the daemon version
./bin/xwift-daemon --version
```

### 4. Install System-wide (Optional)
```bash
# Install to system path (optional)
sudo make install

# Or add to PATH manually
echo 'export PATH=~/Xwift/build/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

---

## ⚙️ Configuration

### 1. Create Data Directory
```bash
# Create Xwift data directory
mkdir -p ~/.xwift/testnet
mkdir -p ~/.xwift/mainnet
```

### 2. Create Testnet Configuration
```bash
# Create testnet configuration file
cat > ~/.xwift/testnet/xwift.conf << 'EOF'
# Xwift Testnet Configuration
testnet=1
data-dir=~/.xwift/testnet
log-level=1

# Network Configuration
p2p-bind-port=19080
rpc-bind-port=19081
zmq-rpc-bind-port=19082

# RPC Configuration
restricted-rpc=1
rpc-ssl=disabled

# Mining Configuration
start-mining=1
mining-threads=4

# Performance Configuration
max-log-file-size=10485760
max-log-files=50
EOF
```

### 3. Create Mainnet Configuration (for future use)
```bash
# Create mainnet configuration file
cat > ~/.xwift/mainnet/xwift.conf << 'EOF'
# Xwift Mainnet Configuration
testnet=0
data-dir=~/.xwift/mainnet
log-level=1

# Network Configuration
p2p-bind-port=18080
rpc-bind-port=18081
zmq-rpc-bind-port=18082

# RPC Configuration
restricted-rpc=1
rpc-ssl=disabled

# Mining Configuration
start-mining=0
mining-threads=$(nproc)

# Performance Configuration
max-log-file-size=10485760
max-log-files=50
EOF
```

---

## 🚀 Testnet Deployment

### 1. Initialize Testnet Blockchain
```bash
# Navigate to Xwift build directory
cd ~/Xwift/build

# Start daemon in offline mode first
./bin/xwift-daemon \
    --testnet \
    --data-dir ~/.xwift/testnet \
    --offline \
    --rpc-bind-port 19081 \
    --p2p-bind-port 19080 \
    --zmq-rpc-bind-port 19082

# Let it run for 30 seconds to initialize, then stop with Ctrl+C
```

### 2. Create and Verify Test Wallet
```bash
# Create a new test wallet
./bin/xwift-wallet-cli \
    --testnet \
    --generate-new-wallet ~/.xwift/testnet/wallet \
    --password test123

# Note down the seed phrase and address!
# Type 'exit' to close wallet
```

### 3. Start Daemon for Network Testing
```bash
# Start daemon without offline flag for network testing
./bin/xwift-daemon \
    --testnet \
    --data-dir ~/.xwift/testnet \
    --rpc-bind-port 19081 \
    --p2p-bind-port 19080 \
    --zmq-rpc-bind-port 19082

# In a separate terminal, test RPC connectivity
curl -s http://127.0.0.1:19081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"get_info"}' \
    -H "Content-Type: application/json" | python3 -m json.tool
```

### 4. Start Wallet RPC Server
```bash
# In a third terminal, start wallet RPC
./bin/xwift-wallet-rpc \
    --testnet \
    --wallet-file ~/.xwift/testnet/wallet \
    --password test123 \
    --rpc-bind-port 19083 \
    --daemon-address 127.0.0.1:19081 \
    --allow-cors '*'

# Test wallet RPC
curl -s http://127.0.0.1:19083/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"get_address"}' \
    -H "Content-Type: application/json" | python3 -m json.tool
```

---

## 🧪 Testing & Validation

### 1. Run Comprehensive Test Suite
```bash
# Navigate to Xwift root directory
cd ~/Xwift

# Make test scripts executable
chmod +x test_*.sh

# Run all test phases
./test_phase1_genesis.sh
./test_phase2_wallet.sh
./test_phase3_mining.sh
./test_comprehensive_validation.sh
```

### 2. Manual Testing Checklist

#### Daemon Tests ✅
```bash
# Test 1: Daemon Status
curl -s http://127.0.0.1:19081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"get_info"}' | jq '.result'

# Expected: height=1, testnet=true, offline=false

# Test 2: Genesis Block Verification
curl -s http://127.0.0.1:19081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"get_block","params":{"height":0}}' | jq '.result.block.hash'

# Expected: Should match the known genesis hash
```

#### Wallet Tests ✅
```bash
# Test 1: Wallet Creation
./bin/xwift-wallet-cli --testnet --generate-new-wallet test_new

# Test 2: Balance Check
./bin/xwift-wallet-cli --testnet --wallet-file test_new --command balance

# Test 3: Address Generation
./bin/xwift-wallet-cli --testnet --wallet-file test_new --command address
```

#### Mining Tests ✅
```bash
# Test 1: Start Mining
curl -s http://127.0.0.1:19081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"start_mining","params":{"threads_count":2}}' | jq '.result'

# Test 2: Mining Status
curl -s http://127.0.0.1:19081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"mining_status"}' | jq '.result'

# Expected: active=true, threads=2
```

### 3. Network Testing
```bash
# Test 1: Peer Discovery
curl -s http://127.0.0.1:19081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"get_peer_list"}' | jq '.result'

# Test 2: Block Propagation
# (If you have multiple nodes, test synchronization between them)
```

### 4. Validation Results Expected
```
✅ Genesis block hash: 48ca7cd3c8de5b6a4d53d2861fbdaedca141553559f9be9520068053cda8430b
✅ Daemon RPC: Responding on port 19081
✅ Wallet RPC: Responding on port 19083
✅ Mining: Active with 10-second block target
✅ Consensus: Xwift rules active
✅ Currency: XFT ticker displayed
✅ Network: Testnet configuration active
```

---

## 🔍 Troubleshooting

### Common Issues & Solutions

#### 1. Build Errors
```bash
# Issue: Missing dependencies
# Solution: Install all required packages
sudo apt install -f  # Fix broken packages
sudo apt install --reinstall build-essential cmake

# Issue: Boost library not found
# Solution: Install boost development libraries
sudo apt install libboost-all-dev
```

#### 2. Runtime Errors
```bash
# Issue: Daemon won't start (port in use)
# Solution: Check for conflicting processes
netstat -tlnp | grep :19081
sudo kill -9 <PID>

# Issue: Permission denied on data directory
# Solution: Fix permissions
chmod -R 755 ~/.xwift
chown -R $USER:$USER ~/.xwift
```

#### 3. RPC Connection Issues
```bash
# Issue: RPC not responding
# Solution: Check daemon status
./bin/xwift-daemon --status

# Issue: CORS errors in browser
# Solution: Restart daemon with CORS allowed
./bin/xwift-daemon --rpc-bind-port 19081 --confirm-external-bind
```

#### 4. Wallet Issues
```bash
# Issue: Wallet file corrupted
# Solution: Restore from seed
./bin/xwift-wallet-cli --testnet --restore-from-seed

# Issue: Cannot connect to daemon
# Solution: Check daemon address
./bin/xwift-wallet-cli --testnet --daemon-address 127.0.0.1:19081
```

### Log Files
```bash
# Check daemon logs
tail -f ~/.xwift/testnet/bitmonero.log

# Check wallet logs (if using wallet RPC)
tail -f ~/.xwift/testnet/wallet.log
```

### Debug Mode
```bash
# Run daemon in debug mode
./bin/xwift-daemon --testnet --log-level 4 --data-dir ~/.xwift/testnet

# Run wallet in debug mode
./bin/xwift-wallet-cli --testnet --log-level 4
```

---

## 📊 Performance Monitoring

### System Resources
```bash
# Monitor CPU usage
htop

# Monitor memory usage
free -h

# Monitor disk usage
df -h

# Monitor network connections
netstat -an | grep :1908
```

### Xwift Metrics
```bash
# Get daemon info
curl -s http://127.0.0.1:19081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"get_info"}' | jq '.result'

# Get mining status
curl -s http://127.0.0.1:19081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"mining_status"}' | jq '.result'

# Get network info
curl -s http://127.0.0.1:19081/json_rpc \
    -d '{"jsonrpc":"2.0","id":"1","method":"get_net_stats"}' | jq '.result'
```

---

## 🔄 Maintenance

### Regular Tasks
```bash
# Backup wallet
cp ~/.xwift/testnet/wallet ~/.xwift/testnet/wallet.backup.$(date +%Y%m%d)

# Clean old logs
find ~/.xwift -name "*.log" -mtime +7 -delete

# Update system packages
sudo apt update && sudo apt upgrade

# Monitor blockchain size
du -sh ~/.xwift/testnet/
```

### Security Checklist
- ✅ Keep wallet seeds secure and backed up
- ✅ Use strong passwords for wallet encryption
- ✅ Regularly update system dependencies
- ✅ Monitor network connections
- ✅ Backup critical configuration files

---

## 📞 Support

### Getting Help
1. Check this guide first for common issues
2. Review log files for error messages
3. Check the GitHub repository for known issues
4. Use debug mode for detailed error information

### Community Resources
- GitHub Repository: https://github.com/YOUR_USERNAME/Xwift
- Documentation: Available in the `docs/` directory
- Test Scripts: All `test_*.sh` files for validation

---

## 🎯 Next Steps

After successful testnet deployment:
1. Configure multiple nodes for network testing
2. Set up mining pool (if desired)
3. Prepare for mainnet deployment
4. Write custom blockchain explorers
5. Develop additional tools and utilities

---

**Congratulations!** You now have a fully functional Xwift cryptocurrency network running on your Ubuntu system. The testnet is ready for development and testing purposes.

*This guide covers the complete deployment process from repository clone to running testnet validation.*