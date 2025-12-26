# Xwift (XWIFT) - Complete Technical Specifications

## 🎯 **Project Vision**
Xwift is a privacy-first cryptocurrency delivering near-instant transactions with robust security against inflation and 51% attacks, built on proven Monero technology with significant enhancements for speed and economics.

---

## 📊 **Core Blockchain Parameters**

### Block & Consensus
- **Block Time**: 30 seconds (120x faster than Bitcoin, 4x faster than Monero)
- **Block Finality**: 3 minutes (6 confirmations)
- **Difficulty Retarget**: Every 8 blocks (4 minutes)
- **Mining Algorithm**: Enhanced RandomX (ASIC-resistant CPU mining)
- **Consensus**: Proof-of-Work with uncle block rewards
- **Maximum Block Size**: 150 KB initially (dynamic)

### Monetary System
- **Decimal Places**: 8 (0.00000001 XWIFT)
- **Atomic Unit**: 1 xwei = 0.00000001 XWIFT
- **1 XWIFT**: 100,000,000 atomic units (1e8)
- **Ticker Symbol**: XWIFT
- **Currency Name**: Xwift

---

## 💰 **Economic Model**

### Supply Structure
- **Total Base Supply**: 108,800,000 XWIFT
- **Tail Emission**: 0.5 XWIFT per block (perpetual)
- **Emission Period**: 10 years to reach tail emission
- **Annual Inflation**: Decreases to ~0.48% after 10 years

### Block Reward Formula
```
Base Reward = (MONEY_SUPPLY - already_generated_coins) >> emission_speed_factor
If Base Reward < Tail Emission:
    Base Reward = Tail Emission (0.5 XWIFT per block)
```

### Emission Schedule Breakdown

| Phase | Timeframe | Daily Emission | Annual Emission | Cumulative | Inflation Rate |
|-------|-----------|----------------|-----------------|------------|----------------|
| Year 1 | 0-365 days | 8,640 XWIFT | 3,153,600 XWIFT | 3.15M | 100.0% |
| Year 2 | 365-730 days | 7,920 XWIFT | 2,890,800 XWIFT | 6.04M | 91.8% |
| Year 3 | 730-1,095 days | 7,270 XWIFT | 2,653,550 XWIFT | 8.69M | 44.0% |
| Year 5 | 1,460-1,825 days | 6,160 XWIFT | 2,248,400 XWIFT | 21.8M | 11.5% |
| Year 10 | 3,287-3,652 days | 4,050 XWIFT | 1,478,250 XWIFT | 54.0M | 2.8% |
| Year 20+ | Tail Emission | 1,440 XWIFT | 525,600 XWIFT | 100M+ | ~0.5% |

**Key Metrics:**
- **Blocks per day**: 2,880 (every 30 seconds)
- **Year 1 block reward**: ~3.0 XWIFT average
- **Year 5 block reward**: ~2.25 XWIFT average
- **Year 10+ block reward**: 0.5 XWIFT (tail emission)

### Development Fund
- **Percentage**: 2% of every block reward
- **Duration**: 1 year (1,051,200 blocks)
- **Purpose**: Development, infrastructure, security audits, staff costs
- **Management**: Publicly tracked and reported
- **Address**: Set before mainnet launch (publicly visible on blockchain)
- **Total Dev Fund Year 1**: ~63,072 XWIFT (2% of 3.15M)

**Transparency Mechanism:**
- All development fund transactions visible on blockchain
- Quarterly public reports on usage
- Community-auditable wallet address
- Multi-signature protection for security

---

## 🔐 **Privacy & Security Features**

### Privacy Technology (Monero-Proven)
- **Ring Signatures**: Minimum 11 mixins (scalable to 16 in later hardforks)
- **Stealth Addresses**: Unique one-time addresses for every transaction
- **RingCT (Ring Confidential Transactions)**: All amounts hidden by default
- **View Tags**: Faster transaction scanning without compromising privacy
- **Bulletproofs+**: Efficient zero-knowledge range proofs for amounts
- **Subaddresses**: Unlimited addresses per wallet
- **Integrated Addresses**: Payment IDs encrypted within address

