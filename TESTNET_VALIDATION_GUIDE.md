# XWIFT Testnet Validation Guide

**Purpose**: Comprehensive guide for deploying, testing, and validating XWIFT testnet before mainnet launch  
**Audience**: Core developers, validators, security auditors, and community testers  
**Status**: Pre-launch validation protocol  
**Last Updated**: 2025-01-19

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Testnet Deployment](#testnet-deployment)
3. [Node Setup for Validators](#node-setup-for-validators)
4. [Critical Testing Procedures](#critical-testing-procedures)
5. [30-Day Testnet Operation Plan](#30-day-testnet-operation-plan)
6. [Success Criteria](#success-criteria)
7. [Known Issues & Workarounds](#known-issues--workarounds)

---

## Overview

### Testnet Purpose
The XWIFT testnet is a separate blockchain network designed to:
- Validate consensus rules under real-world conditions
- Test mining difficulty adjustments with variable hashrate
- Verify emission schedule calculations
- Measure network performance and orphan rates
- Identify and fix bugs before mainnet launch
- Train validators and pool operators

### Critical Parameters to Validate
| Parameter | Expected Value | Test Method |
|-----------|---------------|-------------|
| **Block Time** | 30 seconds | Measure over 1000+ blocks |
| **Difficulty Window** | 72 blocks (36 minutes) | Monitor adjustment smoothness |
| **Maturity Window** | 60 blocks (30 minutes) | Verify coinbase unlock timing |
| **Initial Block Reward** | ~34.57 XWIFT | Calculate first 100 blocks |
| **Tail Emission** | 1.2 XWIFT/block | Verify at block 8,409,600+ |
| **Orphan Rate** | <5% target | Measure over 10,000 blocks |
| **Base Supply (8 years)** | 72.5M XWIFT | Calculate emission curve |

### Minimum Testing Duration
**30 days of continuous operation** is required to validate:
- Long-term network stability
- Difficulty adjustment across varying hashrate conditions
- Edge cases in timestamp validation
- Memory leak detection
- P2P network resilience

---

## Testnet Deployment

### Pre-Deployment Checklist

#### System Requirements
- [ ] **Operating System**: Ubuntu 20.04+ or Debian 11+
- [ ] **CPU**: 4+ cores (8+ recommended)
- [ ] **RAM**: 8 GB minimum (16 GB recommended)
- [ ] **Storage**: 100 GB SSD (fast I/O critical)
- [ ] **Network**: 100 Mbps+ with low latency
- [ ] **Open Ports**: 29080 (P2P), 29081 (RPC)

#### Build Prerequisites
```bash
# Install dependencies
sudo apt update
sudo apt install -y \
    build-essential cmake pkg-config \
    libboost-all-dev libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libunwind8-dev \
    liblzma-dev libreadline-dev libexpat1-dev \
    libgtest-dev doxygen graphviz libhidapi-dev \
    libusb-1.0-0-dev libprotobuf-dev protobuf-compiler \
    git

# Verify versions
cmake --version  # Should be 3.16+
gcc --version    # Should be 9.0+
```

### Build Testnet Binaries

```bash
# Clone repository
git clone https://github.com/xwift/xwift.git
cd xwift

# Checkout testnet branch
git checkout testnet  # Or specific release tag

# Build with testnet flag
make clean
make release-test -j$(nproc)

# Verify binaries
./build/release/bin/xwiftd --version
./build/release/bin/xwift-wallet-cli --version

# Expected output should show:
# Xwift 'Helium Hydra' (v0.18.x.x-release)
# Build: TESTNET enabled
```

### Initialize Testnet Node

```bash
# Create testnet directory
mkdir -p ~/.xwift-testnet

# Start daemon (first time)
./build/release/bin/xwiftd \
    --testnet \
    --data-dir ~/.xwift-testnet \
    --log-level 2 \
    --detach

# Verify testnet mode
./build/release/bin/xwiftd --testnet status

# Expected output:
# Height: 0 (genesis)
# Target height: 0
# Network: testnet (ID: 58574946540000000000000000000002)
# Top block hash: ...
```

### Configure Seed Nodes

Edit `~/.xwift-testnet/xwift.conf`:

```conf
# Testnet Configuration
testnet=1
data-dir=/home/user/.xwift-testnet

# Network Settings
p2p-bind-ip=0.0.0.0
p2p-bind-port=29080
rpc-bind-ip=127.0.0.1
rpc-bind-port=29081

# Seed Nodes (Update with actual testnet seeds)
add-priority-node=seed1-testnet.xwift.network:29080
add-priority-node=seed2-testnet.xwift.network:29080
add-priority-node=seed3-testnet.xwift.network:29080

# Performance
max-concurrency=4
block-sync-size=100

# Logging
log-level=1
log-file=/home/user/.xwift-testnet/xwiftd.log
```

---

## Node Setup for Validators

### Validator Hardware Requirements

**Minimum Validator Spec:**
- CPU: 4 cores @ 2.5 GHz
- RAM: 8 GB
- Storage: 100 GB SSD
- Network: 100 Mbps, <50ms latency to peers

**Recommended Validator Spec:**
- CPU: 8 cores @ 3.0 GHz
- RAM: 16 GB
- Storage: 250 GB NVMe SSD
- Network: 1 Gbps, <20ms latency to peers

### Create Validator Wallet

```bash
# Create testnet wallet
./build/release/bin/xwift-wallet-cli \
    --testnet \
    --generate-new-wallet ~/.xwift-testnet/validator.wallet

# Follow prompts:
# 1. Enter password (secure)
# 2. Confirm password
# 3. Select language (0 for English)
# 4. WRITE DOWN YOUR SEED PHRASE (25 words)

# Get your testnet address
address

# Expected format: Xwift testnet address starting with 'x' or 't'
# Example: t4BvwR...testnet address...
```

### Start Mining on Testnet

```bash
# Method 1: Daemon Mining (for testing)
./build/release/bin/xwiftd \
    --testnet \
    --start-mining YOUR_TESTNET_ADDRESS \
    --mining-threads 4

# Method 2: Via RPC (recommended for validators)
curl http://localhost:29081/json_rpc -d '{
  "jsonrpc":"2.0",
  "id":"0",
  "method":"start_mining",
  "params":{
    "miner_address":"YOUR_TESTNET_ADDRESS",
    "threads_count":4
  }
}' -H 'Content-Type: application/json'
```

### Monitor Validator Node

```bash
# Check mining status
./build/release/bin/xwiftd --testnet print_cn

# Expected output:
# Height: 12345
# Difficulty: 123456789
# Hash rate: 1.23 kH/s
# Connections: 8 out (12 in)

# Check block rewards
./build/release/bin/xwift-wallet-cli --testnet --wallet-file ~/.xwift-testnet/validator.wallet

# In wallet:
balance
show_transfers
```

---

## Critical Testing Procedures

### 1. Difficulty Adjustment Testing

**Objective**: Validate difficulty adjusts smoothly to hashrate changes

#### Test Scenario: 50-500% Hashrate Swings

```bash
# Baseline: Establish stable hashrate
# Run with 4 threads for 500 blocks
./build/release/bin/xwiftd --testnet --start-mining ADDRESS --mining-threads 4

# Monitor baseline
watch -n 30 './build/release/bin/xwiftd --testnet print_block $(./build/release/bin/xwiftd --testnet print_height)'

# After 500 blocks, record:
# - Average block time
# - Difficulty trend
# - Orphan count

# Test 1: 50% Hashrate Drop
# Stop mining, wait 72 blocks, check difficulty dropped
./build/release/bin/xwiftd --testnet stop_mining

# Monitor difficulty decrease over next 72 blocks
# Expected: Difficulty should decrease by ~40-50%

# Test 2: 200% Hashrate Spike
# Resume mining with 8 threads
./build/release/bin/xwiftd --testnet start_mining ADDRESS 8

# Monitor difficulty increase over next 72 blocks
# Expected: Difficulty should increase by ~80-100%

# Test 3: 500% Hashrate Surge
# Add multiple mining nodes (simulate pool joining)
# Expected: Difficulty should increase significantly but stay stable
```

#### Difficulty Validation Script

```bash
#!/bin/bash
# difficulty_test.sh - Monitor difficulty adjustments

DAEMON="./build/release/bin/xwiftd --testnet"
START_HEIGHT=$($DAEMON print_height)
DURATION=1000  # blocks

echo "Starting difficulty monitoring at height $START_HEIGHT"
echo "Height,Timestamp,Difficulty,BlockTime" > difficulty_log.csv

for ((i=0; i<$DURATION; i++)); do
    HEIGHT=$(($START_HEIGHT + $i))
    BLOCK_DATA=$($DAEMON print_block $HEIGHT)
    
    # Parse block data (pseudo-code, adjust to actual output)
    TIMESTAMP=$(echo "$BLOCK_DATA" | grep "timestamp" | awk '{print $2}')
    DIFFICULTY=$(echo "$BLOCK_DATA" | grep "difficulty" | awk '{print $2}')
    
    if [ $i -gt 0 ]; then
        PREV_TS=$(tail -1 difficulty_log.csv | cut -d',' -f2)
        BLOCK_TIME=$(($TIMESTAMP - $PREV_TS))
    else
        BLOCK_TIME=30
    fi
    
    echo "$HEIGHT,$TIMESTAMP,$DIFFICULTY,$BLOCK_TIME" >> difficulty_log.csv
    
    # Wait for next block
    while [ $($DAEMON print_height) -le $HEIGHT ]; do
        sleep 5
    done
done

echo "Difficulty monitoring complete. Analyze difficulty_log.csv"
```

### 2. Orphan Rate Measurement

**Objective**: Verify orphan rate <5% with 72-block difficulty window

#### Orphan Detection Script

```bash
#!/bin/bash
# orphan_tracker.sh - Measure orphan block rate

DAEMON="./build/release/bin/xwiftd --testnet"
SAMPLE_SIZE=10000
orphans=0
valid=0

echo "Tracking orphan rate over $SAMPLE_SIZE blocks..."

START_HEIGHT=$($DAEMON print_height)

for ((i=0; i<$SAMPLE_SIZE; i++)); do
    HEIGHT=$(($START_HEIGHT + $i))
    
    # Check for alternative chains
    ALT_CHAINS=$($DAEMON alt_chain_info)
    
    if echo "$ALT_CHAINS" | grep -q "height.*$HEIGHT"; then
        ((orphans++))
        echo "Orphan detected at height $HEIGHT"
    else
        ((valid++))
    fi
    
    # Wait for next block
    while [ $($DAEMON print_height) -le $HEIGHT ]; do
        sleep 10
    done
    
    # Report every 100 blocks
    if [ $((i % 100)) -eq 0 ]; then
        rate=$(echo "scale=2; $orphans * 100 / ($valid + $orphans)" | bc)
        echo "Height $HEIGHT: Orphan rate = $rate% ($orphans orphans)"
    fi
done

final_rate=$(echo "scale=2; $orphans * 100 / $SAMPLE_SIZE" | bc)
echo "Final orphan rate: $final_rate% ($orphans orphans in $SAMPLE_SIZE blocks)"

if (( $(echo "$final_rate < 5.0" | bc -l) )); then
    echo "✅ PASS: Orphan rate below 5% target"
else
    echo "❌ FAIL: Orphan rate above 5% target"
fi
```

### 3. Emission Schedule Verification

**Objective**: Verify block rewards match expected emission curve

#### Emission Validation Script

```bash
#!/bin/bash
# emission_test.sh - Verify block reward calculations

DAEMON="./build/release/bin/xwiftd --testnet"

# Test blocks at critical points
TEST_HEIGHTS=(1 100 1000 86400 525600 1051200 2102400 4204800)
EXPECTED_REWARDS=(34.5707 34.5239 34.2400 33.1754 26.9068 20.9420 12.6861 4.6553)

echo "Verifying emission schedule..."
echo "Height,Expected,Actual,Diff(%)" > emission_validation.csv

for idx in "${!TEST_HEIGHTS[@]}"; do
    HEIGHT=${TEST_HEIGHTS[$idx]}
    EXPECTED=${EXPECTED_REWARDS[$idx]}
    
    # Get block reward (parse from block data or RPC)
    BLOCK_DATA=$($DAEMON print_block $HEIGHT 2>/dev/null)
    
    if [ -z "$BLOCK_DATA" ]; then
        echo "Waiting for block $HEIGHT..."
        while [ $($DAEMON print_height) -lt $HEIGHT ]; do
            sleep 30
        done
        BLOCK_DATA=$($DAEMON print_block $HEIGHT)
    fi
    
    # Parse reward (adjust to actual output format)
    ACTUAL=$(echo "$BLOCK_DATA" | grep "reward" | awk '{print $2/100000000}')
    
    if [ -z "$ACTUAL" ]; then
        echo "❌ FAIL: Could not parse reward at height $HEIGHT"
        continue
    fi
    
    DIFF=$(echo "scale=2; ($ACTUAL - $EXPECTED) * 100 / $EXPECTED" | bc)
    echo "$HEIGHT,$EXPECTED,$ACTUAL,$DIFF" >> emission_validation.csv
    
    # Allow 0.1% tolerance
    if (( $(echo "${DIFF#-} < 0.1" | bc -l) )); then
        echo "✅ Height $HEIGHT: $ACTUAL XWIFT (expected $EXPECTED)"
    else
        echo "❌ Height $HEIGHT: $ACTUAL XWIFT (expected $EXPECTED, diff $DIFF%)"
    fi
done

echo "Emission validation complete. See emission_validation.csv"
```

#### Manual Emission Verification

```bash
# Get first 10 block rewards
for i in {1..10}; do
    echo "Block $i:"
    ./build/release/bin/xwiftd --testnet print_block $i | grep "reward"
done

# Calculate total supply at specific heights
python3 <<'EOF'
COIN = 100_000_000
MONEY_SUPPLY = 72_500_000 * COIN
EMISSION_SPEED_FACTOR_PER_MINUTE = 20
FINAL_SUBSIDY_PER_MINUTE = 240000000
TARGET = 30

def calculate_reward(already_generated):
    base_reward = (MONEY_SUPPLY - already_generated) >> EMISSION_SPEED_FACTOR_PER_MINUTE
    base_reward = base_reward * TARGET // 60
    final_subsidy = FINAL_SUBSIDY_PER_MINUTE * TARGET // 60
    return max(base_reward, final_subsidy)

already = 0
checkpoints = [1, 100, 1000, 10000, 100000, 1_000_000]
for height in checkpoints:
    for _ in range(height - len(checkpoints)):
        already += calculate_reward(already)
    reward = calculate_reward(already)
    print(f"Block {height}: Reward = {reward/COIN:.4f} XWIFT, Total supply = {already/COIN:.2f} XWIFT")
EOF
```

### 4. Timestamp Attack Resistance Testing

**Objective**: Verify 15-block timestamp validation prevents manipulation

#### Timestamp Validation Test

```bash
#!/bin/bash
# timestamp_test.sh - Verify timestamp validation

DAEMON="./build/release/bin/xwiftd --testnet"
WINDOW=15  # BLOCKCHAIN_TIMESTAMP_CHECK_WINDOW

echo "Testing timestamp attack resistance..."

# Monitor timestamp drift
echo "Height,Timestamp,Drift(s),Status" > timestamp_validation.csv

START_HEIGHT=$($DAEMON print_height)
for ((i=0; i<500; i++)); do
    HEIGHT=$(($START_HEIGHT + $i))
    
    BLOCK_DATA=$($DAEMON print_block $HEIGHT)
    TIMESTAMP=$(echo "$BLOCK_DATA" | grep "timestamp" | awk '{print $2}')
    
    # Get timestamps of previous 15 blocks
    PREV_TIMESTAMPS=()
    for ((j=1; j<=$WINDOW; j++)); do
        if [ $((HEIGHT - j)) -ge 0 ]; then
            PREV_BLOCK=$($DAEMON print_block $((HEIGHT - j)))
            PREV_TS=$(echo "$PREV_BLOCK" | grep "timestamp" | awk '{print $2}')
            PREV_TIMESTAMPS+=($PREV_TS)
        fi
    done
    
    # Calculate median of previous timestamps
    if [ ${#PREV_TIMESTAMPS[@]} -gt 0 ]; then
        SORTED=($(printf '%s\n' "${PREV_TIMESTAMPS[@]}" | sort -n))
        MID=$((${#SORTED[@]} / 2))
        MEDIAN=${SORTED[$MID]}
        DRIFT=$(($TIMESTAMP - $MEDIAN))
    else
        DRIFT=0
    fi
    
    # Check if timestamp is valid (not too far in past/future)
    if [ $DRIFT -gt -450 ] && [ $DRIFT -lt 7200 ]; then
        STATUS="VALID"
    else
        STATUS="INVALID"
        echo "⚠️  Suspicious timestamp at height $HEIGHT: drift=$DRIFT seconds"
    fi
    
    echo "$HEIGHT,$TIMESTAMP,$DRIFT,$STATUS" >> timestamp_validation.csv
    
    # Wait for next block
    while [ $($DAEMON print_height) -le $HEIGHT ]; do
        sleep 10
    done
done

echo "Timestamp validation test complete. See timestamp_validation.csv"

# Analyze results
INVALID_COUNT=$(grep "INVALID" timestamp_validation.csv | wc -l)
if [ $INVALID_COUNT -eq 0 ]; then
    echo "✅ PASS: No timestamp manipulation detected"
else
    echo "❌ FAIL: $INVALID_COUNT blocks with suspicious timestamps"
fi
```

### 5. Maturity Window Testing

**Objective**: Verify coinbase outputs mature after 60 blocks (30 minutes)

```bash
# Mine a block and track when coinbase becomes spendable
WALLET="./build/release/bin/xwift-wallet-cli --testnet --wallet-file ~/.xwift-testnet/validator.wallet"

# Get current height
HEIGHT=$($WALLET height | grep "Blockchain height" | awk '{print $3}')

# Mine 1 block
echo "Mining test block..."
./build/release/bin/xwiftd --testnet start_mining YOUR_ADDRESS 4

# Wait for block
sleep 60

# Stop mining
./build/release/bin/xwiftd --testnet stop_mining

# Get new height
NEW_HEIGHT=$($WALLET height | grep "Blockchain height" | awk '{print $3}')
MINED_HEIGHT=$NEW_HEIGHT

echo "Mined block at height $MINED_HEIGHT"
echo "Coinbase should mature at height $(($MINED_HEIGHT + 60))"

# Check balance every 5 blocks
for ((i=0; i<65; i++)); do
    CURRENT=$($WALLET height | grep "Blockchain height" | awk '{print $3}')
    BLOCKS_SINCE=$(($CURRENT - $MINED_HEIGHT))
    
    if [ $BLOCKS_SINCE -ge 60 ]; then
        UNLOCKED=$($WALLET balance | grep "unlocked" | awk '{print $3}')
        if [ ! -z "$UNLOCKED" ] && (( $(echo "$UNLOCKED > 0" | bc -l) )); then
            echo "✅ PASS: Coinbase unlocked at $BLOCKS_SINCE blocks"
            break
        fi
    else
        echo "Block $CURRENT: $BLOCKS_SINCE blocks since coinbase (need 60)"
        sleep 150  # Wait ~5 blocks
    fi
done
```

---

## 30-Day Testnet Operation Plan

### Week 1: Initial Deployment (Days 1-7)

**Goals:**
- Deploy 5+ seed nodes
- Onboard 10+ validator nodes
- Establish baseline network metrics
- Verify basic consensus

**Daily Tasks:**
- Monitor block time (target: 30±5 seconds)
- Check peer connectivity (target: 8+ peers per node)
- Measure orphan rate (target: <5%)
- Verify emission calculations

**Milestones:**
- [ ] Day 1: Genesis block mined
- [ ] Day 2: 10+ nodes connected
- [ ] Day 3: 1000+ blocks produced
- [ ] Day 5: First difficulty adjustment validated
- [ ] Day 7: 20,000+ blocks, stable network

### Week 2: Stress Testing (Days 8-14)

**Goals:**
- Simulate hashrate fluctuations
- Test network under high transaction load
- Validate difficulty adjustment edge cases
- Identify performance bottlenecks

**Tests:**
- **Day 8-9**: 50% hashrate drop test
- **Day 10-11**: 200% hashrate surge test
- **Day 12-13**: Rapid hashrate oscillation (±50% every hour)
- **Day 14**: 24-hour sustained high load

**Success Metrics:**
- Block time remains 30±10 seconds
- Orphan rate stays <5%
- No consensus splits
- Difficulty adjusts smoothly

### Week 3: Edge Case Testing (Days 15-21)

**Goals:**
- Test timestamp manipulation attempts
- Validate long reorgs (10-20 blocks)
- Test network partitions and healing
- Verify mempool behavior under stress

**Scenarios:**
- **Day 15-16**: Timestamp attack simulation
- **Day 17-18**: Network partition (split testnet into 2 groups)
- **Day 19-20**: Reorg testing (mine competing chains)
- **Day 21**: Recovery validation

**Success Metrics:**
- Timestamp validation prevents manipulation
- Network heals from partitions
- Longest chain rule works correctly
- No funds lost in reorgs

### Week 4: Final Validation (Days 22-30)

**Goals:**
- Long-term stability validation
- Performance benchmarking
- Documentation of all issues
- Prepare mainnet launch

**Activities:**
- **Days 22-25**: Continuous operation monitoring
- **Days 26-27**: Security audit review
- **Days 28-29**: Bug fixing and patch deployment
- **Day 30**: Final go/no-go decision

**Deliverables:**
- [ ] Testnet stability report
- [ ] Performance benchmarks
- [ ] Known issues list
- [ ] Mainnet readiness checklist

---

## Success Criteria

### Network Stability Metrics

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| **Block Time (average)** | 30±3 seconds | 30±10 seconds |
| **Orphan Rate** | <3% | <5% |
| **Node Uptime** | >99% | >95% |
| **Peer Connectivity** | 8-16 peers | 4+ peers |
| **Sync Speed** | <24 hours full sync | <48 hours |
| **Difficulty Adjustment** | ±20% per 72 blocks | ±50% per 72 blocks |

### Consensus Validation

- [ ] **Emission Schedule**: All block rewards match calculated values (±0.01%)
- [ ] **Difficulty Adjustment**: Smooth adjustment to 50-500% hashrate swings
- [ ] **Timestamp Validation**: No blocks with invalid timestamps accepted
- [ ] **Maturity Window**: Coinbase outputs unlock exactly at 60 blocks
- [ ] **Reorg Protection**: Deep reorgs (20+ blocks) handled correctly
- [ ] **Genesis Block**: Correct hash and parameters

### Performance Benchmarks

- [ ] **Block Propagation**: <15 seconds to 90% of network
- [ ] **Transaction Relay**: <10 seconds to 90% of network
- [ ] **Mining Efficiency**: >95% of blocks on main chain (orphan rate <5%)
- [ ] **Memory Usage**: Stable (no leaks over 30 days)
- [ ] **CPU Usage**: Reasonable (<80% average)
- [ ] **Disk I/O**: No bottlenecks in blockchain growth

### Security Validation

- [ ] **51% Attack Resistance**: Validated with simulated attacks
- [ ] **Timestamp Attacks**: Prevented by 15-block median
- [ ] **Sybil Attack Resistance**: P2P layer robust
- [ ] **Double Spend**: Prevented with 60-block maturity
- [ ] **Reorg Attacks**: Mitigated by difficulty window

### Functional Testing

- [ ] **Wallet Operations**: Create, send, receive all working
- [ ] **RPC API**: All endpoints functional
- [ ] **Mining**: Solo and pool mining both operational
- [ ] **P2P Sync**: New nodes sync within 24 hours
- [ ] **Hard Fork Activation**: Test hard fork mechanism

---

## Known Issues & Workarounds

### Issue 1: High Initial Orphan Rate

**Symptom**: Orphan rate >10% in first 500 blocks  
**Cause**: Difficulty adjustment needs time to stabilize  
**Workaround**: Expected behavior, monitor for improvement after 500 blocks  
**Resolution**: Not a bug, network needs bootstrap period

### Issue 2: Slow Initial Sync

**Symptom**: First sync takes >48 hours  
**Cause**: Large difficulty window requires processing more blocks  
**Workaround**:
```bash
# Use fast sync with checkpoints
./build/release/bin/xwiftd --testnet --fast-block-sync 1
```
**Resolution**: Optimize sync in future release

### Issue 3: Occasional Peer Disconnections

**Symptom**: Peers disconnect every few hours  
**Cause**: Timeout settings too aggressive  
**Workaround**:
```bash
# Increase connection timeout
./build/release/bin/xwiftd --testnet --p2p-timeout 300
```
**Resolution**: Tune P2P parameters

### Issue 4: High Memory Usage During Sync

**Symptom**: RAM usage >8 GB during initial sync  
**Cause**: Block processing cache  
**Workaround**:
```bash
# Limit memory usage
./build/release/bin/xwiftd --testnet --max-concurrency 2
```
**Resolution**: Optimize memory management

### Issue 5: Testnet Faucet Rate Limiting

**Symptom**: Cannot get testnet coins from faucet  
**Cause**: Rate limiting to prevent abuse  
**Workaround**:
- Mine your own testnet coins
- Ask in community Discord for manual faucet
**Resolution**: Implement IP-based rate limiting

### Emergency Contacts

**Testnet Support:**
- Discord: #testnet-support channel
- Email: testnet@xwift.network
- GitHub Issues: https://github.com/xwift/xwift/issues

**Critical Issues:**
- Security vulnerabilities: security@xwift.network
- Consensus bugs: dev@xwift.network

---

## Testnet Monitoring Dashboard

### Real-Time Metrics to Track

```bash
#!/bin/bash
# testnet_monitor.sh - Real-time testnet monitoring

DAEMON="./build/release/bin/xwiftd --testnet"

while true; do
    clear
    echo "=== XWIFT Testnet Monitor ==="
    echo "Time: $(date)"
    echo ""
    
    # Height and sync status
    HEIGHT=$($DAEMON print_height)
    echo "Height: $HEIGHT"
    
    # Network info
    $DAEMON print_cn | head -20
    
    # Difficulty
    DIFF=$($DAEMON print_block $HEIGHT | grep "difficulty")
    echo "Current Difficulty: $DIFF"
    
    # Orphan chains
    echo ""
    echo "Alternative Chains:"
    $DAEMON alt_chain_info
    
    # Mining status
    echo ""
    echo "Mining Status:"
    curl -s http://localhost:29081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json' | python3 -m json.tool | grep -E "height|difficulty|hash_rate"
    
    sleep 30
done
```

---

**Document Version**: 1.0  
**Testnet Network ID**: `58574946540000000000000000000002`  
**Testnet Genesis Block**: `013c01ff0001ffffffffffff03029b2e4c0281c0b02e7c53291a94d1d0cbff8883f8024f5142ee494ffbbd08807121017767aafcde9be00dcfd098715ebcf7f410daebc582fda69d24a28e9d0bc890d1`  
**Testnet Genesis Nonce**: 10004

---

## Next Steps After Testnet

Once all success criteria are met:
1. Review security audit findings
2. Fix any critical/high severity issues
3. Deploy final testnet patches
4. Run 7-day final validation
5. Proceed to mainnet deployment (see `DEPLOYMENT_CHECKLIST.md`)

For emergency procedures, see `EMERGENCY_FORK_GUIDE.md`.  
For consensus details, see `CONSENSUS_CHANGES_SUMMARY.md`.  
For emission details, see `EMISSION_SCHEDULE.md`.
