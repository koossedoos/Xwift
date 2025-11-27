# Upgrade to VPS - Migration Plan

## Overview

After successfully validating Xwift on your local testnet, you may want to deploy nodes to VPS infrastructure for 24/7 mainnet operation or public testnet participation.

This guide outlines how to transition from local Docker testnet to VPS-hosted nodes.

---

## Prerequisites

Before migrating:

✅ **Local testnet validated** (at least 7-14 days of testing)
✅ **Budget allocated** for VPS costs (~$20-40/month per node)
✅ **Domain name** (optional, for easier node access)
✅ **SSH key pair** configured for secure access

---

## Cost Estimates

### VPS Provider Comparison

| Provider     | vCPUs | RAM  | Storage | Bandwidth | Cost/month |
|--------------|-------|------|---------|-----------|------------|
| Hetzner      | 2     | 4GB  | 80GB    | 20TB      | €4.51 (~$5)  |
| Contabo      | 4     | 8GB  | 200GB   | 32TB      | €6.99 (~$8)  |
| DigitalOcean | 2     | 4GB  | 80GB    | 4TB       | $24        |
| AWS Lightsail| 2     | 4GB  | 80GB    | 4TB       | $24        |
| Vultr        | 2     | 4GB  | 80GB    | 3TB       | $18        |

**Recommendation:** Hetzner or Contabo for best value.

### Total Monthly Cost (4 nodes)

- **Budget**: $20-$32/month (Hetzner/Contabo)
- **Premium**: $72-$96/month (DigitalOcean/Vultr)

---

## Architecture Planning

### Option 1: Hybrid (Local + VPS)

Keep local mining node, add 3 VPS seed nodes:

**Advantages:**
- Lower cost ($15-25/month)
- Local node stays under your control
- VPS nodes for public P2P network participation

**Disadvantages:**
- Home IP exposure (use firewall)
- Local node downtime affects your network presence

---

### Option 2: Full VPS Deployment

All 4 nodes on VPS:

**Advantages:**
- 24/7 uptime
- Better network connectivity
- Independent of home internet

**Disadvantages:**
- Higher cost ($40-80/month)
- Less direct control

---

### Option 3: Gradual Migration

Start with 1 VPS seed node, scale up:

**Phase 1:** 3 local + 1 VPS seed  
**Phase 2:** 2 local + 2 VPS seeds  
**Phase 3:** 1 local + 3 VPS (or 4 VPS)

---

## Step-by-Step Migration

### Step 1: Provision VPS

Example using Hetzner:

1. Create account at https://www.hetzner.com/cloud
2. Deploy a CPX11 instance (2 vCPU, 4GB RAM, 80GB SSD)
   - Location: Choose closest to your users
   - Image: Ubuntu 22.04 LTS
   - Add SSH key
3. Note the public IP address

Repeat for each VPS node you want.

---

### Step 2: Initial VPS Setup

SSH into each VPS:

```bash
ssh root@<VPS_IP>

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install -y docker-compose-plugin

# Create xwift user
useradd -m -s /bin/bash xwift
usermod -aG docker xwift

# Set up firewall
ufw allow 22/tcp      # SSH
ufw allow 19080/tcp   # Xwift P2P (mainnet)
ufw allow 29080/tcp   # Xwift P2P (testnet)
ufw --force enable
```

---

### Step 3: Deploy Xwift on VPS

Transfer configuration to VPS:

```bash
# On your local machine
cd /path/to/xwift/local-testnet

# Create VPS deployment directory
ssh xwift@<VPS_IP> "mkdir -p ~/xwift-node"

# Copy configs
scp -r configs/* xwift@<VPS_IP>:~/xwift-node/
scp docker-compose.yml xwift@<VPS_IP>:~/xwift-node/
scp -r ../Dockerfile.testnet xwift@<VPS_IP>:~/xwift-node/
```

---

### Step 4: Modify Configuration for VPS

SSH into VPS and edit configs:

```bash
ssh xwift@<VPS_IP>
cd ~/xwift-node

# Edit seed node config
nano configs/seed1-testnet.conf
```

Changes needed:

```ini
# Replace Docker internal IP with VPS public IP
p2p-external-port=29080

# Update seed nodes to VPS IPs instead of 172.25.0.x
add-priority-node=<VPS2_PUBLIC_IP>:29080
add-priority-node=<VPS3_PUBLIC_IP>:29080
add-priority-node=<LOCAL_PUBLIC_IP>:29086    # If keeping local mining node

# For mainnet, change:
testnet=0
# And update all ports: 29080 -> 19080, etc.
```

---

### Step 5: Launch VPS Node

