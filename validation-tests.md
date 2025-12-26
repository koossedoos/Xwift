# Validation Tests - Comprehensive Test Suite

## Overview

This document describes all validation tests for the Xwift local testnet. Run these tests daily or as part of the 30-day validation plan.

---

## Test 1: Orphan Rate

**Objective:** Verify orphan rate stays below 5%

**Command:**
```bash
./monitoring/orphan-rate-tracker-local.sh 60
```

**Success Criteria:**
- Orphan rate < 5% over 60-minute period
- No sudden spikes >10%
- Consistent across all nodes

**Failure Actions:**
1. Check network latency between containers
2. Reduce mining threads to improve propagation
3. Increase CPU allocation
4. Verify Docker network is bridge mode (not NAT)

---

## Test 2: Difficulty Adjustment

**Objective:** Ensure difficulty adjusts smoothly to hashrate changes

**Command:**
```bash
./hashrate-simulator.sh 1
./monitoring/difficulty-monitor-local.sh 240
```

**Success Criteria:**
- Difficulty adjusts within 72-block window (36 minutes)
- No wild swings (>2× or <0.5× within single window)
- Volatility <30% stddev

**Failure Actions:**
1. Check if DIFFICULTY_WINDOW = 72 in cryptonote_config.h
2. Verify 30-second block time
3. Ensure mining threads are stable

---

## Test 3: Block Propagation

**Objective:** Measure time for blocks to propagate from mining node to seed nodes

**Command:**
```bash
./monitoring/block-propagation-test.sh 10
```

**Success Criteria:**
- Average propagation <2 seconds
- Max propagation <5 seconds
- All seed nodes receive blocks

**Failure Actions:**
1. Check Docker network (`docker network inspect`)
2. Verify `add-priority-node` in configs
3. Ensure seed nodes have outgoing_connections_count > 0
4. Restart containers if propagation fails

---

## Test 4: Emission Schedule

**Objective:** Validate block rewards match emission curve

**Command:**
```bash
./emission-validator-local.py --window 1000
```

**Success Criteria:**
- Average reward within 10% of expected
- No zero-reward blocks (except genesis)
- Rewards decrease gradually over time
- Tail emission (1.2 XWIFT) after block 8,409,600

**Failure Actions:**
1. Review cryptonote_core/blockchain.cpp for reward logic
2. Check EMISSION_SPEED_FACTOR_PER_MINUTE in cryptonote_config.h
3. Verify COIN = 100000000 (8 decimals, not 12)

---

## Test 5: Development Fund

**Objective:** Verify 2% dev fund allocation and termination at block 1,051,200

**Command:**
```bash
./monitoring/dev-fund-checker-local.sh
```

**Success Criteria:**
- Dev fund active before block 1,051,200
- Dev fund terminated after block 1,051,200
- Estimated collection ~60,000 XWIFT over duration

**Failure Actions:**
1. Review dev fund logic in cryptonote_core/blockchain.cpp
2. Verify DEV_FUND_CUTOFF = 1051200
3. Check dev fund address in cryptonote_config.h

---

## Test 6: Node Synchronization

**Objective:** Ensure all nodes stay in sync

**Command:**
```bash
./status-testnet.sh --watch
```

**Success Criteria:**
- All nodes show HEIGHT == TARGET
- Height difference between nodes ≤ 2 blocks
- Outgoing peer count ≥ 3 per node

**Failure Actions:**
1. Check peer connections: `./logs-testnet.sh seed1`
2. Verify `add-priority-node` in configs
3. Restart nodes: `./stop-testnet.sh && ./start-testnet.sh`

---

## Test 7: Resource Usage

**Objective:** Verify resource constraints are respected

**Command:**
```bash
docker stats --no-stream
df -h
free -h
```

**Success Criteria:**
- CPU per node ≤ 80% sustained
- RAM per node ≤ 3GB
- Storage per node <100GB after 7 days
- System has >8GB RAM free

**Failure Actions:**
1. Reduce mining threads
2. Lower CPU/RAM limits in docker-compose.yml
3. Prune Docker: `docker system prune -af`
4. Reset blockchain: `./reset-testnet.sh`

---

## Test 8: Mining Performance

**Objective:** Ensure mining node produces blocks consistently

**Command:**
```bash
./logs-testnet.sh mining --follow
# Watch for "Block found!" messages
```

