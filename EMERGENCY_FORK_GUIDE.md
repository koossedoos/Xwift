# XWIFT Emergency Fork Guide

**Purpose**: Provide a repeatable playbook for activating an emergency hard fork, coordinating validators, and communicating with the community when critical bugs or attacks threaten XWIFT mainnet/testnet.  
**Audience**: Core developers, DevOps engineers, validators, mining pools, communications team.  
**Status**: Living document (update after every incident).  
**Last Updated**: 2025-01-19

---

## 📋 Table of Contents

1. [Activation Criteria](#activation-criteria)  
2. [Emergency Fork Activation Process](#emergency-fork-activation-process)  
3. [Hard Fork Voting & Signaling Mechanism](#hard-fork-voting--signaling-mechanism)  
4. [Emergency Contact List Template](#emergency-contact-list-template)  
5. [Rapid-Response Procedures](#rapid-response-procedures)  
6. [Communication Plan for Critical Bugs](#communication-plan-for-critical-bugs)  
7. [Rollback Procedures](#rollback-procedures)  
8. [Validator Coordination Steps](#validator-coordination-steps)  
9. [Technical Appendix](#technical-appendix)  
10. [Post-Incident Checklist](#post-incident-checklist)

---

## Activation Criteria

| Severity | Trigger | Examples | Action |
|----------|---------|----------|--------|
| **Critical** | Active exploit, consensus failure, 51% attack, inflation bug, compromised keys | Invalid blocks accepted, double-spend, emission overflow, dev fund hijack | Immediate emergency fork (<12 hours) |
| **High** | Severe flaw with limited exploitation window | Timestamp manipulation, difficulty collapse, DoS on nodes | Schedule fork within 24 hours |
| **Medium** | Important bug that undermines reliability but not security | Performance regression, memory leak, wallet issue | Bundle into next planned fork |
| **Low** | Cosmetic or non-consensus bug | UI issues, explorer bugs | No fork required |

**Escalation Rule**: If funds at risk or consensus divergence occurs, treat as **Critical**.

---

## Emergency Fork Activation Process

### Phase 0 — **Detection & Triage** (0–30 minutes)
1. Alert raised via monitoring, community report, or security researcher.  
2. On-call engineer opens INCIDENT-XXXX in tracker.  
3. Gather immediate evidence (logs, block hashes, transactions).  
4. Assign Incident Commander (IC) and Technical Lead (TL).

### Phase 1 — **Issue Verification** (30–60 minutes)
- Reproduce bug or confirm attack on isolated node/testnet branch.  
- Capture exact block height, offending transaction hash, or exploit vector.  
- Determine if chain split already occurred.  
- Notify security@xwift.network with PGP-encrypted summary.

### Phase 2 — **Decision & Planning** (≤30 minutes)
- IC schedules emergency bridge call (Discord/Meet).  
- Decide on fix type: parameter change, code patch, checkpoint, rollback.  
- Pick fork height: `current_height + buffer` (see guidelines below).  
- Assign owners for code, testing, binaries, communication.

**Fork Height Buffer Guidelines**
| Scenario | Buffer | Justification |
|----------|--------|---------------|
| Active exploit | +100 blocks (~50 min) | Minimal window, fast response |
| Coordinated upgrade needed | +500 blocks (~4.2 hrs) | Gives validators time |
| Non-urgent bug | +2,000 blocks (~17 hrs) | Allows testing + communication |

### Phase 3 — **Implementation & Review** (1–4 hours)
1. Create branch `emergency-fork-YYYYMMDD`.  
2. Implement fix (consensus code, checkpoints, parameter update).  
3. Update `src/cryptonote_config.h` with new HF version & height.  
4. Run unit tests relevant to change.  
5. Request expedited code review (2 reviewers minimum).

### Phase 4 — **Testing & Packaging** (1–2 hours)
- Build release binaries for Linux, macOS, Windows.  
- Run targeted regression tests (private testnet, reproduction script).  
- Verify block reward, difficulty, timestamp checks unaffected.  
- Generate SHA256 checksums & GPG signatures.  
- Prepare release notes + upgrade instructions.

### Phase 5 — **Release & Monitoring** (until fork finalizes)
1. Publish GitHub release & website update.  
2. Distribute binaries to validators, pools, exchanges.  
3. Monitor upgrade adoption (`hard_fork_info`).  
4. Activate enhanced logging + dashboards.  
5. Declare success after fork height + 100 confirmations.

---

## Hard Fork Voting & Signaling Mechanism

XWIFT inherits Monero’s versioned hard fork table. Each block carries a **major version**; consensus switches once the network observes sufficient upgraded blocks.

### Steps to Define an Emergency Fork
1. **Select New Version**: Increment `HF_VERSION_*` constant (e.g., `HF_VERSION_EMERGENCY_FIX = 16`).  
2. **Set Activation Height**: Update `HF_VERSION_TABLE` entry in `src/cryptonote_core/blockchain.cpp` with `{ version, height, 0, 0 }`.  
3. **Rebuild & Release**: All nodes must run binaries with new version.  
4. **Monitor Voting**: Nodes report how many peers are advertising each version.

### Voting Thresholds
| Metric | Command | Target |
|--------|---------|--------|
| Majority adoption | `./xwiftd hard_fork_info` | >80% peers reporting new version |
| Block version | `./xwiftd print_block <height>` | `major_version` equals new version |
| Peer compliance | `./xwiftd print_cn` | `version` field matches release |

### Example: Monitoring Adoption
```bash
# Check local node status
./xwiftd hard_fork_info

# Sample output
# Current fork version: 15
# Voting: 78% of last 2000 blocks are version 16
# Threshold: 80%

# Fetch peer versions
./xwiftd print_cn | grep "version"
```

**Action**: If voting below threshold 2 hours before fork height, notify stragglers and consider postponing via new emergency release.

---

## Emergency Contact List Template

| Role | Name | Contact | Backup | Notes |
|------|------|--------|--------|-------|
| **Incident Commander** | _Name_ | email/phone/Signal | _Backup_ | Owns decision making |
| **Lead Developer** | _Name_ | | | Implements fix |
| **Security Lead** | _Name_ | | | Coordinates with researchers |
| **DevOps Lead** | _Name_ | | | Seed nodes, monitoring |
| **Communications Lead** | _Name_ | | | Public statements |
| **Legal/Compliance** | _Name_ | | | Approvals |
| **Top Mining Pool #1** | Operator | TG/phone | Alt contact | Hashrate % |
| **Top Mining Pool #2** | | | | |
| **Exchange #1** | Technical contact | Email/phone | | Withdrawal halt |
| **Exchange #2** | | | | |
| **Validator Group** | Rep | Matrix/Signal | | Multi-sig signers |
| **Block Explorer** | Operator | | | Cache flush |
| **Wallet Provider** | | | | Update binaries |
| **Community Manager** | | | | Discord/Twitter |

**Instructions**: Store encrypted copy in password manager and offline (USB). Update quarterly.

---

## Rapid-Response Procedures

### Timeline Overview

| Phase | Duration | Owner | Key Deliverables |
|-------|----------|-------|------------------|
| **0. Detect** | 0–30 min | Monitoring/on-call | Incident ticket, log capture |
| **1. Verify** | 30–60 min | Security + TL | Reproduction, severity rating |
| **2. Decide** | ≤30 min | IC + leads | Fork plan, timeline |
| **3. Fix** | 1–4 hrs | Dev team | Patched branch, code reviews |
| **4. Test** | 1–2 hrs | QA/DevOps | Binaries, checksums |
| **5. Release** | 2–6 hrs | DevOps + Comms | Announcement, downloads |
| **6. Monitor** | 24 hrs | IC + DevOps | Adoption metrics, health reports |

### Rapid-Response Checklist
- [ ] Incident channel opened (`#incident-<date>`).  
- [ ] Roles assigned (IC, TL, Comms, DevOps, Liaison).  
- [ ] Fork height + version agreed.  
- [ ] Patch merged & tagged (e.g., `v0.18.3-emergency`).  
- [ ] Binaries built, checksums signed, uploaded.  
- [ ] Announcement drafted & approved.  
- [ ] Pools/exchanges/validators contacted (see contact list).  
- [ ] Monitoring dashboards pinned.  
- [ ] Rollback plan documented (Section 7).

---

## Communication Plan for Critical Bugs

### Channels & Priority Order
1. **Private Stakeholders** (within 15 min)  
   - Mining pools, validators, exchanges, wallet providers  
   - Method: Signal/Matrix/phone + encrypted email  
   - Message: Minimal disclosure, upgrade instructions
2. **Community Leaders** (within 30 min)  
   - Discord/Telegram mods, ambassadors  
   - Provide talking points & FAQ
3. **Public Announcement** (once binaries live)  
   - Discord `#announcements`, Telegram, Twitter, Reddit, blog  
   - Include fork height, timeline, download links, SHA256 hashes
4. **Status Page** (`status.xwift.network`)  
   - Post incident summary, updates every 30 min until resolved
5. **Post-Mortem** (within 48 hrs)  
   - Blog post + GitHub `POST_MORTEM.md`

### Announcement Template
```[32m🚨 EMERGENCY FORK NOTICE 🚨[0m

**Issue**: <non-exploitable summary>
**Severity**: CRITICAL/HIGH
**Action Required**: Upgrade to v0.18.X immediately
**Fork Height**: <height> (~<timestamp> UTC)
**Downloads**: https://github.com/xwift/xwift/releases/tag/v0.18.X
**SHA256**:
  - xwiftd-linux-x64.tar.gz  <hash>
  - xwiftd-win64.zip         <hash>

**Upgrade Steps**:
1. Stop xwiftd
2. Backup data dir
3. Replace binary
4. Restart node
5. Confirm version via `./xwiftd --version`

**Support**: Discord #emergency-support | emergency@xwift.network

Do NOT download binaries from unofficial links.
```

### Messaging Do’s & Don’ts
- ✅ Be transparent about severity without exposing exploit details.  
- ✅ Provide exact instructions and deadlines.  
- ✅ Update hourly until fork completes.  
- ❌ Do not reveal proof-of-concept code until post-mortem.  
- ❌ Avoid blaming individuals publicly.

---

## Rollback Procedures

If the emergency fork introduces regressions or fails to activate correctly, follow this sequence:

### 1. Trigger Conditions
- Fork activation fails (chain stalls).  
- Severe regression discovered post-release (e.g., crash, consensus bug).  
- Vulnerability persists after fork.  
- Adoption below 60% near activation height.

### 2. Immediate Actions
1. IC declares rollback plan in incident channel.  
2. Freeze new block production: instruct pools/validators to halt mining temporarily.  
3. Publish advisory (private first, then public) with clear instructions.

### 3. Rollback Options
- **Option A: Delay Fork Height**  
  - Release patch with new height (e.g., +1,000 blocks).  
  - Maintain same version, just extend buffer.  
- **Option B: Revert to Previous Version**  
  - Re-release prior stable binary, instruct nodes to downgrade.  
  - Use checkpoints to lock canonical chain.  
- **Option C: Hard Reset** (Extreme)  
  - Pause network, reset to block before incident, replay transactions manually.  
  - Requires unanimous community consent and public transparency.

### 4. Rollback Checklist
- [ ] Decision documented with timestamps.  
- [ ] Updated binaries released.  
- [ ] Exchanges/pools acknowledged instructions.  
- [ ] Network health verified post-rollback.  
- [ ] Incident timeline updated.  
- [ ] Post-mortem includes rollback rationale.

---

## Validator Coordination Steps

### Goals
- Ensure ≥80% of validating hashrate upgrades before fork height.  
- Provide deterministic instructions to avoid accidental chain splits.  
- Collect acknowledgements from each validator/pool.

### Step-by-Step
1. **Create Tracking Sheet** (`validators_emergency_<date>.xlsx`). Columns: operator, contact, version reported, acknowledgement time, notes.  
2. **Send Priority Alert** (Signal/Matrix) with:  
   - Summary of issue, severity, fork height, download link, checksum.  
   - Deadline for acknowledgement (e.g., 60 minutes).  
3. **Office Hours Call**: Host optional Zoom/Discord call for validators to ask questions.  
4. **Verification**: Use script below to confirm remote nodes upgraded.  
5. **Fallback**: If validator unreachable, temporarily reduce trust (e.g., remove from seed list) or request they halt block production until upgrade complete.

### Validator Upgrade Script
```bash
#!/bin/bash
# validator_check.sh - Verify peer versions before fork

PEERS=(
  "pool1.xwift.network:19081"
  "pool2.xwift.network:19081"
  "validator-a.xwift.network:19081"
)
TARGET_VERSION="v0.18.3-emergency"

for peer in "${PEERS[@]}"; do
  echo "Checking $peer"
  curl -s http://$peer/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' \
       -H 'Content-Type: application/json' \
       | jq '{host: "'$peer'", version: .result.version}'
  # Compare version strings and alert if mismatch
  VERSION=$(curl -s http://$peer/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json' | jq -r '.result.version')
  if [[ "$VERSION" != *"$TARGET_VERSION"* ]]; then
    echo "⚠️  $peer not on $TARGET_VERSION (reported $VERSION)"
  else
    echo "✅  $peer upgraded"
  fi
done
```

### Upgrade Confirmation Template
```
Subject: [ACTION REQUIRED] Upgrade to XWIFT v0.18.3-emergency

Hi <validator>,

A critical vulnerability requires an emergency fork at block <height> (~<time UTC>). 
Please:
1. Download v0.18.3-emergency binaries (link + checksum)
2. Stop current daemon
3. Backup data directory
4. Replace binaries
5. Restart and confirm version via `./xwiftd --version`

Reply with:
- Node hostname/IP
- Version output
- Estimated time upgrade completed

Thank you for keeping the network secure.
— XWIFT Core Team
```

---

## Technical Appendix

### Common Commands
```bash
# Check blockchain status
./xwiftd print_height
./xwiftd status

# Examine problematic blocks
./xwiftd print_block <height>
./xwiftd print_bc <start_height> <count>

# View alt chains / forks
./xwiftd alt_chain_info

# Monitor peers
./xwiftd print_cn | head -40

# Build release binary
make clean
make release -j$(nproc)
./build/release/bin/xwiftd --version

# Generate checksums
sha256sum build/release/bin/xwiftd > SHA256SUMS
sha256sum build/release/bin/xwift-wallet-cli >> SHA256SUMS
sha256sum build/release/bin/xwift-wallet-rpc >> SHA256SUMS

# Tag release
git tag -a v0.18.3-emergency -m "Emergency fix for <issue>"
git push origin v0.18.3-emergency
```

### Fork Height Table Management
```cpp
// src/cryptonote_core/blockchain.cpp
static const hard_fork_t hard_forks[] = {
  { 1, 1, 0, 0 },
  // ... existing entries ...
  { 16, HF_EMERGENCY_FORK_HEIGHT, 0, 0 },
};
```

### Checklist: Binary Release
- [ ] Update version numbers in `CMakeLists.txt`.  
- [ ] Update release notes (issue summary, fork height, upgrade steps).  
- [ ] Upload binaries + SHA256 + GPG signatures.  
- [ ] Mirror to CDN.  
- [ ] Verify download links.  
- [ ] Provide Docker image if applicable.

---

## Post-Incident Checklist

| Task | Owner | Deadline |
|------|-------|----------|
| **1. Incident Timeline** | IC | +24 hrs |
| **2. Root Cause Analysis** | TL + security | +48 hrs |
| **3. Post-Mortem Report** | IC + Comms | +72 hrs |
| **4. Code Cleanup** | Dev team | +1 week |
| **5. Documentation Updates** | Docs lead | +1 week |
| **6. Lessons Learned Meeting** | All stakeholders | +1 week |
| **7. Community Update** | Comms | After post-mortem |

### Post-Mortem Template
```markdown
# Emergency Fork Post-Mortem

## Summary
- Date/Time
- Severity
- Fork Height & Version
- Issue Description

## Timeline
- HH:MM — Event detection
- HH:MM — Incident channel opened
- HH:MM — Decision to fork
- HH:MM — Binaries released
- HH:MM — Fork activated

## Impact
- Affected components
- Lost funds? (Y/N)
- Downtime

## Root Cause
- Technical explanation

## Mitigations
- Immediate fixes
- Longer-term action items

## Action Items
- [ ] Item 1 (Owner, Due date)
- [ ] Item 2
```

---

**Document Maintenance**  
- Store signed copy in repo + share encrypted PDF with core team.  
- Update contact list quarterly or after personnel changes.  
- Run tabletop exercise twice per year using this guide.

For deployment readiness see `DEPLOYMENT_CHECKLIST.md`.  
For consensus parameters see `CONSENSUS_CHANGES_SUMMARY.md`.  
For testnet procedures see `TESTNET_VALIDATION_GUIDE.md`.
