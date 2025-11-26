# Week 3 - Long-term Stability & Emission Validation

**Objective:** Validate long-term stability, emission accuracy, and edge cases.

## Day 15: Emission Checkpoint Validation
- [ ] Run `emission-validator.py --checkpoints 1 100 1000 10000 100000`
- [ ] Verify rewards match expected curve within ±0.1%
- [ ] Document any discrepancies

## Day 16: Block Propagation Analysis
- [ ] Re-run `block-propagation-test.sh` with larger sample
- [ ] Compare to Week 1 baseline (should be same or better)
- [ ] Identify any degradation trends

## Day 17: Continuous Uptime Check
- [ ] Verify all seed nodes have 100% uptime since Day 1
- [ ] Check for memory leaks (monitor RAM usage trend)
- [ ] Review any restarts or crashes

## Day 18: Community Mining Assessment
- [ ] Count active public miners
- [ ] Track geographic distribution
- [ ] Gather community feedback on mining experience

## Day 19: Difficulty Window Verification
- [ ] Extract 10,000 blocks of difficulty data
- [ ] Plot difficulty over time
- [ ] Analyze for anomalies or unexpected patterns

## Day 20: Wallet & RPC Testing
- [ ] Test wallet creation and recovery
- [ ] Verify transaction history accuracy
- [ ] Test RPC endpoints under load

## Day 21: Weekly Review
- [ ] Generate weekly report
- [ ] Milestone check: ~20,000+ blocks mined
- [ ] Plan Week 4 final validation

### Expected Outcomes
- Emission schedule verified accurate
- No long-term stability issues
- Community mining active and positive
