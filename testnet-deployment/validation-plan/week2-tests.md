# Week 2 - Stress & Variance Testing

**Objective:** Validate consensus resilience under variable hashrate and network load.

## Day 8: Hashrate Drop Test
- [ ] Run `hashrate-variance-test.sh` phase 1 (baseline)
- [ ] Stop mining for 72 blocks to simulate 50% drop
- [ ] Record difficulty decrease %
- [ ] Document block time deviation

## Day 9: Hashrate Spike Test
- [ ] Resume mining with 8 threads (200% spike)
- [ ] Measure adjustment period and overshoot
- [ ] Verify no consensus splits occur

## Day 10: Hashrate Surge Test
- [ ] Launch surge with 16 threads (500% increase)
- [ ] Monitor for oscillations or instability
- [ ] Collect difficulty log for 500+ blocks

## Day 11: Recovery Observation
- [ ] Return to baseline hashrate
- [ ] Measure time to stabilize at target block time
- [ ] Check for residual oscillations

## Day 12: Network Stress Test
- [ ] Use `stress-test-network.sh` to send 100+ TX
- [ ] Monitor mempool size and propagation
- [ ] Ensure faucet and wallets remain responsive

## Day 13: Orphan Audit
- [ ] Review orphan tracker logs
- [ ] Investigate any spikes >5%
- [ ] Correlate with network events

## Day 14: Weekly Review
- [ ] Generate weekly report
- [ ] Highlight stress test findings
- [ ] Decide on adjustments for Week 3

### Expected Outcomes
- Difficulty adjusts smoothly within ±10% block time variation
- No forks longer than 2 blocks during stress
- Network handles transaction bursts without backlog
