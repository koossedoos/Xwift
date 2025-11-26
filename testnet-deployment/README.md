# Xwift Testnet Deployment Infrastructure

This directory contains the complete infrastructure for deploying and validating the Xwift testnet across multiple VPS providers.

## 📋 Overview

**Purpose:** Deploy 3+ seed nodes across different VPS providers for 30-day testnet validation  
**Duration:** Minimum 30 days continuous operation  
**Providers:** Digital Ocean, Linode, Vultr (geographic distribution)

## 📁 Directory Structure

```
testnet-deployment/
├── README.md                          # This file
├── vps-providers/                     # VPS-specific deployment scripts
│   ├── digitalocean-setup.sh         # Digital Ocean node deployment
│   ├── linode-setup.sh               # Linode node deployment
│   ├── vultr-setup.sh                # Vultr node deployment
│   └── generic-ubuntu-setup.sh       # Generic Ubuntu VPS setup
├── seed-configs/                      # Seed node configurations
│   ├── seed1-config.conf             # Seed node 1 configuration
│   ├── seed2-config.conf             # Seed node 2 configuration
│   ├── seed3-config.conf             # Seed node 3 configuration
│   └── bootstrap-nodes.txt           # Bootstrap node list
├── monitoring/                        # Monitoring and testing scripts
│   ├── collect-metrics.sh            # Automated metrics collection
│   ├── orphan-rate-tracker.sh        # Track orphan block rates
│   ├── difficulty-monitor.sh         # Monitor difficulty adjustments
│   ├── block-propagation-test.sh     # Measure block propagation
│   ├── emission-validator.py         # Validate emission schedule
│   ├── dev-fund-checker.sh           # Verify dev fund termination
│   └── dashboard-generator.sh        # Generate HTML dashboard
├── validation-plan/                   # 30-day validation plan
│   ├── daily-checklist.md            # Daily validation tasks
│   ├── week1-tests.md                # Week 1 test scenarios
│   ├── week2-tests.md                # Week 2 test scenarios
│   ├── week3-tests.md                # Week 3 test scenarios
│   ├── week4-tests.md                # Week 4 test scenarios
│   └── validation-tracker.csv        # Progress tracking spreadsheet
├── automation/                        # Automated testing orchestration
│   ├── run-all-tests.sh              # Master test orchestrator
│   ├── hashrate-variance-test.sh     # Simulate hashrate swings
│   ├── stress-test-network.sh        # Network stress testing
│   └── automated-report.sh           # Generate automated reports
├── reports/                           # Generated reports
│   └── TESTNET_VALIDATION_REPORT.md  # Final validation report template
└── deploy-testnet.sh                  # Master deployment script

```

## 🚀 Quick Start

### Prerequisites

1. **VPS Accounts** (at least 3 providers):
   - Digital Ocean account + API token
   - Linode account + API token
   - Vultr account + API token

2. **SSH Keys**:
   ```bash
   ssh-keygen -t ed25519 -C "xwift-testnet-deployment"
   ```

3. **Required Tools**:
   ```bash
   sudo apt install -y curl jq python3 python3-pip bc
   pip3 install requests pandas matplotlib
   ```

### Deploy Seed Nodes

#### Step 1: Configure VPS Credentials

```bash
cd testnet-deployment
cp .env.example .env
nano .env  # Add your API tokens
```

#### Step 2: Deploy All Seed Nodes

```bash
# Deploy all nodes automatically
./deploy-testnet.sh --auto

# Or deploy individually
./vps-providers/digitalocean-setup.sh
./vps-providers/linode-setup.sh
./vps-providers/vultr-setup.sh
```

#### Step 3: Verify Network

```bash
# Check all seed nodes
./monitoring/collect-metrics.sh --check-seeds

# View network status
./monitoring/dashboard-generator.sh
```

### Start 30-Day Validation

```bash
# Begin automated testing
./automation/run-all-tests.sh --duration 30d

# Monitor daily
./monitoring/collect-metrics.sh --daily-report
```

## 📊 Validation Tests

### 1. Orphan Rate Measurement
**Target:** <5% orphan rate  
**Script:** `monitoring/orphan-rate-tracker.sh`  
**Duration:** Continuous (30 days)

### 2. Difficulty Adjustment Stability
**Test:** 50-500% hashrate swings  
**Script:** `automation/hashrate-variance-test.sh`  
**Frequency:** Weekly

### 3. Block Propagation Timing
**Metric:** Average propagation time between seeds  
**Script:** `monitoring/block-propagation-test.sh`  
**Frequency:** Continuous

