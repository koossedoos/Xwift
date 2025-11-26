# Xwift Testnet Deployment - Quick Start Guide

**🎯 Objective:** Deploy Xwift testnet with 3+ seed nodes and run 30-day validation

---

## ⚡ Quick Start (5 Minutes to Deploy)

### Step 1: Navigate to Deployment Directory

```bash
cd testnet-deployment
```

### Step 2: Configure API Tokens

```bash
cp .env.example .env
nano .env  # Add your VPS provider API tokens
```

### Step 3: Deploy All Seed Nodes

```bash
./deploy-testnet.sh --auto
```

That's it! The script will:
- ✅ Create VPS instances on 3 providers
- ✅ Install and configure Xwift testnet
- ✅ Start blockchain synchronization
- ✅ Set up monitoring

**Estimated time:** 2-3 hours (including compilation)

---

## 📊 Monitoring & Validation

### Check Status

```bash
# Check all seed nodes
./monitoring/collect-metrics.sh --check-seeds

# Generate daily report
./monitoring/collect-metrics.sh --daily-report
```

### Start 30-Day Validation

```bash
# Begin automated testing
./automation/run-all-tests.sh --duration 30
```

### View Dashboard

```bash
# Generate HTML dashboard
./monitoring/dashboard-generator.sh

# Serve locally
python3 -m http.server 8080 --directory reports/
# Open: http://localhost:8080/dashboard.html
```

---

## 🧪 Individual Tests

Run specific validation tests:

```bash
# Orphan rate (sample 1000 blocks)
./monitoring/orphan-rate-tracker.sh --sample 1000

# Difficulty monitoring (500 blocks)
./monitoring/difficulty-monitor.sh --duration 500

# Block propagation timing
./monitoring/block-propagation-test.sh --samples 100

# Emission validation
./monitoring/emission-validator.py --checkpoints 1 100 1000

# Dev fund termination check
./monitoring/dev-fund-checker.sh
```

---

## 📝 Manual VPS Setup

If you don't have API tokens, deploy manually:

```bash
# On each VPS, run:
wget https://your-repo/generic-ubuntu-setup.sh
chmod +x generic-ubuntu-setup.sh
sudo ./generic-ubuntu-setup.sh --node 1  # Use 1, 2, 3 for each node
```

---

## 📖 Documentation

- **Complete Guide:** `testnet-deployment/README.md`
- **Deployment Summary:** `TESTNET_DEPLOYMENT_SUMMARY.md`
- **Daily Checklist:** `testnet-deployment/validation-plan/daily-checklist.md`
- **Test Reports:** `testnet-deployment/reports/TESTNET_VALIDATION_REPORT.md`

---

## 🎯 Success Criteria (30-Day Validation)

| Metric | Target | Script |
|--------|--------|--------|
| Network Uptime | >99% | `collect-metrics.sh` |
| Orphan Rate | <5% | `orphan-rate-tracker.sh` |
| Block Time | 30s ±10% | `difficulty-monitor.sh` |
| Difficulty Adjustment | Stable | `hashrate-variance-test.sh` |
| Emission Accuracy | ±0.1% | `emission-validator.py` |
| Dev Fund Termination | Exact at 1,051,200 | `dev-fund-checker.sh` |
| Block Propagation | <5s avg | `block-propagation-test.sh` |
| No Consensus Issues | 0 forks >10 blocks | Continuous monitoring |

---

## 🔧 Troubleshooting

### Node Not Syncing

```bash
ssh root@<seed-ip>
systemctl status xwift-testnet
journalctl -u xwift-testnet -f
```

### View Node Metrics

```bash
ssh root@<seed-ip>
check-xwift-status
curl http://localhost:29081/get_info | jq
```

### Restart Node

```bash
ssh root@<seed-ip>
systemctl restart xwift-testnet
```

---

## 💰 Infrastructure Costs

**Per seed node (monthly):**
- Digital Ocean 4vCPU/8GB: ~$50/month
- Linode 4vCPU/8GB: ~$45/month
- Vultr 4vCPU/8GB: ~$48/month

**Total for 3 nodes:** ~$150/month  
**30-day validation:** ~$150 total

---

## ✅ Deployment Checklist

Before starting:
- [ ] VPS provider accounts created
- [ ] API tokens obtained
- [ ] SSH keys generated
- [ ] Budget approved (~$150 for 30 days)
- [ ] Team assigned for monitoring

During deployment:
- [ ] All 3 seed nodes online
- [ ] Blockchain syncing
- [ ] Monitoring scripts running
- [ ] Daily reports generated

After 30 days:
- [ ] Final report completed
- [ ] All 8 success criteria met
- [ ] Mainnet launch decision made

---

## 🚀 Ready to Deploy?

```bash
cd testnet-deployment
./deploy-testnet.sh --auto
```

**Questions?** See `testnet-deployment/README.md` for detailed documentation.

---

**Good luck with your testnet deployment! 🎉**
