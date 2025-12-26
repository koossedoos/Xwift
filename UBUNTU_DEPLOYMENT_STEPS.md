# Xwift Ubuntu Deployment - Step-by-Step Guide

## Overview
This guide will walk you through deploying Xwift (with 2% development fund) on your Ubuntu PC from start to finish.

---

## ⚠️ CRITICAL: Before You Start

### Development Fund Address (MUST SET)
Before deploying mainnet, you **MUST** set your development fund address:

1. The placeholder `DEVELOPMENT_FUND_ADDRESS_TO_BE_SET` is currently in the code
2. You need to generate a wallet and update the config
3. Then rebuild before deploying mainnet

**Steps to set address are in Step 5 below**

---

## Prerequisites

- Ubuntu 20.04 or newer
- At least 8GB RAM (16GB recommended)
- 200GB+ free disk space
- Sudo/root access
- Good internet connection

---

## Step 1: Pull Latest Code from GitHub

```bash
# Go to your workspace directory
cd ~

# Clone the repository (first time)
git clone https://github.com/YOUR_GITHUB_USERNAME/Xwift.git
cd Xwift

# OR if you already have it, pull latest changes
cd ~/Xwift
git pull origin compyle/xwift-deploy-testnet-mainnet
```

**Verify you have the latest code:**
```bash
# Check for dev fund config
grep -A 3 "Development Fund Configuration" src/cryptonote_config.h

# You should see:
# // Development Fund Configuration
# const uint64_t DEV_FUND_PERCENTAGE = 2;
# const uint64_t DEV_FUND_DURATION_BLOCKS = 1051200;
# const char DEV_FUND_ADDRESS[] = "DEVELOPMENT_FUND_ADDRESS_TO_BE_SET";
```

---

## Step 2: Install Dependencies

```bash
# Update package list
sudo apt update

# Install build tools
sudo apt install -y \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    libzmq3-dev \
    libunbound-dev \
    libsodium-dev \
    libunwind8-dev \
    liblzma-dev \
    libreadline6-dev \
    libexpat1-dev \
    git \
    curl \
    autoconf \
    libtool \
    gperf \
    python3 \
    ccache \
    zlib1g-dev

# Install Boost libraries
sudo apt install -y \
    libboost-filesystem-dev \
    libboost-thread-dev \
    libboost-date-time-dev \
    libboost-chrono-dev \
    libboost-serialization-dev \
    libboost-program-options-dev

# Verify installations
cmake --version
gcc --version
```

**Expected output:**
- cmake version 3.16 or higher
- gcc version 9.0 or higher

---

## Step 3: Initialize Git Submodules

```bash
# Make sure you're in the Xwift directory
cd ~/Xwift

# Initialize and update submodules
git submodule init
git submodule update

# This will take a few minutes
# You should see it downloading various dependencies
```

---

## Step 4: Build Xwift (Testnet First)

**Build for testing (takes 20-60 minutes depending on your CPU):**

```bash
# Clean any previous builds
make clean

# Build release version
make release -j$(nproc)

# Monitor the build progress
# You'll see compilation messages scrolling by
# This is normal and will take a while
```

**What to expect:**
- Build time: 20-60 minutes depending on your CPU
- CPU usage: 100% (normal during compilation)
- Memory usage: 4-8GB (normal during compilation)

**If build succeeds, you'll see:**
```
Built target wallet_rpc_server
Built target monero-wallet-rpc
[100%] Built target all
```

**Binaries location:**
```bash
ls -lh build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/

# You should see:
# monerod           (the daemon/node)
# monero-wallet-cli (the wallet)
# monero-wallet-rpc (RPC wallet)
```

---

## Step 5: Set Development Fund Address (CRITICAL FOR MAINNET)

**For Testnet Testing:**
```bash
# Generate testnet wallet
./build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monero-wallet-cli \
    --testnet \
    --generate-wallet testnet-devfund

# When prompted:
# 1. Enter a password (remember this!)
# 2. Confirm password
# 3. Enter language: 0 (for English)

# Write down your SEED PHRASE (25 words) - CRITICAL!
# Write down your ADDRESS (starts with 'X' for testnet)

# Example address: Xw1234...abcd (testnet starts with different prefix)

# Exit wallet
# Type: exit
```