### 4. Emission Schedule Accuracy
**Test:** Verify rewards at checkpoints  
**Script:** `monitoring/emission-validator.py`  
**Frequency:** Daily validation at key heights

### 5. Dev Fund Automatic Termination
**Test:** Verify 2% allocation ends at block 1,051,200  
**Script:** `monitoring/dev-fund-checker.sh`  
**Frequency:** Pre-height, at-height, post-height validation

## 📈 Monitoring Dashboard

Access the real-time dashboard:
```bash
cd testnet-deployment
python3 -m http.server 8080
# Open: http://localhost:8080/reports/dashboard.html
```

## 🔍 Daily Checklist

- [ ] Verify all 3 seed nodes are online
- [ ] Check orphan rate (should be <5%)
- [ ] Review difficulty adjustment stability
- [ ] Measure block propagation times
- [ ] Validate emission schedule
- [ ] Monitor network hashrate
- [ ] Check for consensus issues
- [ ] Review logs for errors
- [ ] Backup metrics data

## 📝 Report Generation

### Daily Reports
```bash
./automation/automated-report.sh --daily
```

### Weekly Summary
```bash
./automation/automated-report.sh --weekly
```

### Final 30-Day Report
```bash
./automation/automated-report.sh --final > reports/TESTNET_VALIDATION_REPORT.md
```

## 🌍 Seed Node Information

### Seed 1 (Digital Ocean - NYC3)
- **IP:** To be assigned
- **Region:** New York, USA
- **Specs:** 4 vCPU, 8GB RAM, 160GB SSD
- **Config:** `seed-configs/seed1-config.conf`

### Seed 2 (Linode - EU-Central)
- **IP:** To be assigned
- **Region:** Frankfurt, Germany
- **Specs:** 4 vCPU, 8GB RAM, 160GB SSD
- **Config:** `seed-configs/seed2-config.conf`

### Seed 3 (Vultr - Asia-Pacific)
- **IP:** To be assigned
- **Region:** Singapore
- **Specs:** 4 vCPU, 8GB RAM, 160GB SSD
- **Config:** `seed-configs/seed3-config.conf`

## 🎯 Success Criteria

| Metric | Target | Status |
|--------|--------|--------|
| Uptime | >99% for all nodes | Pending |
| Orphan Rate | <5% | Pending |
| Block Time | 30s ±10% | Pending |
| Difficulty Adjustment | Stable during hashrate swings | Pending |
| Emission Accuracy | ±0.1% from expected | Pending |
| Dev Fund Termination | Exact at block 1,051,200 | Pending |
| Network Stability | No forks >10 blocks | Pending |
| Block Propagation | <5s between all seeds | Pending |

## 🔧 Troubleshooting

### Node Won't Connect
```bash
# Check firewall
sudo ufw status
sudo ufw allow 29080/tcp

# Verify seed nodes in config
cat /etc/xwift-testnet.conf | grep add-priority-node

# Restart node
sudo systemctl restart xwift-testnet
```

### High Orphan Rate
```bash
# Check network latency
./monitoring/block-propagation-test.sh --detailed

# Review peer connections
curl http://localhost:29081/get_info | jq '.outgoing_connections_count'
```

### Mining Issues
```bash
# Verify mining is active
curl http://localhost:29081/mining_status | jq

# Check mining address
grep "Mining to" /var/log/xwift-testnet/xwift.log
```

## 📞 Support

- **Documentation:** See individual script `--help` flags
- **Logs:** `/var/log/xwift-testnet/xwift.log`
- **Issues:** Check `reports/issues.log`

## 🔒 Security Notes

1. **Firewall:** Only ports 29080 (P2P) and 29081 (RPC) should be open
2. **RPC Access:** All seed nodes use `restricted-rpc=1`
3. **SSH:** Key-based authentication only (no password)
4. **Updates:** Security updates applied automatically
5. **Monitoring:** All nodes monitored 24/7

## 📅 Timeline

| Phase | Duration | Activities |
|-------|----------|------------|
| Setup | Days 1-2 | Deploy all seed nodes, verify connectivity |
| Baseline | Days 3-7 | Establish baseline metrics, initial testing |
| Stress Testing | Days 8-14 | Hashrate variance tests, load testing |
| Long-term Validation | Days 15-28 | Continuous monitoring, edge case testing |
| Final Analysis | Days 29-30 | Generate reports, readiness assessment |

## ✅ Next Steps After 30 Days

1. Review final validation report
2. Address any identified issues
3. Plan mainnet genesis parameters
4. Coordinate mainnet launch
5. Transition testnet to perpetual test environment

---

**Ready to deploy? Start with:** `./deploy-testnet.sh --auto`
