# Daily Validation Checklist - Local Testnet

## Overview
Use this checklist each day to ensure the 4-node local testnet is running smoothly. Each daily review should take ~15 minutes.

---

## Step 1: Node Health

- [ ] `./status-testnet.sh`
  - Verify all nodes show `HEIGHT == TARGET` and `PEERS > 0`
- [ ] `docker ps`
  - Confirm containers `xwift-seed-1/2/3`, `xwift-mining` are `Up`
- [ ] `./logs-testnet.sh mining --follow`
  - Check for new blocks within last hour

---

## Step 2: Resource Checks

- [ ] `docker stats --no-stream`
  - CPU per container <80%
  - Memory per container <3GB
- [ ] `df -h`
  - Ensure `local-testnet/data/*` partitions have >50GB free
- [ ] `free -h`
  - System has >8GB free RAM

---

## Step 3: Blockchain Metrics

- [ ] `./monitoring/orphan-rate-tracker-local.sh 5`
  - Orphan rate <5%
- [ ] `./monitoring/difficulty-monitor-local.sh 120`
  - Difficulty within expected range
- [ ] `./monitoring/block-propagation-test.sh 3`
  - Propagation <2 seconds to all seeds

---

## Step 4: Economics

- [ ] `./emission-validator-local.py --window 200`
  - Rewards within expected range
- [ ] `./monitoring/dev-fund-checker-local.sh`
  - Dev fund status matches height (active before 1,051,200; terminated after)

---

## Step 5: Reports & Dashboard

- [ ] `./dashboard/generate-local-dashboard.sh`
  - Open `dashboard/index.html` to verify
- [ ] `./dashboard/daily-report-generator.sh`
  - Save Markdown report to `dashboard/reports/`
- [ ] Screenshot dashboard & archive in `reports/screenshots/`

---

## Step 6: Hashrate Simulation (Weekly)

- [ ] `./hashrate-simulator.sh 1`
  - Cycle through 50%, 100%, 200%, 500% load
  - After run, execute `./monitoring/difficulty-monitor-local.sh 240`

---

## Step 7: Maintenance

- [ ] `docker system prune -af` (weekly)
- [ ] `./reset-testnet.sh --restart` (monthly) if storage >400GB

---

## Checklist Template (Copy Daily)

```
Date: __________

Node Health
[ ] Status check
[ ] Docker ps
[ ] Mining logs

Resources
[ ] docker stats
[ ] df -h
[ ] free -h

Blockchain
[ ] Orphan rate
[ ] Difficulty monitor
[ ] Propagation test

Economics
[ ] Emission validator
[ ] Dev fund checker

Reports
[ ] Generate dashboard
[ ] Daily report
[ ] Archive screenshot

Notes:
- 
- 
- 
```

---

## Tips

- Schedule daily reminders at same time each day.
- Keep logs in `reports/daily-checklists/` for audit trail.
- Automate with `./test-harness.sh --quick` if time constrained.