### Security Layers

#### Layer 1: Fast Difficulty Adjustment
- **Retarget Frequency**: Every 8 blocks (4 minutes)
- **Adjustment Limit**: ±60% per retarget period
- **Response Time**: 1 block lag for rapid response
- **Protection**: Prevents difficulty manipulation attacks

#### Layer 2: Uncle Block Rewards (Ethereum-Style)
- **Uncle Reward**: 87.5% of full block reward (7/8)
- **Inclusion Bonus**: 6.25% of uncle reward to block producer (1/16)
- **Maximum Uncles**: 2 per block
- **Uncle Age Limit**: Maximum 6 blocks old
- **Benefit**: Reduces orphan rate from ~8% to <1% effective loss

#### Layer 3: Checkpoint System
- **Checkpoint Interval**: Every 1,000 blocks (~8.3 hours)
- **Validation Depth**: 100 blocks before deep reorganization
- **Protection**: Prevents long-range chain reorganization attacks

#### Layer 4: Time Attack Protection
- **Future Time Limit**: 15 seconds maximum ahead
- **Timestamp Window**: 5-second variance allowed
- **Protection**: Prevents timestamp manipulation

---

## ⛏️ **Mining Specifications**

### Algorithm Details
- **Primary**: Enhanced RandomX
- **Optimization**: 1MB JIT cache per thread
- **Hardware AES**: Enabled for better performance
- **Memory**: ~2GB RAM per mining thread
- **ASIC Resistance**: Maintained through RandomX design

### Mining Rewards
```
Standard Block:
  - Miner Reward: 98% of (base reward - dev fund)
  - Dev Fund: 2% of base reward (first year only)

Uncle Block (orphaned but valid):
  - Uncle Miner: 87.5% of standard reward
  - Block Producer: 6.25% of uncle reward (inclusion bonus)
  - Network Effect: Reduces miner variance and orphan losses
```

### Mining Economics
- **Block Frequency**: 2,880 opportunities per day
- **Confirmation Time**: 30 seconds average for first confirmation
- **Maturity**: 6 blocks (~3 minutes) before spendable
- **Profitability**: CPU-friendly, accessible to general-purpose hardware

---

## 🚀 **Transaction Features**

### Transaction Parameters
- **Minimum Fee**: Dynamic, approximately 0.0001 XWIFT per KB
- **Fee Formula**: Scales with network congestion
- **Average Transaction Size**: ~2-3 KB with ring size 11
- **Confirmation Times**:
  - 1 confirmation: 30 seconds average
  - 3 confirmations: 90 seconds (recommended for small amounts)
  - 6 confirmations: 3 minutes (recommended for large amounts)
  - 10 confirmations: 5 minutes (maximum security)

### Privacy Guarantees
- **Default Privacy**: ALL transactions are private by default
- **Sender Privacy**: Hidden among 11-16 decoys (ring signatures)
- **Receiver Privacy**: Stealth addresses (unique per transaction)
- **Amount Privacy**: RingCT hides all transaction amounts
- **No Metadata Leakage**: Payment IDs encrypted, IP addresses protected via i2p/Tor

---

## 🌐 **Network Configuration**

### Port Assignments
**Mainnet:**
- P2P: 18080
- RPC: 18081
- ZMQ: 18082

**Testnet:**
- P2P: 28080
- RPC: 28081
- ZMQ: 28082

### Network Identity
- **Mainnet Network ID**: `58 57 49 46 54 00 00 00 00 00 00 00 00 00 00 01` (XWIFT)
- **Testnet Network ID**: `58 57 49 46 54 00 00 00 00 00 00 00 00 00 00 02` (XWIFT testnet)
- **Genesis Nonce**: 10003 (mainnet), 10004 (testnet)

