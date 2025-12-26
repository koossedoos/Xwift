# Xwift Development Fund - Public Transparency Guide

## Overview

The Xwift Development Fund is configured to automatically allocate **2% of every block reward** to a development fund address for the **first year of operation** (1,051,200 blocks). This guide explains how the transparency system works and how to use the monitoring tools.

---

## 🎯 Key Features

### Automatic & Transparent
- ✅ **2% per block** - Automatically deducted from block rewards
- ✅ **1-year duration** - Terminates automatically at block 1,051,200
- ✅ **Publicly visible** - All transactions on blockchain
- ✅ **Real-time monitoring** - Multiple tools for public verification
- ✅ **Quarterly reports** - Detailed expenditure documentation

### Fund Economics (at 30-second blocks)
- **Per block:** ~0.06 XWIFT (varies with emission)
- **Per day:** ~173 XWIFT
- **Per month:** ~5,260 XWIFT
- **Year 1 total:** ~63,072 XWIFT
- **Percentage of year 1 supply:** ~2%

---

## 📊 Public Monitoring Tools Created

### 1. Command-Line Monitor
**File:** `utils/scripts/dev-fund-monitor.sh`

Real-time terminal-based monitoring with:
- Live blockchain statistics
- Fund collection status
- Progress tracking
- Transparency information

### 2. Web Dashboard
**File:** `utils/web/dev-fund-dashboard.html`

Beautiful web interface with:
- Auto-refresh every 60 seconds
- Visual progress bars
- Mobile-friendly design
- No backend required

### 3. Quarterly Report Template
**File:** `utils/templates/QUARTERLY_REPORT_TEMPLATE.md`

Comprehensive template for publishing detailed transparency reports every 3 months.

---

## 🚀 Quick Start Guide

### Step 1: Set Development Fund Address (CRITICAL)

```bash
# Generate mainnet wallet
./monero-wallet-cli --generate-wallet dev-fund-wallet

# Update src/cryptonote_config.h line 230 with your address
const char DEV_FUND_ADDRESS[] = "YOUR_ACTUAL_XWIFT_ADDRESS";

# Rebuild
make clean && make release -j$(nproc)
```

### Step 2: Deploy Web Dashboard

```bash
# Edit utils/web/dev-fund-dashboard.html
# Update lines 285-287:
const RPC_HOST = 'your-node.example.com';
const RPC_PORT = 18081;
const DEV_FUND_ADDRESS = 'YOUR_ACTUAL_ADDRESS';

# Upload to your website or GitHub Pages
```

### Step 3: Run Monitoring Script

```bash
# Make executable (already done)
chmod +x utils/scripts/dev-fund-monitor.sh

# Run anytime to check status
./utils/scripts/dev-fund-monitor.sh
```

### Step 4: Setup Quarterly Reports

```bash
# Copy template when needed
cp utils/templates/QUARTERLY_REPORT_TEMPLATE.md reports/Q1-2025.md

# Fill with actual data and publish
```

---

## 🔍 How Community Can Verify

Anyone can verify the development fund at any time:

### Method 1: Use the Web Dashboard
Visit your hosted dashboard to see real-time statistics

### Method 2: Run the Monitor Script
```bash
./utils/scripts/dev-fund-monitor.sh YOUR_DEV_FUND_ADDRESS
```

### Method 3: Check Blockchain Directly
```bash
# View any block's coinbase transaction
./monerod print_block <HEIGHT>

# You'll see:
# - Main output → Miner (98%)
# - Second output → Dev fund (2%)
```

### Method 4: Open Dev Fund Wallet
```bash
# View-only wallet access
./monero-wallet-cli --wallet-file dev-fund-wallet

# Check balance and transactions
balance
show_transfers
```

---

## 📅 Publishing Schedule

### Real-Time Monitoring
- Web dashboard updates every 60 seconds automatically
- Anyone can run CLI monitor anytime

### Quarterly Reports
- **Q1** - Due April 1
- **Q2** - Due July 1
- **Q3** - Due October 1
- **Q4** - Due January 1

Each report includes:
- Complete transaction list with hashes
- Expenditure breakdown by category
- Verification instructions
- Major achievements
- Next quarter plans

---

## 🛡️ Transparency Features

### Built-in Code Features
```cpp
// src/cryptonote_config.h
const uint64_t DEV_FUND_PERCENTAGE = 2;           // Hardcoded 2%
const uint64_t DEV_FUND_DURATION_BLOCKS = 1051200; // Hardcoded 1 year
```

### Automatic Allocation
Every mined block automatically:
1. Calculates total reward
2. Deducts 2% for dev fund
3. Sends 98% to miner
4. Sends 2% to dev fund address
5. Logs the transaction

### Automatic Termination
At block 1,051,201 the dev fund automatically stops. No manual intervention needed or possible.

---

## 📞 Tools Location Summary

All transparency tools are in the `/workspace/cmhjf7k0r00yxpsimrm8kylyb/Xwift` directory:

```
utils/
├── scripts/
│   ├── dev-fund-monitor.sh          # CLI monitoring tool
│   ├── check-nodes.sh                # Node status checker
│   └── deploy-xwift.sh               # Deployment automation
├── web/
│   └── dev-fund-dashboard.html       # Public web dashboard
└── templates/
    └── QUARTERLY_REPORT_TEMPLATE.md  # Report template
```

---

## ✅ Implementation Complete

The development fund is now fully implemented with:

✅ **Code Implementation** - Automatic 2% allocation in `cryptonote_tx_utils.cpp`
✅ **Configuration** - Dev fund settings in `cryptonote_config.h`
✅ **CLI Monitor** - Real-time terminal-based monitoring
✅ **Web Dashboard** - Beautiful public web interface
✅ **Report Template** - Comprehensive quarterly report format
✅ **Documentation** - Complete guides and instructions

**Status:** Ready for testing on testnet, then mainnet launch after setting dev fund address.

---

**For questions or support, contact the development fund manager.**