```bash
# On VPS
cd ~/xwift-node

# Build image
docker build -f Dockerfile.testnet -t xwift:testnet .

# Start single seed node (don't use full docker-compose)
docker run -d \
  --name xwift-seed-vps \
  --restart unless-stopped \
  -p 29080:29080 \
  -p 29081:29081 \
  -v ~/xwift-node/data:/home/xwift/.xwift \
  -v ~/xwift-node/configs/seed1-testnet.conf:/config/testnet.conf:ro \
  xwift:testnet \
  --config-file /config/testnet.conf
```

---

### Step 6: Update Local Nodes

Update local testnet to connect to VPS nodes:

```bash
# Edit local-testnet/configs/seed1-testnet.conf
nano local-testnet/configs/seed1-testnet.conf

# Add VPS nodes to priority list:
add-priority-node=<VPS1_IP>:29080
add-priority-node=<VPS2_IP>:29080

# Restart local testnet
./stop-testnet.sh
./start-testnet.sh
```

---

### Step 7: Monitoring VPS Nodes

Set up monitoring on VPS:

```bash
# On VPS
cd ~/xwift-node

# Create monitoring script
cat > check-node.sh <<'EOF'
#!/bin/bash
curl -s http://localhost:29081/get_info | jq '.height, .outgoing_connections_count'
EOF

chmod +x check-node.sh

# Add to crontab (every 5 minutes)
crontab -e
# Add: */5 * * * * ~/xwift-node/check-node.sh >> ~/xwift-node/health.log
```

---

### Step 8: Mainnet vs Testnet

To switch from testnet to mainnet on VPS:

1. Update configs:
```ini
# Change testnet=1 to:
testnet=0

# Update ports:
# 29080 -> 19080 (P2P)
# 29081 -> 19081 (RPC)
# 29082 -> 19082 (ZMQ)
```

2. Update firewall:
```bash
ufw allow 19080/tcp
```

3. Restart node with new config

---

## Security Best Practices

### SSH Hardening

```bash
# Disable root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Disable password auth (SSH keys only)
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH
sudo systemctl restart sshd
```

### Firewall Configuration

```bash
# Default deny
ufw default deny incoming
ufw default allow outgoing

# Allow only necessary ports
ufw allow 22/tcp       # SSH (consider changing default port)
ufw allow 19080/tcp    # Xwift P2P
# Do NOT open RPC port 19081 to public

ufw enable
```

### Automatic Updates

```bash
# Install unattended-upgrades
sudo apt install -y unattended-upgrades

# Enable
sudo dpkg-reconfigure -plow unattended-upgrades
```

---

## Monitoring & Maintenance

### Set Up Monitoring

Options:
1. **Prometheus + Grafana**: Full metrics stack
2. **Netdata**: Simple, real-time monitoring
3. **UptimeRobot**: External uptime monitoring (free tier available)

### Backup Strategy

```bash
# On VPS, create backup script
cat > ~/backup-blockchain.sh <<'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d)
tar -czf ~/backups/xwift-data-$DATE.tar.gz ~/xwift-node/data
find ~/backups -name "xwift-data-*.tar.gz" -mtime +7 -delete
EOF

chmod +x ~/backup-blockchain.sh

# Schedule weekly backups
crontab -e
# Add: 0 2 * * 0 ~/backup-blockchain.sh
```

---

## Cost Optimization

### Tips to Reduce Costs

1. **Use smaller VPS for seed nodes** (1 vCPU, 2GB RAM sufficient for non-mining)
2. **Shared VPS for multiple seed nodes** (if provider allows multiple IPs)
3. **Prune blockchain data** (if Xwift supports it)
4. **Snapshot VPS state** before major changes (avoid rebuild costs)

---

## Rollback Plan

If VPS deployment fails, you can always return to local testnet:

```bash
# Stop VPS nodes
ssh xwift@<VPS_IP> "docker stop xwift-seed-vps"

# Restart local testnet
cd local-testnet
./start-testnet.sh
```

Local testnet is preserved and ready to use anytime.

---

## Next Steps

1. ✅ Validate local testnet for 7-14 days
2. ✅ Choose VPS provider and plan
3. ✅ Deploy first VPS seed node
4. ✅ Connect local and VPS nodes
5. ✅ Monitor for 24-48 hours
6. ✅ Scale up to additional VPS nodes
7. ✅ Switch to mainnet when ready

---

## Support Resources

- VPS Provider Docs:
  - Hetzner: https://docs.hetzner.com/cloud/
  - Contabo: https://contabo.com/en/support/
  - DigitalOcean: https://docs.digitalocean.com/

- Xwift Documentation:
  - Main README: `/path/to/xwift/README.md`
  - Local Testnet: `docs/LOCAL_TESTNET_README.md`