**For Mainnet (BEFORE LAUNCH):**
```bash
# Generate mainnet wallet
./build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monero-wallet-cli \
    --generate-wallet mainnet-devfund

# When prompted:
# 1. Enter a STRONG password
# 2. Confirm password
# 3. Enter language: 0 (for English)

# ⚠️ CRITICAL: Write down your SEED PHRASE (25 words)
# ⚠️ Store it in multiple secure locations (paper backup, safe)
# ⚠️ This controls ~63,000 XWIFT over 1 year!

# ⚠️ Write down your ADDRESS (starts with 'X' for Xwift mainnet)
# Example: Xw7Abc...xyz123

# Exit wallet
# Type: exit
```

**Update the code with your mainnet address:**
```bash
# Edit the config file
nano src/cryptonote_config.h

# Find line 230:
# const char DEV_FUND_ADDRESS[] = "DEVELOPMENT_FUND_ADDRESS_TO_BE_SET";

# Replace with your actual mainnet address:
# const char DEV_FUND_ADDRESS[] = "YOUR_ACTUAL_XWIFT_MAINNET_ADDRESS";

# Save and exit (Ctrl+X, then Y, then Enter)

# ⚠️ REBUILD after changing address
make clean
make release -j$(nproc)
```

---

## Step 6: Test on Testnet (HIGHLY RECOMMENDED)

**Start testnet node:**
```bash
# Create testnet data directory
mkdir -p ~/xwift-testnet-data

# Start testnet daemon
./build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monerod \
    --testnet \
    --data-dir ~/xwift-testnet-data \
    --log-file ~/xwift-testnet.log \
    --detach

# Check if it's running
./build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monerod --testnet status

# You should see:
# Height: XXX/XXX (syncing or synced)
# Difficulty: XXXXX
# Status: OK
```

**Mine some testnet blocks:**
```bash
# Open testnet wallet
./build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monero-wallet-cli \
    --testnet \
    --wallet-file testnet-devfund

# Start mining to your testnet address
start_mining 1

# Let it mine 100+ blocks (takes ~50 minutes at 30-second blocks)
# Monitor progress with: height
# After 100 blocks, stop: stop_mining
# Exit: exit
```

**Verify dev fund is working:**
```bash
# Check dev fund testnet wallet balance
./build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monero-wallet-cli \
    --testnet \
    --wallet-file testnet-devfund \
    --command balance

# You should see approximately:
# Balance: ~6 XWIFT (100 blocks × ~0.06 XWIFT per block)

# If you see funds, the dev fund is working! ✅
```

---

## Step 7: Deploy Production (Mainnet)

### Option A: Automated Deployment Script (Recommended)

```bash
# Make the deployment script executable
chmod +x utils/scripts/deploy-xwift.sh

# Run the automated deployment
sudo ./utils/scripts/deploy-xwift.sh

# This script will:
# 1. Install all dependencies
# 2. Create xwift system user
# 3. Build binaries
# 4. Install systemd services
# 5. Configure firewall
# 6. Start both testnet and mainnet nodes
```

### Option B: Manual Deployment

```bash
# 1. Create system user
sudo adduser --system --group --disabled-password xwift

# 2. Create directories
sudo mkdir -p /var/lib/xwift-{testnet,mainnet}
sudo mkdir -p /var/log/xwift-{testnet,mainnet}
sudo chown -R xwift:xwift /var/lib/xwift-* /var/log/xwift-*

# 3. Install binaries
sudo cp build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monerod /usr/local/bin/
sudo cp build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monero-wallet-cli /usr/local/bin/

# 4. Create mainnet config
sudo nano /etc/xwift-mainnet.conf
```

**Add to config file:**
```ini
data-dir=/var/lib/xwift-mainnet
log-file=/var/log/xwift-mainnet/xwift.log
log-level=0
p2p-bind-ip=0.0.0.0
p2p-bind-port=18080
rpc-bind-ip=0.0.0.0
rpc-bind-port=18081
confirm-external-bind=1
```

**Create systemd service:**
```bash
sudo nano /etc/systemd/system/xwift-mainnet.service
```

**Add to service file:**
```ini
[Unit]
Description=Xwift Mainnet Daemon
After=network-online.target

[Service]
User=xwift
Group=xwift
Type=simple
ExecStart=/usr/local/bin/monerod --config-file /etc/xwift-mainnet.conf --non-interactive
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Start the service:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable xwift-mainnet
sudo systemctl start xwift-mainnet

# Check status
sudo systemctl status xwift-mainnet

# View logs
sudo journalctl -u xwift-mainnet -f
```

