# Week 1 - Baseline & Initial Validation

**Objective:** Establish baseline metrics, verify network stability, and ensure monitoring pipeline is working.

## Day 1-2: Deployment & Sync
- [ ] Deploy 3 seed nodes across providers
- [ ] Verify DNS and firewall configuration
- [ ] Confirm blockchain sync progress
- [ ] Collect initial metrics snapshot

## Day 3: Baseline Metrics
- [ ] Measure average block time over 500 blocks
- [ ] Establish baseline difficulty curve
- [ ] Record initial orphan rate (should be near 0% at genesis)
- [ ] Validate emission for blocks 1-100

## Day 4: Monitoring Pipeline
- [ ] Run `collect-metrics.sh --daily-report`
- [ ] Start orphan tracker (sample 1000 blocks)
- [ ] Start difficulty monitor (sample 500 blocks)
- [ ] Confirm dashboards update automatically

## Day 5: Public Mining Access
- [ ] Announce testnet mining instructions
- [ ] Invite community testers
- [ ] Track incoming connections (>30 expected)
- [ ] Ensure mining rewards distributed correctly

## Day 6: Block Propagation Baseline
- [ ] Run `block-propagation-test.sh --samples 200`
- [ ] Measure latency between NYC ↔ Frankfurt ↔ Singapore
- [ ] Identify any routing issues or high-latency links

## Day 7: Weekly Summary
- [ ] Generate weekly report (`automated-report.sh --weekly`)
- [ ] Review open issues
- [ ] Plan Week 2 stress tests

### Expected Outcomes
- Stable network with <5% orphan rate
- All monitoring scripts operational
- Public mining successfully connected
- Baseline metrics recorded for comparison
