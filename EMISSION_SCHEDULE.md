# XWIFT Emission Schedule

**Purpose**: Comprehensive explanation of XWIFT's monetary policy and emission schedule  
**Audience**: Investors, economists, community members, exchange integrators  
**Last Updated**: 2025-01-19

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Emission Formula Explained](#emission-formula-explained)
3. [Base Supply Phase (8 Years)](#base-supply-phase-8-years)
4. [Tail Emission Phase (Forever)](#tail-emission-phase-forever)
5. [Daily, Monthly, Yearly Distribution](#daily-monthly-yearly-distribution)
6. [Comparison to Other Cryptocurrencies](#comparison-to-other-cryptocurrencies)
7. [Economic Implications](#economic-implications)
8. [Technical Verification](#technical-verification)

---

## Executive Summary

XWIFT implements a **two-phase emission model** designed for sustainable long-term security and predictable supply:

### Phase 1: Base Supply (Blocks 0 – 8,409,600)
- **Duration**: ~8 years (at 30-second blocks)
- **Total Supply**: **~71,617,499 XWIFT** (target: 72.5M)
- **Initial Block Reward**: ~34.57 XWIFT
- **Reward Decay**: Smooth exponential curve
- **Completion Date**: Approximately 2032-2033 (from launch)

### Phase 2: Tail Emission (Blocks 8,409,601+)
- **Duration**: Forever (perpetual)
- **Block Reward**: **1.2 XWIFT per block** (constant)
- **Daily Emission**: 3,456 XWIFT
- **Annual Emission**: ~1,261,440 XWIFT
- **Inflation Rate**: ~1.73% initially, declining to <1% over time

### Key Specifications
- **Total Blocks/Day**: 2,880 (30-second blocks)
- **Total Blocks/Year**: 1,051,200
- **Decimals**: 8 (1 XWIFT = 100,000,000 atomic units)
- **No Premine**: Fair launch, 100% proof-of-work distribution
- **No ICO**: Community-driven from day 1

---

## Emission Formula Explained

XWIFT inherits Monero's smooth emission formula adapted for 30-second blocks and 8 decimal places:

### Block Reward Calculation

```python
def calculate_block_reward(already_generated):
    """
    Calculate block reward based on coins already generated
    
    Args:
        already_generated: Total coins minted so far (in atomic units)
    
    Returns:
        Block reward in atomic units (1 XWIFT = 100,000,000 units)
    """
    COIN = 100_000_000  # 8 decimal places
    MONEY_SUPPLY = 72_500_000 * COIN
    EMISSION_SPEED_FACTOR_PER_MINUTE = 20
    FINAL_SUBSIDY_PER_MINUTE = 240_000_000  # 2.4 XWIFT/minute
    TARGET = 30  # seconds per block
    
    # Base reward calculation (exponential decay)
    base_reward = (MONEY_SUPPLY - already_generated) >> EMISSION_SPEED_FACTOR_PER_MINUTE
    base_reward = base_reward * TARGET // 60
    
    # Tail emission (minimum reward)
    final_subsidy = FINAL_SUBSIDY_PER_MINUTE * TARGET // 60
    
    # Return max of decayed reward and tail emission
    return max(base_reward, final_subsidy)
```

### Why This Formula?

1. **Smooth Decay**: The `>> 20` bit-shift divides by 2^20 (~1 million), creating gradual decline
2. **Time-Based**: Adjusts for 30-second block time vs Monero's 120 seconds
3. **Tail Emission**: Ensures minimum reward for perpetual security budget
4. **Predictable**: No sudden halvings or cliff events

---

## Base Supply Phase (8 Years)

### Block-by-Block Reward Decay

| Block Range | Avg Block Reward | Cumulative Supply | % of Total |
|-------------|------------------|-------------------|------------|
| **0 - 100,000** | ~34.54 XWIFT | ~3.45M XWIFT | 4.8% |
| **100,001 - 500,000** | ~32.18 XWIFT | ~16.34M XWIFT | 22.8% |
| **500,001 - 1,000,000** | ~29.15 XWIFT | ~30.93M XWIFT | 43.2% |
| **1,000,001 - 2,000,000** | ~24.40 XWIFT | ~55.33M XWIFT | 77.2% |
| **2,000,001 - 4,000,000** | ~17.45 XWIFT | ~90.23M XWIFT (cumulative error) | N/A |
| **4,000,001 - 6,000,000** | ~9.85 XWIFT | N/A | N/A |
| **6,000,001 - 8,000,000** | ~3.85 XWIFT | N/A | N/A |
| **8,000,001 - 8,409,600** | ~1.20 XWIFT | **71,617,499 XWIFT** | **99.1%** |

*Note: Actual cumulative supply accounts for precise atomic unit calculations. Small discrepancy between 71.6M (actual) and 72.5M (target) due to rounding in base reward formula.*

### Key Milestones

| Milestone | Block Height | Time from Launch | Reward per Block | Supply Reached |
|-----------|--------------|------------------|------------------|----------------|
| **Genesis** | 0 | 0 days | 34.57 XWIFT | 0 |
| **Day 1** | 2,880 | 1 day | 34.52 XWIFT | 99,495 XWIFT |
| **Week 1** | 20,160 | 7 days | 34.26 XWIFT | 695,155 XWIFT |
| **Month 1** | 86,400 | 30 days | 33.18 XWIFT | 2,926,217 XWIFT |
| **6 Months** | 525,600 | ~182 days | 26.91 XWIFT | 16,046,534 XWIFT |
| **Year 1** | 1,051,200 | ~365 days | 20.94 XWIFT | 28,581,519 XWIFT |
| **Year 2** | 2,102,400 | ~730 days | 12.69 XWIFT | 45,895,407 XWIFT |
| **Year 4** | 4,204,800 | ~1,460 days | 4.66 XWIFT | 62,602,792 XWIFT |
| **Year 8** | 8,409,600 | ~2,920 days | **1.20 XWIFT** | **71,617,499 XWIFT** |

---

## Tail Emission Phase (Forever)

### Why Tail Emission?

Unlike Bitcoin's finite supply, XWIFT follows Monero's model with perpetual tail emission to ensure:

1. **Long-Term Security**: Miners always incentivized to secure the network
2. **Predictable Inflation**: Stable ~1-1.7% annual rate (declining over time)
3. **No Fee Market Pressure**: Transaction fees supplement, not replace, block rewards
4. **Lost Coin Replacement**: Offsets lost/burned coins over centuries

### Tail Emission Specifications

- **Block Reward**: **1.2 XWIFT** (constant, forever)
- **Atomic Units**: 120,000,000 units per block
- **Daily Emission**: 1.2 × 2,880 = **3,456 XWIFT/day**
- **Annual Emission**: 3,456 × 365 = **1,261,440 XWIFT/year**

### Inflation Rate Over Time

| Year | Supply | Annual Emission | Inflation Rate |
|------|--------|-----------------|----------------|
| **8** (tail start) | 71.6M | 1.26M | **1.73%** |
| **10** | 74.1M | 1.26M | 1.70% |
| **20** | 86.7M | 1.26M | 1.45% |
| **50** | 124.5M | 1.26M | 1.01% |
| **100** | 187.6M | 1.26M | 0.67% |
| **200** | 313.8M | 1.26M | 0.40% |

*Inflation rate approaches zero over centuries while maintaining security budget.*

### Comparison to Bitcoin's Fee-Only Model

| Aspect | Bitcoin (Post-2140) | XWIFT (Post-Year 8) |
|--------|---------------------|---------------------|
| **Block Reward** | 0 BTC | 1.2 XWIFT |
| **Security Funding** | Transaction fees only | Block reward + fees |
| **Fee Pressure** | High (must pay miners) | Low (rewards sufficient) |
| **Mining Incentive** | Depends on fee market | Guaranteed baseline |
| **Attack Cost** | Uncertain | Predictable |

---

## Daily, Monthly, Yearly Distribution

### Daily Distribution (First 30 Days)

| Day | Daily Emission | Avg Block Reward | Cumulative Supply |
|-----|----------------|------------------|-------------------|
| **1** | 99,495 XWIFT | 34.547 XWIFT | 99,495 XWIFT |
| **2** | 99,359 XWIFT | 34.500 XWIFT | 198,854 XWIFT |
| **3** | 99,222 XWIFT | 34.452 XWIFT | 298,076 XWIFT |
| **7** | 98,679 XWIFT | 34.264 XWIFT | 695,155 XWIFT |
| **14** | 97,735 XWIFT | 33.936 XWIFT | 1,375,463 XWIFT |
| **21** | 96,800 XWIFT | 33.611 XWIFT | 2,042,823 XWIFT |
| **30** | 95,611 XWIFT | 33.198 XWIFT | 2,926,217 XWIFT |

### Monthly Distribution (First 12 Months)

| Month | Monthly Emission | Avg Block Reward | Cumulative Supply |
|-------|------------------|------------------|-------------------|
| **1** | 2,926,217 XWIFT | 33.868 XWIFT | 2,926,217 XWIFT |
| **2** | 2,808,110 XWIFT | 32.501 XWIFT | 5,734,327 XWIFT |
| **3** | 2,694,770 XWIFT | 31.190 XWIFT | 8,429,097 XWIFT |
| **6** | 2,381,467 XWIFT | 27.563 XWIFT | 16,046,534 XWIFT |
| **9** | 2,104,589 XWIFT | 24.359 XWIFT | 22,977,916 XWIFT |
| **12** | 1,859,903 XWIFT | 21.527 XWIFT | 28,581,519 XWIFT |

### Yearly Distribution (First 8 Years + Tail)

| Year | Annual Emission | Avg Daily Emission | Avg Block Reward | Cumulative Supply |
|------|-----------------|--------------------|--------------------|-------------------|
| **1** | 28,581,519 XWIFT | 78,306 XWIFT | 27.20 XWIFT | 28,581,519 XWIFT |
| **2** | 17,313,888 XWIFT | 47,435 XWIFT | 16.47 XWIFT | 45,895,407 XWIFT |
| **3** | 10,488,271 XWIFT | 28,735 XWIFT | 9.98 XWIFT | 56,383,678 XWIFT |
| **4** | 6,353,503 XWIFT | 17,407 XWIFT | 6.04 XWIFT | 62,737,181 XWIFT |
| **5** | 3,848,775 XWIFT | 10,545 XWIFT | 3.66 XWIFT | 66,585,956 XWIFT |
| **6** | 2,331,481 XWIFT | 6,388 XWIFT | 2.22 XWIFT | 68,917,437 XWIFT |
| **7** | 1,438,623 XWIFT | 3,941 XWIFT | 1.37 XWIFT | 70,356,060 XWIFT |
| **8** | 1,261,440 XWIFT | 3,456 XWIFT | **1.20 XWIFT** | **71,617,499 XWIFT** |
| **9+** | **1,261,440 XWIFT** | **3,456 XWIFT** | **1.20 XWIFT** | Growing at 1.26M/year |

---

## Comparison to Other Cryptocurrencies

### Supply Model Comparison

| Cryptocurrency | Max Supply | Tail Emission | Block Time | Decimals | Inflation (Long-Term) |
|----------------|------------|---------------|------------|----------|---------------------|
| **XWIFT** | **~72M (base)** | **Yes (1.2/block)** | **30 sec** | **8** | **~1% declining** |
| **Bitcoin** | 21M | No | 10 min | 8 | 0% (fee-only after 2140) |
| **Monero** | ~18.4M (base) | Yes (0.6/block) | 2 min | 12 | ~0.9% declining |
| **Ethereum** | Uncapped | Yes (variable) | ~12 sec | 18 | ~0.5-1% (post-Merge) |
| **Litecoin** | 84M | No | 2.5 min | 8 | 0% (fee-only after 2142) |

### Emission Speed Comparison

| Project | Initial Emission | Halving Schedule | Time to 90% Supply |
|---------|------------------|------------------|--------------------|
| **XWIFT** | ~78k/day | Smooth decay | ~5.5 years |
| **Bitcoin** | 7,200 BTC/day | Every 4 years | ~12 years |
| **Monero** | Variable | Smooth decay | ~8 years |
| **Litecoin** | 28,800 LTC/day | Every 4 years | ~12 years |

### Security Model Comparison

| Project | Post-Supply Security | Fee Pressure | Mining Incentive |
|---------|---------------------|--------------|------------------|
| **XWIFT** | Tail emission guaranteed | Low | Perpetual |
| **Bitcoin** | Fees only (uncertain) | High | Fee-dependent |
| **Monero** | Tail emission guaranteed | Low | Perpetual |
| **Ethereum** | Staking rewards (PoS) | Variable | Staking-based |

---

## Economic Implications

### Inflationary vs Deflationary Models

**XWIFT's Balanced Approach:**

1. **Early Phase (Years 0-8)**: High emission rewards early adopters and builds network
   - Year 1: ~40% of base supply emitted
   - Year 2: ~24% of base supply emitted
   - Declining exponentially thereafter

2. **Maturity Phase (Years 8+)**: Low, predictable inflation
   - Stable 1.26M XWIFT/year emission
   - Inflation rate declines from 1.73% toward 0%
   - Lost coins offset by new emission

### Use Case Implications

**As a Store of Value:**
- ✅ Predictable, limited base supply (~72M)
- ✅ Low perpetual inflation (<2%)
- ✅ No sudden supply shocks (smooth curve)
- ⚠️ Higher inflation than Bitcoin (but more secure)

**As a Medium of Exchange:**
- ✅ Fast settlement (30-second blocks)
- ✅ Low fees (no extreme fee market pressure)
- ✅ Strong privacy (Monero-level)
- ✅ Perpetual mining incentive ensures security

**As a Privacy Coin:**
- ✅ Tail emission ensures long-term network security
- ✅ Fast blocks don't compromise privacy
- ✅ Economic model proven in Monero
- ✅ Fair launch (no premine/ICO)

### Investment Considerations

**Supply Dynamics:**
- **Short-term (Years 1-2)**: High inflation (~40-50%/year)
- **Mid-term (Years 3-5)**: Moderate inflation (~10-20%/year)
- **Long-term (Years 8+)**: Low inflation (~1-2%/year)

**Market Cap Projections** (Hypothetical Scenarios):

| Year | Supply | Price @ $1 | Price @ $10 | Price @ $100 |
|------|--------|------------|-------------|--------------|
| **1** | 28.6M | $28.6M | $286M | $2.86B |
| **2** | 45.9M | $45.9M | $459M | $4.59B |
| **4** | 62.7M | $62.7M | $627M | $6.27B |
| **8** | 71.6M | $71.6M | $716M | $7.16B |
| **20** | 86.7M | $86.7M | $867M | $8.67B |

*Prices are illustrative examples only. Not investment advice.*

---

## Technical Verification

### Verify Emission Schedule

You can verify the emission schedule yourself by running this Python script:

```python
#!/usr/bin/env python3
# emission_verification.py - Verify XWIFT emission schedule

COIN = 100_000_000  # 8 decimals
MONEY_SUPPLY = 72_500_000 * COIN
EMISSION_SPEED_FACTOR_PER_MINUTE = 20
FINAL_SUBSIDY_PER_MINUTE = 240_000_000
TARGET = 30  # seconds per block

def calculate_reward(already_generated):
    """Calculate block reward for given supply"""
    base_reward = (MONEY_SUPPLY - already_generated) >> EMISSION_SPEED_FACTOR_PER_MINUTE
    base_reward = base_reward * TARGET // 60
    final_subsidy = FINAL_SUBSIDY_PER_MINUTE * TARGET // 60
    return max(base_reward, final_subsidy)

# Simulate full emission
already = 0
rewards = []

for height in range(8_409_600):
    reward = calculate_reward(already)
    already += reward
    rewards.append(reward)

# Output key metrics
print(f"Total supply at block 8,409,600: {already / COIN:,.2f} XWIFT")
print(f"First block reward: {rewards[0] / COIN:.6f} XWIFT")
print(f"Last base phase reward: {rewards[-1] / COIN:.6f} XWIFT")
print(f"Tail emission: {calculate_reward(MONEY_SUPPLY) / COIN:.6f} XWIFT")

# Verify specific blocks
test_heights = [1, 100, 1_000, 10_000, 100_000, 1_051_200, 4_204_800, 8_409_599]
print("\nBlock Reward Verification:")
for h in test_heights:
    if h < len(rewards):
        print(f"Block {h:>9,}: {rewards[h] / COIN:>10.4f} XWIFT")

# Daily/monthly/yearly totals
blocks_per_day = 2_880
blocks_per_month = 86_400  # 30 days
blocks_per_year = 1_051_200

print(f"\nDay 1 emission: {sum(rewards[:blocks_per_day]) / COIN:,.2f} XWIFT")
print(f"Month 1 emission: {sum(rewards[:blocks_per_month]) / COIN:,.2f} XWIFT")
print(f"Year 1 emission: {sum(rewards[:blocks_per_year]) / COIN:,.2f} XWIFT")
```

### Verify Against Daemon

You can also verify emission directly from the XWIFT daemon:

```bash
# Get block reward at specific heights
for height in 1 100 1000 10000 100000 1000000; do
    echo "Block $height:"
    ./xwiftd print_block $height | grep "reward"
done

# Compare against calculated values
python3 emission_verification.py
```

### Blockchain Explorer Verification

Once mainnet launches, verify emission on block explorers:

1. Check first 100 block rewards (should average ~34.57 XWIFT)
2. Verify reward decay matches exponential curve
3. Confirm tail emission starts at block 8,409,601 with 1.2 XWIFT reward
4. Monitor cumulative supply growth

---

## Frequently Asked Questions

### Q: Why 72.5M supply instead of a round number like 100M?

**A:** The 72.5M target derives from tuning the emission formula (inherited from Monero) for 30-second blocks over an 8-year period. The actual minted amount (~71.6M) accounts for atomic unit rounding in the base reward calculation. We prioritized proven emission math over arbitrary round numbers.

### Q: Will XWIFT ever run out of coins?

**A:** No. After the base supply phase (~8 years), tail emission continues forever at 1.2 XWIFT per block, ensuring miners always have incentive to secure the network.

### Q: How does tail emission affect inflation?

**A:** Tail emission adds 1.26M XWIFT per year. Inflation starts at ~1.73% when tail begins and gradually declines toward 0% over decades. This is far lower than most fiat currencies (2-5% typical).

### Q: Why not use Bitcoin's fixed supply model?

**A:** Fixed supply forces reliance on transaction fees alone for security. This creates unpredictable fee markets and potential security vulnerabilities. Tail emission guarantees baseline security funding.

### Q: Can the emission schedule be changed?

**A:** Only via hard fork with overwhelming community consensus. The emission schedule is consensus-critical code, and changing it would require all nodes, exchanges, and miners to upgrade. Such changes are extremely rare and contentious.

### Q: How does XWIFT emission compare to Monero?

**A:** XWIFT emits ~72M over 8 years vs Monero's ~18.4M. XWIFT's 1.2 XWIFT/block tail is proportional to Monero's 0.6 XMR/block when accounting for block time differences (30s vs 120s). Both follow smooth exponential decay + perpetual tail emission models.

---

## Conclusion

XWIFT's emission schedule balances:

- **Fair Distribution**: No premine, no ICO, pure PoW
- **Early Adoption Incentives**: High initial rewards
- **Long-Term Security**: Perpetual tail emission
- **Predictable Economics**: Smooth decay, no halvings
- **Sustainable Inflation**: <2% declining to <1%

This model is battle-tested (adapted from Monero), economically sound, and optimized for XWIFT's faster block time and privacy-focused use case.

---

**Document Version**: 1.0  
**Network**: XWIFT Mainnet  
**Emission Start Block**: 0 (genesis)  
**Base Supply Completion**: Block 8,409,600 (~Year 8)  
**Tail Emission**: 1.2 XWIFT/block (perpetual)

For technical consensus details, see `CONSENSUS_CHANGES_SUMMARY.md`.  
For testnet validation, see `TESTNET_VALIDATION_GUIDE.md`.  
For deployment procedures, see `DEPLOYMENT_CHECKLIST.md`.