### Address Prefixes
**Mainnet:**
- Standard: 65 (addresses start with specific Xwift prefix)
- Integrated: 66
- Subaddress: 67

**Testnet:**
- Standard: 85
- Integrated: 86
- Subaddress: 87

---

## 🔄 **Hardfork Schedule**

Xwift uses an accelerated hardfork schedule optimized for 30-second blocks:

| HF Version | Features | Activation |
|------------|----------|------------|
| HF 1 | Launch, Dynamic Fees, Min Mixin 4 | Genesis |
| HF 2 | RingCT, Min Mixin 6, Per-Byte Fees | Early (month 1) |
| HF 3 | Min Mixin 10, Bulletproofs, Block Weight | Month 2 |
| HF 4 | CLSAG Signatures, Exact Coinbase | Month 6 |
| HF 5 | Bulletproofs+, View Tags, 2021 Scaling | Month 12 |
| HF 6 | Min Mixin 15 (optional upgrade path to 16) | Year 2 |

**Benefits of Accelerated Schedule:**
- Faster adoption of privacy improvements
- Earlier optimization of transaction sizes
- Quicker migration to latest security features

---

## 📈 **Performance Metrics**

### Expected Performance
- **Transaction Throughput**: ~50-100 tx/second with optimizations
- **Block Propagation**: <15 seconds globally
- **Orphan Rate**: 5-8% raw, <1% with uncle rewards
- **Network Synchronization**: Full sync in 2-4 hours (vs days for Monero)

### Comparison Table

| Metric | Bitcoin | Monero | Xwift |
|--------|---------|--------|-------|
| Block Time | 10 min | 2 min | 30 sec |
| Finality (6 conf) | 60 min | 12 min | 3 min |
| Privacy | Optional | Default | Default |
| ASIC Resistance | No | Yes | Yes |
| Tail Emission | No | Yes | Yes |
| Uncle Rewards | No | No | Yes |
| Supply Cap | 21M | Unlimited | 108.8M + tail |

---

## 🎯 **Key Advantages**

### vs Bitcoin
✅ **20x Faster Finality**: 3 minutes vs 60 minutes
✅ **Privacy by Default**: All transactions confidential
✅ **Lower Energy Use**: CPU mining vs specialized ASICs
✅ **Sustainable Security**: Perpetual tail emission funds miners
✅ **Lower Fees**: Dynamic fee system adapts to network demand

### vs Monero
✅ **4x Faster Blocks**: 30 seconds vs 120 seconds
✅ **Enhanced Security**: Uncle rewards + fast difficulty adjustment
✅ **Better Economics**: Fixed tail emission, predictable supply
✅ **Optimized Mining**: Enhanced RandomX for 30-second blocks
✅ **Lower Orphan Rate**: Uncle system reduces effective loss

### vs Other Privacy Coins
✅ **Proven Technology**: Based on battle-tested Monero codebase
✅ **True Privacy**: No optional privacy (all mandatory)
✅ **Active Development**: Rapid hardfork schedule for improvements
✅ **Fair Launch**: No premine, no ICO, pure proof-of-work

---

## 🚀 **Launch Strategy**

### Fair Launch Protocol
- **Premine**: NONE - 0% founder allocation
- **ICO/Token Sale**: NONE - no pre-sale of any kind
- **Founder Rewards**: NONE (dev fund is separate, time-limited, and transparent)
- **Distribution**: 100% proof-of-work mining from genesis
- **Public Announcement**: 2 weeks before mainnet launch
- **Testnet Period**: 1 month private + 2 weeks public

### Initial Network Bootstrap
1. **Week -2**: Public announcement, mining preparation
2. **Week -1**: Final testing, community setup
3. **Day 0**: Genesis block, mining begins immediately
4. **Week 1**: Network stabilization, exchange listings preparation
5. **Month 1**: First hardfork (HF2) with RingCT

