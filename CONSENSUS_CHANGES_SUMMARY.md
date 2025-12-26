# XWIFT Consensus Changes Summary

**Purpose**: Document all consensus-level modifications made when forking XWIFT from Monero.  
**Audience**: Protocol engineers, validator operators, auditors, and integration partners.  
**Last Updated**: 2025-01-19

---

## 1. Executive Summary

XWIFT inherits Monero's battle-tested Cryptonote consensus model but introduces key changes to achieve faster settlement, improved responsiveness, and a predictable economic schedule tailored to an 8-year base supply. The most visible differences are the 30-second block cadence, 72-block difficulty window, longer coinbase maturity, and a custom emission plan delivering 72.5M XWIFT before a 1.2 XWIFT/block perpetual tail emission.

---

## 2. Parameter Overview (Monero vs XWIFT)

| Area | Monero (v0.18) | XWIFT | Rationale |
|------|----------------|-------|-----------|
| **Block Time** | 120 seconds | **30 seconds** | Faster settlement, 4× throughput vs Monero |
| **Difficulty Target** | 120 seconds | **30 seconds (DIFFICULTY_TARGET_V2)** | Aligns with faster blocks |
| **Difficulty Window** | 60 blocks (~2 hours) | **72 blocks (36 minutes)** | Wider sample for stability at 30s cadence; requirement in CRITICAL #4 |
| **Difficulty Lag** | 15 blocks | **3 blocks** | Faster response to hashrate swings |
| **Timestamp Window** | 60 blocks | **15 blocks** | Tighter bound to block time, mitigates timestamp attacks |
| **Coinbase Maturity** | 60 minutes (60 blocks) | **30 minutes (60 blocks)** | Maintains 30-minute finality at 30s blocks (CRITICAL #3) |
| **Money Supply** | ~18.4M XMR (before tail) | **72.5M XWIFT (8 years)** | Custom supply curve |
| **Tail Emission** | 0.6 XMR/block (~120s) | **1.2 XWIFT/block (30s)** | Ensures security budget post base supply |
| **Decimals** | 12 (COIN = 1e12) | **8 (COIN = 1e8)** | Easier UX, consistent with CRITICAL #7 |
| **Fee Per KB** | 0.0002 XMR | **0.002 XWIFT** | Adjusted for 8 decimals + faster blocks |
| **Default Ports** | 18080/18081 | **19080/19081 (testnet: 29080/29081)** | Avoid collision with Monero nodes |
| **Hard Fork Table** | 10+ versions | **Rebased schedule** | Aligns with new features and faster cadence |
| **P2P Defaults** | 12 peers | **16 peers + shorter handshake** | Faster propagation |

---

## 3. 30-Second Block Time Implications

### Throughput & Finality
- **Blocks per day**: 2,880 (vs Monero's 720)
- **6 confirmations**: 3 minutes finality (vs 12 minutes)
- **Increased chain size**: 4× more blocks; pruning and fast sync recommended
- **Higher orphan risk**: mitigated via wider difficulty window, aggressive propagation parameters, and 60-block maturity

### Engineering Considerations
- Block validation, transaction pool, and network queues must handle 4× more wakeups.  
- RPC polling intervals reduced (default handshake 30s vs 60s).  
- Seed nodes require higher bandwidth (≥100 Mbps).  
- Monitoring dashboards should aggregate metrics per minute rather than per block.

---

## 4. Difficulty Window Changes (8 → 72 Blocks)

- **Original Proposal (8 blocks)**: Early prototypes used an 8-block (4-minute) window. This proved too reactive, causing oscillations and enabling timestamp manipulation.
- **Final Implementation (72 blocks)**: 36-minute history with 3-block lag. Provides smoother adjustments while still 3× faster than Monero's ~2-hour window.

### Benefits
- Dampens oscillations from sudden hashrate spikes/drops.  
- Reduces orphan rate from 20-30% (observed in early tests) to <5% (target).  
- Improves security against time-warp attacks by blending larger data set with tighter timestamp checks.

### Testing Recommendations
- Simulate ±50%, ±200%, and +500% hashrate changes (see `TESTNET_VALIDATION_GUIDE.md`).  
- Monitor `print_block` difficulty values across 720+ blocks per scenario.  
- Ensure retarget never exceeds ±20% per 72-block window (expected behavior).

---

## 5. Maturity Window Changes (6 → 60 Blocks)

- **Monero**: 60-block maturity at 2-minute blocks = 120 minutes.  
- **XWIFT**: 60-block maturity at 30-second blocks = 30 minutes.

### Motivation
- Prevents mining pool payout manipulation at faster cadence.  
- Provides 30-minute finality before coinbase outputs become spendable.  
- Aligns with CRITICAL #3 requirement: Resist reorg attacks targeting pool payouts.

### Operational Impact
- Exchanges/wallets should wait **60 confirmations** for mined deposits.  
- Block explorers must highlight maturity height = `coinbase_height + 60`.  
- Regression tests must mine 60 blocks after each coinbase to spend funds.

---

## 6. Timestamp Validation Changes

- **Window**: Reduced from 60 blocks (Monero) to 15 blocks (7.5 minutes).  
- **Future Time Limit**: Remains at 2 hours (`CRYPTONOTE_BLOCK_FUTURE_TIME_LIMIT`).

### Rationale
- 30-second cadence means 60-block window covered 30 minutes, providing too much slack.  
- 15-block median ensures manipulations quickly detected and rejected.  
- Couples with 72-block difficulty history to defeat time-warp attacks that previously exploited tighter windows.

### Enforcement
- Nodes compute median of last 15 timestamps; new block must be ≥ median and ≤ current time + 2 hours.  
- Violations entered into log with `timestamp check failed`.  
- Testing includes replaying crafted blocks with ±600 second drift.

---

## 7. Emission Schedule Changes

### Base Supply
- **Target**: 72,500,000 XWIFT over ~8 years (8,409,600 blocks).  
- **Initial Block Reward**: ~34.57 XWIFT (first blocks).  
- **Reward Decay**: Controlled via `EMISSION_SPEED_FACTOR_PER_MINUTE = 20` tuned for 30-second blocks.  
- **Verification**: Running the emission script (`python3 scripts/emission_curve.py`) yields ~71.6M before tail when rounding to atomic units (see `EMISSION_SCHEDULE.md` for details).

### Tail Emission
- Starts immediately after base supply hits ~72.5M XWIFT.  
- Fixed `FINAL_SUBSIDY_PER_MINUTE = 2.4 XWIFT/minute` ⇒ **1.2 XWIFT per 30-second block**.  
- Ensures perpetual security budget of 3,456 XWIFT/day (~1.26M/year).

### Economic Implications
- Inflation drops from ~24k XWIFT/day at launch to 3,456 XWIFT/day in perpetuity.  
- Predictable supply curve supports economic modeling and exchange integration.  
- 8 decimal places simplify payment UX and align with CRITICAL monetary specification.

---

## 8. Additional Consensus Modifications

| Category | Change | Notes |
|----------|--------|-------|
| **Network Identity** | Address prefixes 65/66/67 (mainnet), 85/86/87 (testnet) | Prevent cross-chain confusion |
| **Ports & UUID** | P2P: 19080, RPC: 19081, ZMQ: 19082 | Avoid Monero overlap |
| **P2P Propagation** | 16 default peers, handshake 30s, sync batch size doubled | Required for 30-second cadence |
| **Dynamic Fees** | Base fee tuned for 8 decimals (0.002 XWIFT/kB) | Aligns with smaller COIN |
| **Hard Fork Table** | Accelerated early feature activations (RingCT, CLSAG, BP+) | Provide privacy/security from genesis |
| **Dust Threshold** | 0.002 XWIFT (200,000 atomic units) | Avoid micro-dust at 8 decimals |
| **RPC Limits** | Lower connection limits per IP to mitigate spam | 3 public IP connections by default |

---

## 9. Performance Implications

- **Storage Growth**: 4× blocks/year requires pruning (default long-term block weight window set to 100k).  
- **Network Load**: Increased handshake frequency; ensure validators have stable bandwidth.  
- **CPU Usage**: Daemon wakeups every 30 seconds; set `max-concurrency` to avoid thrashing on low-end hardware.  
- **Safety Margin**: `P2P_DEFAULT_LIMIT_RATE_UP/DOWN` increased to 8/32 MBps.  
- **Sync Behavior**: `BLOCKS_SYNCHRONIZING_DEFAULT_COUNT` doubled to 200 with max 8192 to keep up with block creation.

---

## 10. Testing Recommendations

### Core Scenarios
1. **Difficulty Oscillation Test**: ±50%, ±200%, and +500% hashrate swings (scripts in `TESTNET_VALIDATION_GUIDE.md`).  
2. **Timestamp Attack Simulation**: Submit blocks with ±10-minute offsets; ensure rejection/logs.  
3. **Emission Curve Validation**: Compare `print_block` rewards at milestones vs script results.  
4. **Coinbase Maturity**: Ensure unlock exactly at `height + 60`.  
5. **Network Partitions**: Split nodes into two groups, let both mine, then heal; confirm canonical chain equals highest cumulative difficulty.  
6. **Tail Emission Activation**: Force-skip to block 8,409,600 in private testnet (`--fixed-difficulty`) and verify reward locks at 1.2 XWIFT.  
7. **Stress Propagation**: Flood network with transactions (simulate 150KB blocks) to ensure propagation <30s.

### Tooling
- **RPC**: `get_info`, `print_block`, `hard_fork_info`, `alt_chain_info`.  
- **Scripts**: Provided in `TESTNET_VALIDATION_GUIDE.md` and `EMISSION_SCHEDULE.md`.  
- **Metrics**: Height, difficulty, orphan rate, timestamp drift, block propagation time.

### Acceptance Criteria
- No consensus mismatches between nodes running identical code.  
- Difficulty and emission results match reference scripts within ±0.1%.  
- Orphan rate <5% over 10k+ blocks.  
- Timestamp validation rejects >99.9% of manipulated attempts.  
- Coinbase maturity irreversibly enforced at 60 blocks.

---

## 11. Compatibility Notes

- **Wallets**: Must support 8 decimal places and new address prefixes.  
- **Block Explorers**: Update block time assumptions, reward parsing, and difficulty charts.  
- **Mining Pools**: Adjust payout logic for 30-second blocks and 60-block maturity.  
- **Exchanges**: Require 60 confirmations for deposits; adjust risk models for faster block cadence.  
- **Light Clients**: Increase polling frequency to 15s or subscribe via ZMQ for near-real-time updates.

---

## 12. References

- `src/cryptonote_config.h` — Ground truth for constants and consensus settings.  
- `src/cryptonote_basic/cryptonote_basic_impl.cpp` — Emission and reward calculation.  
- `tests/unit_tests/block_reward.cpp` — Regression coverage for emission math.  
- `TESTNET_VALIDATION_GUIDE.md` — Detailed procedures for validating consensus behavior.  
- `EMISSION_SCHEDULE.md` — Block-by-block emission analysis.  
- `EMERGENCY_FORK_GUIDE.md` — Procedures when consensus parameters require urgent changes.

---

**Document Version**: 1.0 |
**Maintainers**: Protocol Working Group (protocol@xwift.network)
