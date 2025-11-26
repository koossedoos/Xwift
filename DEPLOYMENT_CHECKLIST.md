# XWIFT Deployment Checklist

**Purpose**: Comprehensive pre-deployment validation checklist for testnet and mainnet launches  
**Audience**: Core developers, DevOps engineers, launch coordinators  
**Status**: Pre-launch validation protocol  
**Last Updated**: 2025-01-19

---

## 📋 Table of Contents

1. [Pre-Testnet Checklist](#pre-testnet-checklist)
2. [Pre-Mainnet Checklist](#pre-mainnet-checklist)
3. [Binary Build Verification](#binary-build-verification)
4. [Security Audit Checklist](#security-audit-checklist)
5. [Seed Node Deployment](#seed-node-deployment)
6. [Exchange & Wallet Integration](#exchange--wallet-integration)
7. [Launch Day Procedures](#launch-day-procedures)

---

## Pre-Testnet Checklist

### Code Freeze & Preparation

- [ ] **Code Review Complete**
  - All critical components reviewed by ≥2 senior engineers
  - No P0/P1 issues outstanding
  - Consensus logic approved by protocol team
  - Emergency fork procedures documented

- [ ] **Branch Management**
  - Create `testnet` branch from `develop`
  - Tag release candidate (e.g., `v0.18.0-rc1-testnet`)
  - Lock branch (require 2 approvals for merges)

- [ ] **Configuration Verification**
  - Testnet network ID: `58574946540000000000000000000002`
  - Testnet ports: 29080 (P2P), 29081 (RPC), 29082 (ZMQ)
  - Testnet address prefixes: 85/86/87
  - Genesis block: Unique nonce (10004)
  - Difficulty: Set to 1 for genesis (no premine)

### Build & Test

- [ ] **Compile All Platforms**
  - Linux (Ubuntu 20.04, 22.04, Debian 11)
  - macOS (Intel + Apple Silicon)
  - Windows (x64)
  - ARM64 (Raspberry Pi, cloud instances)

- [ ] **Binary Verification**
  - Run `xwiftd --version` on each platform
  - Verify testnet mode enabled
  - Check dependencies linked correctly (`ldd` on Linux)
  - Validate hardened build flags enabled

- [ ] **Unit Tests**
  - All tests pass on all platforms
  - Emission tests validate 72.5M supply
  - Difficulty tests validate 72-block window
  - Timestamp tests validate 15-block median

- [ ] **Integration Tests**
  - Private testnet with 3 nodes mines 1000 blocks
  - Hard fork activation verified
  - Transaction relay works
  - Wallet send/receive validated

### Infrastructure Preparation

- [ ] **Seed Nodes** (minimum 5 required)
  - [ ] Seed 1: `seed1-testnet.xwift.network` (US East)
  - [ ] Seed 2: `seed2-testnet.xwift.network` (EU West)
  - [ ] Seed 3: `seed3-testnet.xwift.network` (Asia Pacific)
  - [ ] Seed 4: `seed4-testnet.xwift.network` (US West)
  - [ ] Seed 5: `seed5-testnet.xwift.network` (EU East)

- [ ] **Monitoring Infrastructure**
  - [ ] Block explorer deployed
  - [ ] RPC monitoring dashboard
  - [ ] Alerting configured (PagerDuty/Slack)
  - [ ] Metrics collection (Prometheus + Grafana)

- [ ] **Testnet Faucet**
  - [ ] Faucet web interface deployed
  - [ ] Rate limiting configured (1 request/hour per IP)
  - [ ] Wallet funded with 10,000 XWIFT
  - [ ] Captcha enabled

### Documentation

- [ ] **Testnet Guide Published**
  - Installation instructions
  - Configuration examples
  - Mining setup
  - Wallet usage
  - Troubleshooting FAQ

- [ ] **Community Announcement**
  - [ ] Discord announcement prepared
  - [ ] Reddit post drafted
  - [ ] Twitter thread ready
  - [ ] GitHub release notes complete

### Go/No-Go Decision

**Testnet Launch Gate (All must be ✅):**
- [ ] All unit tests pass
- [ ] 5+ seed nodes operational
- [ ] Monitoring dashboards live
- [ ] Documentation published
- [ ] Emergency contacts confirmed
- [ ] Lead developer approval
- [ ] DevOps approval

---

## Pre-Mainnet Checklist

### Testnet Validation Complete

- [ ] **Minimum 30 Days of Testnet Operation**
  - Testnet launch date: _______________
  - 30-day milestone: _______________
  - Actual completion date: _______________

- [ ] **Testnet Metrics Achieved**
  - [ ] Block time: 30±5 seconds average
  - [ ] Orphan rate: <5% over 10,000+ blocks
  - [ ] Difficulty adjustments: Smooth response to ±200% hashrate swings
  - [ ] Emission verified: Rewards match expected curve (±0.1%)
  - [ ] Maturity window: Coinbase unlock at exactly 60 blocks
  - [ ] Timestamp validation: Rejects manipulated timestamps
  - [ ] Network stability: >99% uptime
  - [ ] Peak concurrent nodes: >50
  - [ ] Total blocks mined: >100,000

- [ ] **Testnet Issues Resolved**
  - [ ] All P0 bugs fixed
  - [ ] All P1 bugs fixed or documented workarounds
  - [ ] Post-mortem completed for any incidents
  - [ ] No consensus splits in last 14 days

### Security Audit

- [ ] **External Security Audit Complete**
  - [ ] Auditor: _______________
  - [ ] Audit start date: _______________
  - [ ] Audit completion date: _______________
  - [ ] Audit report published: _______________

- [ ] **Audit Findings Addressed**
  - [ ] Critical findings: 0 outstanding
  - [ ] High findings: 0 outstanding
  - [ ] Medium findings: _____ outstanding (documented)
  - [ ] Low findings: Acknowledged

- [ ] **Internal Code Review**
  - [ ] Consensus logic reviewed by ≥3 engineers
  - [ ] Cryptographic implementations verified
  - [ ] Memory safety validated (Valgrind, AddressSanitizer)
  - [ ] Fuzzing run for 72+ hours (no crashes)

### Code Freeze & Release

- [ ] **Mainnet Branch Preparation**
  - Create `mainnet` branch from tested `testnet` branch
  - Update network ID to mainnet (last byte `01`)
  - Update ports to 19080/19081/19082
  - Update address prefixes to 65/66/67
  - Update genesis transaction and nonce (10003)
  - Remove testnet-only debug flags

- [ ] **Version Tagging**
  - [ ] Tag release: `v0.18.0`
  - [ ] Sign tag with GPG key
  - [ ] Create GitHub release
  - [ ] Upload binaries + SHA256SUMS
  - [ ] Sign SHA256SUMS with GPG

- [ ] **Release Notes**
  - [ ] Changelog complete
  - [ ] Upgrade instructions clear
  - [ ] Known issues documented
  - [ ] Credits and acknowledgments included

### Binary Build Verification (See Section Below)

- [ ] All platforms built successfully
- [ ] Checksums generated and signed
- [ ] Deterministic build verification (Gitian)
- [ ] Binaries uploaded to official sources only

### Infrastructure

- [ ] **Mainnet Seed Nodes** (minimum 10 required)
  - [ ] `seed1.xwift.network` (US East)
  - [ ] `seed2.xwift.network` (EU West)
  - [ ] `seed3.xwift.network` (Asia Pacific)
  - [ ] `seed4.xwift.network` (US West)
  - [ ] `seed5.xwift.network` (EU East)
  - [ ] `seed6.xwift.network` (South America)
  - [ ] `seed7.xwift.network` (Asia East)
  - [ ] `seed8.xwift.network` (Africa)
  - [ ] `seed9.xwift.network` (Oceania)
  - [ ] `seed10.xwift.network` (EU North)

- [ ] **Monitoring & Observability**
  - [ ] Production monitoring dashboards
  - [ ] 24/7 on-call rotation established
  - [ ] Incident response runbooks prepared
  - [ ] Emergency contact list updated
  - [ ] Status page configured (status.xwift.network)

- [ ] **Block Explorer**
  - [ ] Mainnet explorer deployed
  - [ ] API endpoints tested
  - [ ] Search functionality validated
  - [ ] Mobile responsive

- [ ] **Official Website**
  - [ ] Download page with mainnet binaries
  - [ ] Documentation updated
  - [ ] FAQ reflects mainnet
  - [ ] Community links active

### Legal & Compliance

- [ ] **Legal Review Complete**
  - [ ] Terms of Service finalized
  - [ ] Privacy Policy published
  - [ ] Disclaimer prominent on website
  - [ ] No securities law violations (fair launch, no premine, no ICO)

- [ ] **Trademark & Branding**
  - [ ] Trademark application filed (if applicable)
  - [ ] Logo and brand assets finalized
  - [ ] Brand guidelines published

### Community Preparation

- [ ] **Communication Channels Active**
  - [ ] Discord server >500 members
  - [ ] Telegram channel operational
  - [ ] Reddit community r/xwift created
  - [ ] Twitter account @xwift_official active
  - [ ] GitHub Discussions enabled

- [ ] **Launch Announcement Prepared**
  - [ ] Blog post drafted
  - [ ] Social media content scheduled
  - [ ] Press release (if applicable)
  - [ ] Community AMA scheduled

- [ ] **Educational Content**
  - [ ] Mining guide published
  - [ ] Wallet setup guide published
  - [ ] Video tutorials (optional but recommended)
  - [ ] FAQ covers common questions

### Go/No-Go Decision

**Mainnet Launch Gate (All must be ✅):**
- [ ] 30+ days testnet operation successful
- [ ] Security audit complete, criticals resolved
- [ ] 10+ seed nodes operational
- [ ] Monitoring infrastructure ready
- [ ] Emergency procedures tested
- [ ] Community prepared (>500 Discord members)
- [ ] Legal review complete
- [ ] Lead developer approval
- [ ] Protocol team approval
- [ ] Community council approval

---

## Binary Build Verification

### Build Environment Setup

#### Linux (Ubuntu 20.04)
```bash
# Install dependencies
sudo apt update
sudo apt install -y build-essential cmake pkg-config \
    libboost-all-dev libssl-dev libzmq3-dev libunbound-dev \
    libsodium-dev libunwind8-dev liblzma-dev libreadline-dev \
    libexpat1-dev libgtest-dev doxygen graphviz libhidapi-dev \
    libusb-1.0-0-dev libprotobuf-dev protobuf-compiler

# Clone and build
git clone https://github.com/xwift/xwift.git
cd xwift
git checkout v0.18.0  # Replace with actual tag
git submodule update --init --recursive

# Build release
make clean
make release -j$(nproc)

# Generate checksum
sha256sum build/release/bin/xwiftd > SHA256SUMS.linux
sha256sum build/release/bin/xwift-wallet-cli >> SHA256SUMS.linux
sha256sum build/release/bin/xwift-wallet-rpc >> SHA256SUMS.linux

# Sign checksum
gpg --detach-sign --armor SHA256SUMS.linux
```

#### macOS (Homebrew)
```bash
# Install dependencies
brew install boost openssl@3 zmq libsodium unbound pkg-config cmake

# Clone and build
git clone https://github.com/xwift/xwift.git
cd xwift
git checkout v0.18.0
git submodule update --init --recursive

# Build
make clean
make release -j$(sysctl -n hw.ncpu)

# Generate checksum
shasum -a 256 build/release/bin/xwiftd > SHA256SUMS.macos
shasum -a 256 build/release/bin/xwift-wallet-cli >> SHA256SUMS.macos
shasum -a 256 build/release/bin/xwift-wallet-rpc >> SHA256SUMS.macos

# Sign
gpg --detach-sign --armor SHA256SUMS.macos
```

#### Windows (MSYS2)
```bash
# In MSYS2 MinGW 64-bit terminal
pacman -Syu
pacman -S mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake \
    mingw-w64-x86_64-boost mingw-w64-x86_64-openssl \
    mingw-w64-x86_64-zeromq mingw-w64-x86_64-libsodium \
    mingw-w64-x86_64-hidapi git

# Clone and build
git clone https://github.com/xwift/xwift.git
cd xwift
git checkout v0.18.0
git submodule update --init --recursive

# Build
make release-static-win64 -j$(nproc)

# Generate checksum (in PowerShell)
Get-FileHash build/release/bin/xwiftd.exe -Algorithm SHA256 > SHA256SUMS.windows
Get-FileHash build/release/bin/xwift-wallet-cli.exe -Algorithm SHA256 >> SHA256SUMS.windows
```

### Verification Checklist

- [ ] **All Binaries Built Successfully**
  - [ ] Linux x86_64
  - [ ] macOS x86_64 (Intel)
  - [ ] macOS ARM64 (Apple Silicon)
  - [ ] Windows x64
  - [ ] Linux ARM64 (optional)

- [ ] **Binary Smoke Tests**
  ```bash
  # Test version
  ./xwiftd --version
  
  # Expected output:
  # Xwift 'Helium Hydra' (v0.18.0-release)
  # Mainnet (network ID: 58574946540000000000000000000001)
  
  # Test help
  ./xwiftd --help
  
  # Test wallet
  ./xwift-wallet-cli --version
  ```

- [ ] **Checksums Generated**
  - [ ] SHA256SUMS file created
  - [ ] All binaries included
  - [ ] GPG signature created
  - [ ] Signature verified locally

- [ ] **Deterministic Build (Gitian/Guix)**
  - [ ] At least 3 developers build independently
  - [ ] All checksums match
  - [ ] Publish builder attestations

- [ ] **Upload to Official Sources**
  - [ ] GitHub Releases
  - [ ] Official website (xwift.network/downloads)
  - [ ] Mirror servers (if applicable)
  - [ ] **DO NOT** upload to unofficial sources

---

## Security Audit Checklist

### Pre-Audit Preparation

- [ ] **Scope Definition**
  - [ ] Consensus logic
  - [ ] Cryptographic implementations
  - [ ] Network protocol
  - [ ] Wallet security
  - [ ] RPC API endpoints

- [ ] **Documentation Provided to Auditors**
  - [ ] Architecture overview
  - [ ] Threat model
  - [ ] Code comments and inline docs
  - [ ] Consensus changes summary
  - [ ] Known issues and mitigations

- [ ] **Test Suite Access**
  - [ ] Unit tests
  - [ ] Integration tests
  - [ ] Fuzzing corpus
  - [ ] Testnet access credentials

### Audit Execution

- [ ] **Kickoff Meeting Completed**
  - Auditors briefed on XWIFT-specific changes
  - Questions answered
  - Timeline confirmed

- [ ] **Weekly Status Calls**
  - Track progress
  - Address auditor questions
  - Preliminary findings reviewed

- [ ] **Remediation Sprints**
  - Critical findings fixed immediately
  - High findings prioritized
  - Fixes validated by auditors

### Post-Audit

- [ ] **Final Report Received**
  - All findings documented
  - Severity levels assigned
  - Recommendations provided

- [ ] **Remediation Complete**
  - Critical: 100% fixed
  - High: 100% fixed or documented accepted risk
  - Medium: ≥80% fixed
  - Low: Acknowledged

- [ ] **Public Disclosure**
  - [ ] Audit report published (after remediation)
  - [ ] Summary blog post
  - [ ] Community announcement

---

## Seed Node Deployment

### Hardware Requirements

**Seed Node Spec:**
- CPU: 4+ cores
- RAM: 8 GB minimum
- Storage: 200 GB SSD
- Network: 1 Gbps, <50ms global latency
- Uptime SLA: 99.9%

### Deployment Steps

#### 1. Provision Server
```bash
# Example: AWS EC2 t3.large or equivalent
# Ubuntu 22.04 LTS
# EBS: 200 GB gp3
# Security group: Allow 19080/tcp (P2P), 19081/tcp (RPC optional)
```

#### 2. Install XWIFT
```bash
# Add user
sudo adduser xwift
sudo usermod -aG sudo xwift
su - xwift

# Download and verify binary
wget https://github.com/xwift/xwift/releases/download/v0.18.0/xwift-linux-x64-v0.18.0.tar.gz
wget https://github.com/xwift/xwift/releases/download/v0.18.0/SHA256SUMS
wget https://github.com/xwift/xwift/releases/download/v0.18.0/SHA256SUMS.asc

# Verify signature
gpg --import xwift-release-key.asc
gpg --verify SHA256SUMS.asc SHA256SUMS
sha256sum -c SHA256SUMS

# Extract
tar -xvf xwift-linux-x64-v0.18.0.tar.gz
sudo mv xwift-linux-x64-v0.18.0/xwiftd /usr/local/bin/
sudo chmod +x /usr/local/bin/xwiftd
```

#### 3. Configure Systemd Service
```bash
sudo tee /etc/systemd/system/xwiftd.service > /dev/null <<EOF
[Unit]
Description=XWIFT Daemon (Mainnet Seed Node)
After=network.target

[Service]
Type=forking
PIDFile=/home/xwift/.xwift/xwiftd.pid
User=xwift
Group=xwift

ExecStart=/usr/local/bin/xwiftd \\
    --data-dir /home/xwift/.xwift \\
    --log-file /home/xwift/.xwift/xwiftd.log \\
    --log-level 1 \\
    --max-concurrency 4 \\
    --p2p-bind-ip 0.0.0.0 \\
    --p2p-bind-port 19080 \\
    --rpc-bind-ip 127.0.0.1 \\
    --rpc-bind-port 19081 \\
    --confirm-external-bind \\
    --detach

Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable xwiftd
sudo systemctl start xwiftd
```

#### 4. Verify Operation
```bash
# Check status
sudo systemctl status xwiftd

# Check logs
tail -f ~/.xwift/xwiftd.log

# Check sync progress
xwiftd print_height
xwiftd print_cn
```

### Seed Node Checklist (Per Node)

- [ ] **Server Provisioned**
  - [ ] Hostname: _______________
  - [ ] IP Address: _______________
  - [ ] DNS Record: seed#.xwift.network

- [ ] **XWIFT Installed**
  - [ ] Binary verified
  - [ ] Systemd service configured
  - [ ] Auto-restart enabled

- [ ] **Monitoring Configured**
  - [ ] Health check endpoint enabled
  - [ ] Prometheus exporter (if using)
  - [ ] Alerting configured

- [ ] **Network Validated**
  - [ ] Port 19080 reachable globally
  - [ ] Connected to 16+ peers
  - [ ] Block sync complete

- [ ] **Backup Configured**
  - [ ] Blockchain data backed up daily (optional, fast sync available)
  - [ ] Configuration backed up

---

## Exchange & Wallet Integration

### Exchange Integration Guide

#### Pre-Integration

- [ ] **Technical Documentation Provided**
  - [ ] RPC API documentation
  - [ ] Address format specification
  - [ ] Confirmation requirements (60 blocks)
  - [ ] Fee recommendations

- [ ] **Testnet Testing**
  - [ ] Exchange tests deposits/withdrawals on testnet
  - [ ] Edge cases validated (reorgs, pending txs)
  - [ ] Performance tested (high volume)

#### Integration Checklist (Per Exchange)

- [ ] **Exchange Name**: _______________
- [ ] **Contact**: _______________
- [ ] **Status**: [ ] In Progress [ ] Complete

**Technical Requirements:**
- [ ] Node deployed (dedicated, not shared)
- [ ] `xwift-wallet-rpc` configured
- [ ] Deposit detection working (60 confirmations)
- [ ] Withdrawal processing working
- [ ] Address validation implemented
- [ ] Fee calculation correct (0.002 XWIFT/kB minimum)
- [ ] Testnet testing completed
- [ ] Mainnet testing with small amounts

**Operational Requirements:**
- [ ] Hot wallet secured (minimal balance)
- [ ] Cold wallet setup (multisig recommended)
- [ ] Withdrawal limits configured
- [ ] Monitoring and alerting
- [ ] Support team trained

### Wallet Integration Guide

#### Desktop/Mobile Wallet Providers

**Integration Checklist (Per Wallet):**
- [ ] **Wallet Name**: _______________
- [ ] **Platform**: [ ] Desktop [ ] Mobile [ ] Web
- [ ] **Contact**: _______________

**Technical Requirements:**
- [ ] XWIFT daemon integration or light wallet mode
- [ ] Address generation (prefix 65/66/67)
- [ ] Transaction creation with correct fees
- [ ] 8 decimal place support
- [ ] Balance calculation correct
- [ ] Transaction history parsing
- [ ] QR code support

**Testing:**
- [ ] Testnet integration completed
- [ ] Send/receive validated
- [ ] Fee estimation accurate
- [ ] Backup/restore working
- [ ] Mainnet beta testing

---

## Launch Day Procedures

### T-24 Hours: Final Preparations

- [ ] **Final Checks**
  - [ ] All seed nodes online and synced (genesis block only)
  - [ ] Monitoring dashboards operational
  - [ ] On-call team confirmed
  - [ ] Emergency contact list verified
  - [ ] Status page ready

- [ ] **Communication Prep**
  - [ ] Launch announcement ready (do not publish)
  - [ ] Social media posts scheduled
  - [ ] Discord/Telegram pinned messages drafted
  - [ ] FAQ updated

### T-12 Hours: Team Briefing

- [ ] **Launch Team Call**
  - Review timeline
  - Confirm roles and responsibilities
  - Test emergency communication channels
  - Review rollback procedures (if needed)

### T-1 Hour: Final Countdown

- [ ] **Launch Checklist**
  - [ ] Binaries uploaded and accessible
  - [ ] Checksums published
  - [ ] Documentation live
  - [ ] Monitoring dashboards confirmed
  - [ ] Team in standby mode

### T-0: Genesis Block

- [ ] **Announce Launch**
  - [ ] Publish GitHub release
  - [ ] Tweet launch announcement
  - [ ] Post to Discord/Telegram/Reddit
  - [ ] Update website banner

- [ ] **Monitor Genesis**
  - [ ] First block mined
  - [ ] Seed nodes connecting to each other
  - [ ] Community nodes joining network
  - [ ] No errors in logs

### T+1 Hour: Initial Monitoring

- [ ] **Network Health**
  - [ ] 10+ nodes connected
  - [ ] Blocks being produced
  - [ ] Difficulty adjusting (initially low)
  - [ ] No consensus errors

### T+6 Hours: Stability Check

- [ ] **Metrics Review**
  - [ ] 720+ blocks mined
  - [ ] Average block time near 30 seconds
  - [ ] Peer count growing
  - [ ] Transaction pool functional

- [ ] **Community Support**
  - [ ] Active monitoring of Discord/Telegram
  - [ ] Respond to setup questions
  - [ ] Address any early issues

### T+24 Hours: Post-Launch Review

- [ ] **24-Hour Metrics**
  - [ ] ~2,880 blocks mined
  - [ ] 50+ active nodes
  - [ ] Orphan rate measured
  - [ ] No critical issues

- [ ] **Team Retrospective**
  - What went well
  - What could be improved
  - Action items for next phase

### T+7 Days: First Week Review

- [ ] **Network Stability Report**
  - [ ] Block time analysis
  - [ ] Orphan rate analysis
  - [ ] Difficulty adjustment review
  - [ ] Peer distribution geographic map

- [ ] **Community Growth**
  - [ ] Active miners count
  - [ ] Discord/Telegram member growth
  - [ ] GitHub stars/watchers
  - [ ] Block explorer traffic

- [ ] **Issues Log**
  - [ ] Document all reported issues
  - [ ] Prioritize bug fixes
  - [ ] Plan patch release if needed (v0.18.1)

---

## Emergency Contacts

### Core Team

- **Lead Developer**: _______________  
- **Protocol Engineer**: _______________  
- **DevOps Lead**: _______________  
- **Community Manager**: _______________

### External Partners

- **Security Auditor**: _______________  
- **Infrastructure Provider**: _______________  
- **Emergency Hotline**: _______________

### Communication Channels

- **Emergency Slack/Discord**: #emergency-response (private)  
- **Status Page**: status.xwift.network  
- **Public Announcements**: Discord #announcements, Twitter @xwift_official

---

## Post-Launch Monitoring

### Daily Monitoring (First 30 Days)

- [ ] Block time average
- [ ] Orphan rate
- [ ] Node count
- [ ] Hash rate
- [ ] Difficulty adjustments
- [ ] Transaction volume
- [ ] Seed node health
- [ ] No consensus errors

### Weekly Reporting

- [ ] Network health report published
- [ ] Community update posted
- [ ] Issue tracker reviewed
- [ ] Patch planning (if needed)

### Monthly Milestones

- [ ] 1-month anniversary post
- [ ] Exchange listing announcements
- [ ] Ecosystem growth metrics
- [ ] Roadmap progress update

---

**Document Version**: 1.0  
**Next Review**: Post-mainnet launch retrospective  
**Maintainers**: Launch Coordination Team (launch@xwift.network)

For emergency procedures, see `EMERGENCY_FORK_GUIDE.md`.  
For testnet validation, see `TESTNET_VALIDATION_GUIDE.md`.  
For consensus details, see `CONSENSUS_CHANGES_SUMMARY.md`.