---

## Step 8: Configure Firewall

```bash
# Allow SSH (if not already)
sudo ufw allow ssh

# Allow Xwift mainnet ports
sudo ufw allow 18080/tcp comment "Xwift Mainnet P2P"
sudo ufw allow 18081/tcp comment "Xwift Mainnet RPC"

# Allow Xwift testnet ports (if running testnet)
sudo ufw allow 28080/tcp comment "Xwift Testnet P2P"
sudo ufw allow 28081/tcp comment "Xwift Testnet RPC"

# Enable firewall
sudo ufw --force enable

# Check status
sudo ufw status
```

---

## Step 9: Monitor Your Node

**Check node status:**
```bash
# View mainnet status
curl -s http://localhost:18081/get_info | python3 -m json.tool

# Should show:
# {
#   "height": XXX,
#   "difficulty": XXX,
#   "target_height": XXX,
#   ...
# }
```

**Use monitoring script:**
```bash
# Make monitoring script executable
chmod +x utils/scripts/check-nodes.sh

# Run it
./utils/scripts/check-nodes.sh

# Or install it system-wide
sudo cp utils/scripts/check-nodes.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/check-nodes.sh

# Then run from anywhere
check-nodes.sh
```

**Use dev fund monitor:**
```bash
# Make it executable
chmod +x utils/scripts/dev-fund-monitor.sh

# Run it
./utils/scripts/dev-fund-monitor.sh YOUR_DEV_FUND_ADDRESS

# This shows real-time dev fund statistics
```

---

## Step 10: Setup Public Transparency Dashboard

**Host the web dashboard:**

### Option A: Simple HTTP Server (For Testing)
```bash
cd utils/web
python3 -m http.server 8080

# Access at: http://YOUR_SERVER_IP:8080/dev-fund-dashboard.html
```

### Option B: Install Web Server (Production)
```bash
# Install nginx
sudo apt install -y nginx

# Copy dashboard to web root
sudo cp utils/web/dev-fund-dashboard.html /var/www/html/transparency.html

# Edit the dashboard to set your RPC details
sudo nano /var/www/html/transparency.html

# Find these lines (around line 285):
# const RPC_HOST = 'localhost';
# const RPC_PORT = 18081;
# const DEV_FUND_ADDRESS = 'DEVELOPMENT_FUND_ADDRESS_TO_BE_SET';

# Change to:
# const RPC_HOST = 'your-domain.com';  # or your IP
# const RPC_PORT = 18081;
# const DEV_FUND_ADDRESS = 'YOUR_ACTUAL_ADDRESS';

# Allow through firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Access at: http://YOUR_SERVER_IP/transparency.html
```

---

## Step 11: Create Your First Wallet (Users)

```bash
# Create new mainnet wallet
./build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monero-wallet-cli \
    --generate-wallet my-xwift-wallet

# Or open existing wallet
./build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monero-wallet-cli \
    --wallet-file my-xwift-wallet

# Useful commands inside wallet:
# address      - Show your address
# balance      - Check balance
# transfer     - Send XWIFT
# show_transfers - View transaction history
# help         - Show all commands
# exit         - Exit wallet
```

---

## Troubleshooting

### Build Fails
```bash
# Check dependencies
dpkg -l | grep libboost
dpkg -l | grep libssl

# If missing, install:
sudo apt install -y libboost-all-dev libssl-dev

# Clean and rebuild
make clean
make release -j$(nproc)
```

### Node Won't Start
```bash
# Check logs
sudo journalctl -u xwift-mainnet -n 100

# Check if port is in use
sudo netstat -tlnp | grep 18080

# Try starting manually
/usr/local/bin/monerod --config-file /etc/xwift-mainnet.conf
```

### Can't Connect to RPC
```bash
# Check if daemon is running
sudo systemctl status xwift-mainnet

# Check if RPC port is open
curl http://localhost:18081/get_info

# Check firewall
sudo ufw status
```

### Dev Fund Not Working
```bash
# 1. Verify address is set
grep "DEV_FUND_ADDRESS" src/cryptonote_config.h

# 2. Verify you rebuilt after setting address
ls -lh build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/monerod

# 3. Check logs for dev fund messages
sudo journalctl -u xwift-mainnet | grep -i "development"

# 4. Test on testnet first!
```

---

## Quick Reference Commands

