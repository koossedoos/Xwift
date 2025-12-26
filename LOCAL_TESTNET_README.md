# Xwift Local Testnet - Complete Setup Guide

## Overview

This local testnet setup allows you to validate the Xwift blockchain on your own hardware **at zero cost** using 4 Docker containers. Perfect for testing before deploying to VPS nodes.

### Hardware Requirements

- **CPU**: 6+ cores (tested on AMD Ryzen 5 7600 with 12 threads)
- **RAM**: 16GB minimum, 30GB recommended
- **Storage**: 400GB+ free space
- **OS**: Ubuntu 20.04+ or any Docker-compatible Linux distribution
- **Network**: Internet connection (for initial Docker image build only)

### What You Get

- **3 Seed Nodes** (xwift-seed-1, xwift-seed-2, xwift-seed-3)
- **1 Mining Node** (xwift-mining)
- Full blockchain validation
- Real-time monitoring dashboard
- Orphan rate tracking (<5% target)
- Difficulty adjustment validation
- Block propagation tests
- Development fund verification

---

## Quick Start

### 1. Install Docker and Docker Compose

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Log out and log back in for group changes to take effect

# Verify installation
docker --version
docker-compose --version
```

### 2. Create Testnet Wallet

Before starting the testnet, you need a wallet address to receive mining rewards:

```bash
cd /path/to/xwift/local-testnet

# Create a wallet (will be stored in ./wallet directory)
mkdir -p wallet
docker run --rm -it -v $(pwd)/wallet:/wallet local-xwift:testnet \
  xwift-wallet-cli --testnet --generate-new-wallet /wallet/miner-wallet

# Follow prompts:
# - Enter a password
# - Select language (1 for English)
# - SAVE YOUR 25-WORD SEED PHRASE!
# - Copy the wallet address (starts with "X...")
```

### 3. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env and set your wallet address
nano .env
# Set: MINER_ADDRESS=<your_wallet_address_from_step_2>
```

### 4. Start Testnet

```bash
# Start all 4 nodes
./start-testnet.sh

# This will:
# - Build Docker images (10-20 minutes first time)
# - Start all containers
# - Wait for initialization
# - Show node status
```

### 5. Monitor Nodes

```bash
# Real-time dashboard (updates every 5 seconds)
./monitoring/monitor-nodes.sh

# Quick status check
./status-testnet.sh

# View logs
./logs-testnet.sh          # All nodes
./logs-testnet.sh mining   # Mining node only
./logs-testnet.sh seed1    # Seed node 1 only
```

---

## Management Scripts

### Starting/Stopping

```bash
# Start testnet
./start-testnet.sh

# Stop testnet (preserves blockchain data)
./stop-testnet.sh

# Reset testnet (DELETES all blockchain data)
./reset-testnet.sh

# Reset and restart in one command
./reset-testnet.sh --restart
```

### Status & Logs

```bash
# Check node status
./status-testnet.sh

# Watch status (updates every 10 seconds)
./status-testnet.sh --watch

# View logs
./logs-testnet.sh [all|seed1|seed2|seed3|mining]

# Follow logs (live)
./logs-testnet.sh mining --follow
```

---

## Monitoring & Validation

### Real-Time Dashboard

```bash
# Full node dashboard (CPU, RAM, blocks, peers)
./monitoring/monitor-nodes.sh
```

### Orphan Rate Tracking

Target: <5% orphan rate

```bash
# Monitor for 60 minutes (default)
./monitoring/orphan-rate-tracker-local.sh

# Monitor for 2 hours
./monitoring/orphan-rate-tracker-local.sh 120

# Results logged to: data/orphan-rate-YYYYMMDD-HHMMSS.log
```

### Difficulty Adjustment

```bash
# Analyze last 120 blocks
./monitoring/difficulty-monitor-local.sh

# Custom window
./monitoring/difficulty-monitor-local.sh 500
```

### Block Propagation

Measures time for blocks to propagate from mining node to seed nodes.

```bash
# Test 5 blocks (default)
./monitoring/block-propagation-test.sh

# Test 20 blocks
./monitoring/block-propagation-test.sh 20
```

### Development Fund

Verify 2% dev fund allocation and termination at block 1,051,200.

```bash
./monitoring/dev-fund-checker-local.sh
```

---

## Port Mapping

| Node       | P2P Port | RPC Port | Container IP  |
|------------|----------|----------|---------------|
| Seed 1     | 29080    | 29081    | 172.25.0.10   |
| Seed 2     | 29082    | 29083    | 172.25.0.11   |
| Seed 3     | 29084    | 29085    | 172.25.0.12   |
| Mining     | 29086    | 29087    | 172.25.0.13   |

### Accessing RPC

All nodes are accessible via RPC:

```bash
# Get node info
curl http://127.0.0.1:29081/get_info | jq

# Get blockchain height
curl http://127.0.0.1:29081/get_height | jq

# JSON-RPC example
curl -X POST http://127.0.0.1:29081/json_rpc \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}'
```