**Success Criteria:**
- New block every 20-40 seconds (30s average)
- No extended gaps (>5 minutes without block)
- Mining hashrate stable

**Failure Actions:**
1. Check mining status via RPC
2. Increase mining threads
3. Verify MINER_ADDRESS in .env
4. Restart mining: `docker restart xwift-mining`

---

## Test 9: RPC Functionality

**Objective:** Verify all nodes respond to RPC queries

**Commands:**
```bash
# Test each node
for port in 29081 29083 29085 29087; do
  echo "Testing port $port..."
  curl -s http://127.0.0.1:$port/get_info | jq '.height'
done
```

**Success Criteria:**
- All nodes return valid JSON
- Height values match or differ by ≤2
- No connection errors

**Failure Actions:**
1. Check firewall: `sudo ufw status`
2. Verify RPC bind in configs
3. Check container health: `docker ps`
4. Inspect logs: `./logs-testnet.sh`

---

## Test 10: Stress Test (Hashrate Variance)

**Objective:** Test system under 50-500% hashrate swings

**Command:**
```bash
./hashrate-simulator.sh 3
# This cycles through 50%, 100%, 200%, 500% hashrate 3 times
```

**Success Criteria:**
- Difficulty adjusts within expected window
- Orphan rate stays <5% during variance
- No node crashes
- Block time averages 30s across cycles

**Failure Actions:**
1. Review difficulty-monitor logs
2. Check orphan-rate during test
3. Reduce max threads in hashrate-simulator.sh
4. Increase CPU allocation

---

## Test 11: Long-Run Stability

**Objective:** Ensure testnet runs without intervention

**Duration:** 7 days minimum

**Monitoring:**
```bash
# Set up automated monitoring
crontab -e
# Add:
# 0 */6 * * * cd /path/to/local-testnet && ./status-testnet.sh >> stability.log
```

**Success Criteria:**
- No container restarts
- Block height increases steadily
- No orphan rate spikes
- Storage growth <100GB/week

**Failure Actions:**
1. Review Docker logs for crashes
2. Check system logs: `dmesg | tail -100`
3. Monitor disk I/O: `iostat -x 5`
4. Reduce mining threads for sustainability

---

## Test 12: Recovery Test

**Objective:** Verify testnet can recover from failures

**Commands:**
```bash
# Intentionally stop all nodes
./stop-testnet.sh

# Restart
./start-testnet.sh

# Verify recovery
./status-testnet.sh
```

**Success Criteria:**
- All nodes restart successfully
- Synchronization resumes
- No blockchain corruption
- Mining resumes

**Failure Actions:**
1. Check for corrupt DB files in data/
2. Reset if needed: `./reset-testnet.sh`
3. Verify Docker health: `docker system df`

---

## Automated Test Suite

Run all tests:

```bash
./test-harness.sh
```

Quick validation (reduced samples):

```bash
./test-harness.sh --quick
```

---

## Test Schedule (30-Day Plan)

### Week 1: Setup & Baseline
- **Day 1-2**: Node health, synchronization, RPC functionality
- **Day 3-4**: Orphan rate baseline, difficulty monitoring
- **Day 5-7**: Emission validation, dev fund check, resource usage

### Week 2: Stress Testing
- **Day 8-10**: Hashrate variance simulation (3 cycles)
- **Day 11-14**: Block propagation under load, orphan rate tracking

### Week 3: Long-Run Validation
- **Day 15-21**: Continuous operation, automated monitoring

### Week 4: Final Analysis
- **Day 22-24**: Re-run all tests, compare to baseline
- **Day 25-27**: Recovery tests, edge cases
- **Day 28-30**: Generate comprehensive reports, document findings

---

## Success Summary

After 30 days, you should have:

✅ **Orphan rate:** <5% consistently  
✅ **Difficulty adjustment:** Smooth, predictable  
✅ **Block propagation:** <2s average  
✅ **Emission schedule:** Accurate to spec  
✅ **Dev fund:** Correctly allocated and terminated  
✅ **Node sync:** Tight synchronization (<2 block difference)  
✅ **Resource usage:** Within defined limits  
✅ **Mining:** Consistent block production  
✅ **RPC:** All endpoints responsive  
✅ **Stress test:** Passes 50-500% hashrate variance  
✅ **Long-run:** 7+ days uptime without intervention  
✅ **Recovery:** Clean restart after stop/start  

If all tests pass, you're ready to consider VPS deployment for mainnet.
