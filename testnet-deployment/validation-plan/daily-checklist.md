# Xwift Testnet Daily Validation Checklist

**Purpose:** Ensure consistent monitoring and validation activities during the 30-day testnet run.

## Daily Tasks (Every 24 Hours)

### 1. Node Health Checks
- [ ] Verify all seed nodes are online (use `monitoring/collect-metrics.sh --check-seeds`)
- [ ] Confirm RPC responsiveness on each node
- [ ] Review systemd status: `systemctl status xwift-testnet`
- [ ] Check disk usage and available storage

### 2. Network Metrics
- [ ] Capture daily metrics (`monitoring/collect-metrics.sh --daily-report`)
- [ ] Record block height, difficulty, and connections per node
- [ ] Review orphan rate tracker logs for anomalies
- [ ] Note block propagation times and outliers

### 3. Consensus Validation
- [ ] Confirm block time remains ~30 seconds
- [ ] Review difficulty data for stability
- [ ] Check emission validation results for the day
- [ ] Ensure dev fund checker reports expected status

### 4. Mining Operations
- [ ] Confirm public mining access is operational
- [ ] Verify at least one external miner is connected (if applicable)
- [ ] Ensure mining threads/hashrate tests scheduled for the day are executed

### 5. Logs & Alerts
- [ ] Inspect `/var/log/xwift-testnet/xwift.log` for warnings/errors
- [ ] Review journal logs for crashes or restarts
- [ ] Check monitoring alerts (if any) and document responses

### 6. Reporting & Documentation
- [ ] Update validation tracker with daily results
- [ ] Append notable events/incidents to daily report
- [ ] Archive metrics JSON (`reports/metrics-*.json`)
- [ ] Backup all logs and reports to secure storage

### 7. Security Review
- [ ] Ensure SSH access logs show no anomalies
- [ ] Validate firewall rules (only required ports open)
- [ ] Confirm restricted RPC mode is enabled (`restricted-rpc=1`)
- [ ] Run vulnerability updates if available (outside of test windows)

### 8. Readiness Evaluation
- [ ] Compare metrics against success criteria
- [ ] Flag any deviations >10% from targets
- [ ] Plan remediation steps for identified issues
- [ ] Communicate status to stakeholders

---

## Daily Report Template

```
Date: <YYYY-MM-DD>
Deploy ID: <ID>

Node Status
-----------
Seed1: Online/Offline (Height, Difficulty, Connections)
Seed2: ...
Seed3: ...

Metrics Summary
---------------
- Orphan rate: <value>% (target <5%)
- Avg block time: <value>s
- Difficulty trend: Rising/Stable/Falling
- Emission check: Pass/Fail
- Dev fund status: Active/Terminated

Incidents
---------
- [Description, impact, resolution]

Actions for Tomorrow
--------------------
- [Task 1]
- [Task 2]

Prepared by: <Name>
```

---

**Reminder:** Any critical issue (consensus failure, forks >10 blocks, emission mismatch) must be escalated immediately to core developers.