---

## Resource Usage

### Per-Node Allocation

- **CPU**: 2.5 cores per seed node, 3 cores for mining node
- **RAM**: 2-3GB per node (12GB total)
- **Storage**: ~100GB per node after extended operation
- **Network**: Minimal (local bridge network)

### Total System Usage

- **CPU**: ~11 cores (leaves 1 core free on 12-thread system)
- **RAM**: ~12GB (leaves ~18GB free on 30GB system)
- **Storage**: ~400GB max (leaves 150GB free on 551GB free space)

Resource limits are enforced via Docker `mem_limit` and `cpus` directives.

---

## Data Directories

```
local-testnet/
├── data/
│   ├── seed1/         # Seed Node 1 blockchain data
│   ├── seed2/         # Seed Node 2 blockchain data
│   ├── seed3/         # Seed Node 3 blockchain data
│   └── mining/        # Mining Node blockchain data
├── configs/
│   ├── seed1-testnet.conf
│   ├── seed2-testnet.conf
│   ├── seed3-testnet.conf
│   └── mining-testnet.conf
└── wallet/            # Your testnet wallet (if created locally)
```

---

## Troubleshooting

### Nodes Won't Start

1. Check Docker is running: `docker ps`
2. Check logs: `./logs-testnet.sh`
3. Verify `.env` has `MINER_ADDRESS` set
4. Ensure ports aren't in use: `sudo netstat -tulpn | grep 290`

### Nodes Not Syncing

1. Check peer connections: `./status-testnet.sh`
2. Restart testnet: `./stop-testnet.sh && ./start-testnet.sh`
3. Check Docker network: `docker network inspect local-testnet_xwift-testnet`

### High CPU Usage

Mining uses significant CPU. Adjust `MINING_THREADS` in `.env`:

```bash
# Edit .env
MINING_THREADS=2    # Reduce from 4 to 2 threads
```

Then restart: `./stop-testnet.sh && ./start-testnet.sh`

### Out of Disk Space

1. Check usage: `du -sh data/*`
2. Prune old data: `./reset-testnet.sh` (WARNING: deletes blockchain!)
3. Free space: `docker system prune -af`

### Container Fails Healthcheck

Wait 2-3 minutes for full initialization. Check with:

```bash
docker inspect xwift-seed-1 | grep -A 10 Health
```

---

## 30-Day Validation Plan

### Week 1: Setup & Baseline

- Day 1-2: Start testnet, verify all nodes running
- Day 3-4: Run orphan rate tests (target <5%)
- Day 5-7: Monitor difficulty adjustment stability

### Week 2: Stress Testing

- Day 8-10: Adjust mining threads (2-8 threads)
- Day 11-14: Monitor orphan rate during hashrate variance

### Week 3: Long-Term Validation

- Day 15-21: Continuous operation, monitor metrics daily

### Week 4: Final Analysis

- Day 22-28: Run all validation tests
- Day 29-30: Generate comprehensive report

---

## Upgrading to VPS

When ready to deploy to VPS nodes, see [`UPGRADE_TO_VPS.md`](UPGRADE_TO_VPS.md).

Key points:
- Replace Docker container IPs with VPS public IPs
- Update `add-priority-node` in configs
- Set up firewalls and monitoring
- Use testnet data to size VPS instances

---

## Support & Documentation

- **Troubleshooting**: [`TROUBLESHOOTING_LOCAL.md`](TROUBLESHOOTING_LOCAL.md)
- **Docker Setup**: [`DOCKER_SETUP_GUIDE.md`](DOCKER_SETUP_GUIDE.md)
- **VPS Migration**: [`UPGRADE_TO_VPS.md`](UPGRADE_TO_VPS.md)
- **Validation Tests**: [`validation-tests.md`](validation-tests.md)
- **Daily Checklist**: [`daily-checklist-local.md`](daily-checklist-local.md)

---

## Cost Tracking

This setup runs at **zero marginal cost**:
- ✅ No VPS fees
- ✅ No cloud storage fees
- ✅ Powered by solar panels (user has solar)
- ✅ Free WiFi (already paid for)

See [`COST_TRACKING.md`](COST_TRACKING.md) for detailed tracking.

---

## Next Steps

1. ✅ Start testnet with `./start-testnet.sh`
2. ✅ Run monitoring dashboard: `./monitoring/monitor-nodes.sh`
3. ✅ Test orphan rate: `./monitoring/orphan-rate-tracker-local.sh`
4. ✅ Validate difficulty: `./monitoring/difficulty-monitor-local.sh`
5. ✅ Test block propagation: `./monitoring/block-propagation-test.sh`
6. ✅ Check dev fund: `./monitoring/dev-fund-checker-local.sh`
7. ✅ Follow 30-day validation plan
8. ✅ Generate final report and decide on VPS deployment

---

**Happy validating! 🚀**