### Node Management
```bash
# Start node
sudo systemctl start xwift-mainnet

# Stop node
sudo systemctl stop xwift-mainnet

# Restart node
sudo systemctl restart xwift-mainnet

# Check status
sudo systemctl status xwift-mainnet

# View logs
sudo journalctl -u xwift-mainnet -f
```

### Wallet Commands
```bash
# Create wallet
./monerod/monero-wallet-cli --generate-wallet WALLET_NAME

# Open wallet
./monerod/monero-wallet-cli --wallet-file WALLET_NAME

# Check balance
balance

# Send XWIFT
transfer ADDRESS AMOUNT

# View history
show_transfers
```

### Monitoring
```bash
# Node status
curl http://localhost:18081/get_info | python3 -m json.tool

# Check height
curl -s http://localhost:18081/get_info | grep -o '"height":[0-9]*'

# Check connections
curl -s http://localhost:18081/get_info | grep -o '"outgoing_connections_count":[0-9]*'

# Run monitoring script
check-nodes.sh

# Run dev fund monitor
./utils/scripts/dev-fund-monitor.sh YOUR_DEV_FUND_ADDRESS
```

---

## Important Files & Locations

### Binaries
- **Daemon:** `/usr/local/bin/monerod`
- **Wallet:** `/usr/local/bin/monero-wallet-cli`

### Data Directories
- **Mainnet:** `/var/lib/xwift-mainnet/`
- **Testnet:** `/var/lib/xwift-testnet/`

### Logs
- **Mainnet:** `/var/log/xwift-mainnet/xwift.log`
- **Testnet:** `/var/log/xwift-testnet/xwift.log`
- **Systemd:** `journalctl -u xwift-mainnet`

### Configuration
- **Mainnet config:** `/etc/xwift-mainnet.conf`
- **Testnet config:** `/etc/xwift-testnet.conf`
- **Service file:** `/etc/systemd/system/xwift-mainnet.service`

### Source Code
- **Config:** `src/cryptonote_config.h`
- **Dev fund logic:** `src/cryptonote_core/cryptonote_tx_utils.cpp`

---

## Next Steps After Deployment

1. ✅ **Monitor blockchain sync** - Wait for node to fully sync
2. ✅ **Test transactions** - Send test transaction on testnet
3. ✅ **Setup monitoring** - Install monitoring dashboard
4. ✅ **Create documentation** - Document procedures for your team
5. ✅ **Announce launch** - Share transparency dashboard with community
6. ✅ **Start mining** - Begin mining or set up mining pool
7. ✅ **Publish Q1 report** - Use quarterly report template after 3 months

---

## Support & Resources

### Documentation
- **Full specs:** `XWIFT_SPECIFICATIONS.md`
- **Transparency:** `DEVELOPMENT_FUND_TRANSPARENCY.md`
- **Implementation:** `IMPLEMENTATION_SUMMARY.md`
- **Public guide:** `PUBLIC_TRANSPARENCY_GUIDE.md`

### Tools
- **Deployment script:** `utils/scripts/deploy-xwift.sh`
- **Monitoring script:** `utils/scripts/check-nodes.sh`
- **Dev fund monitor:** `utils/scripts/dev-fund-monitor.sh`
- **Web dashboard:** `utils/web/dev-fund-dashboard.html`
- **Report template:** `utils/templates/QUARTERLY_REPORT_TEMPLATE.md`

### Help
- **GitHub Issues:** https://github.com/YOUR_USERNAME/Xwift/issues
- **Documentation:** All `.md` files in repository
- **Logs:** Check system logs for errors

---

## Checklist: Ready to Launch?

Before launching mainnet, verify:

- [ ] Development fund address set in code (line 230 of cryptonote_config.h)
- [ ] Code rebuilt after setting address
- [ ] Tested on testnet for 100+ blocks
- [ ] Dev fund verified working on testnet
- [ ] Backup of dev fund wallet seed phrase (multiple secure locations)
- [ ] Binaries installed in `/usr/local/bin/`
- [ ] Systemd service configured and tested
- [ ] Firewall configured and ports open
- [ ] Monitoring tools setup and tested
- [ ] Web transparency dashboard configured
- [ ] Team knows how to check logs and monitor
- [ ] Quarterly report template reviewed
- [ ] Community announcement prepared

**Only launch mainnet after ALL checkboxes are complete!**

---

**Last Updated:** 2025-01-03
**Version:** 1.0
**Status:** Ready for deployment