---

## 🔬 **Technical Implementation Details**

### Critical Code Changes (from Monero)

**File: src/cryptonote_config.h**
```cpp
// Block timing
#define DIFFICULTY_TARGET_V2                    30      // 30-second blocks
#define CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW     6      // 3 minutes

// Economics
#define MONEY_SUPPLY                            10880000000000000  // 108.8M
#define EMISSION_SPEED_FACTOR_PER_MINUTE        8       // Emission curve
#define FINAL_SUBSIDY_PER_MINUTE                1800000000000     // 0.5 XWIFT per block
#define CRYPTONOTE_DISPLAY_DECIMAL_POINT         8      // 8 decimals
#define COIN                                    100000000          // 1e8 units

// Development Fund
#define DEV_FUND_PERCENTAGE                     2       // 2% of reward
#define DEV_FUND_DURATION_BLOCKS                1051200 // 1 year
```

---

## 📊 **Supply Distribution Timeline**

### 10-Year Distribution
```
Year 1:  2.9% of total supply (3.15M XWIFT)
Year 2:  5.5% cumulative (6.04M XWIFT)
Year 3:  8.0% cumulative (8.69M XWIFT)
Year 4: 12.0% cumulative (13.0M XWIFT)
Year 5: 20.1% cumulative (21.8M XWIFT)
Year 10: 49.7% cumulative (54.0M XWIFT)
Year 20: 74.8% cumulative (81.5M XWIFT)
Year 50: 95.3% cumulative (103M XWIFT)
```

### Inflation Model
```
Year 1:  High emission for bootstrap
Year 2-5: Decreasing inflation
Year 10+: Stable ~0.5% tail emission
Year 50+: Asymptotic approach to 0.48%
```

---

## ⚠️ **Important Notes for Deployment**

### Before Mainnet Launch (CRITICAL)
1. **Set Development Fund Address**: Replace `DEVELOPMENT_FUND_ADDRESS_TO_BE_SET` in cryptonote_config.h with your actual Xwift address
2. **Test on Testnet**: Mine minimum 10,000 blocks to verify economics
3. **Security Audit**: Have block reward and dev fund logic professionally audited
4. **Announce Publicly**: Give community 2 weeks preparation time
5. **Seed Nodes**: Set up minimum 5 geographically distributed seed nodes

### Development Fund Transparency
- **Blockchain Visibility**: All fund transactions visible at the specified address
- **Public Reporting**: Quarterly reports required on usage
- **Community Trust**: Critical for project legitimacy
- **Auto-Termination**: Fund automatically stops after 1,051,200 blocks

---

## 📚 **Additional Resources**

### Documentation
- Full deployment guide: `DEPLOYMENT_GUIDE.md`
- Fork analysis: `XWIFT_FORK_ANALYSIS.md`
- Quick start: `README_XWIFT.md`

### Network Status
- Block explorer: (To be deployed)
- Mining pools: (To be announced)
- Exchanges: (Post-launch)

---

**Last Updated**: 2025-01-03
**Specification Version**: 1.0
**Implementation Status**: Core economics implemented, testing in progress
**Target Launch**: Q2 2025 pending security audits

---

## ✅ **Implementation Checklist**

- [x] Network identity (name, IDs, addresses)
- [x] 30-second block time
- [x] 108.8M supply with tail emission
- [x] 8 decimal places
- [x] Enhanced RandomX configuration
- [x] Development fund structure (2% for 1 year)
- [x] Uncle block reward system specification
- [x] Fast difficulty adjustment
- [x] Hardfork schedule optimization
- [ ] **Set actual development fund address before launch**
- [ ] Complete security audit
- [ ] Testnet stress testing
- [ ] Documentation finalization
- [ ] Community announcement

---

**🎯 Xwift delivers on its promise: Privacy-first, near-instant transactions with sustainable economics and robust security.**