# Xwift Cryptocurrency Deployment Guide

## Overview
This guide covers deploying Xwift (a Monero fork) testnet and mainnet nodes on Ubuntu/Debian systems.

## Critical Fork Customizations Applied

The following customizations have been implemented to create a unique Xwift network:

### Network Identity
- **Name**: Changed from "bitmonero" to "xwift"
- **Windows Service**: Updated to "Xwift Daemon"
- **Message Signing**: Updated to "XwiftMessageSignature"

### Mainnet Configuration
- **Address Prefix**: 65 (standard addresses)
- **Integrated Address Prefix**: 66
- **Subaddress Prefix**: 67
- **Network ID**: `58 57 49 46 54 00 00 00 00 00 00 00 00 00 00 01` (XWIFT network)
- **Ports**: P2P 18080, RPC 18081, ZMQ 18082
- **Genesis Nonce**: 10003

### Testnet Configuration
- **Address Prefix**: 85 (standard addresses)
- **Integrated Address Prefix**: 86
- **Subaddress Prefix**: 87
- **Network ID**: `58 57 49 46 54 00 00 00 00 00 00 00 00 00 00 02` (XWIFT testnet)
- **Ports**: P2P 28080, RPC 28081, ZMQ 28082
- **Genesis Nonce**: 10004

## Prerequisites

### System Requirements
- Ubuntu 18.04+ or Debian 10+
- Minimum 4GB RAM, 8GB+ recommended
- 200GB+ disk space for mainnet blockchain
- 45GB+ disk space for testnet blockchain

### Install Dependencies
```bash
sudo apt update && sudo apt install -y \
    build-essential cmake pkg-config libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libunwind8-dev liblzma-dev \
    libreadline6-dev libexpat1-dev git curl autoconf libtool \
    gperf python3 ccache libboost-dev zlib1g-dev
```

## Deployment Options

### Option 1: Native Build with Systemd (Recommended)

#### 1. Build from Source
```bash
cd Xwift
git submodule init && git submodule update
make release -j$(nproc)
```

#### 2. Install Binaries
```bash
sudo cp build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/xwiftd /usr/local/bin/
sudo cp build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/xwift-wallet-cli /usr/local/bin/
sudo cp build/Linux/compyle_xwift-deploy-testnet-mainnet/release/bin/xwift-wallet-rpc /usr/local/bin/
```

#### 3. Create System User
```bash
sudo adduser --system --group --disabled-password xwift
sudo mkdir -p /var/lib/xwift-testnet /var/lib/xwift-mainnet
sudo mkdir -p /var/log/xwift-testnet /var/log/xwift-mainnet
sudo chown -R xwift:xwift /var/lib/xwift-* /var/log/xwift-*
```

#### 4. Install Systemd Services
```bash
sudo cp utils/systemd/xwift-testnet.service /etc/systemd/system/
sudo cp utils/systemd/xwift-mainnet.service /etc/systemd/system/
sudo cp utils/conf/xwift-testnet.conf /etc/
sudo cp utils/conf/xwift-mainnet.conf /etc/

sudo systemctl daemon-reload
sudo systemctl enable xwift-testnet
sudo systemctl enable xwift-mainnet
sudo systemctl start xwift-testnet
sudo systemctl start xwift-mainnet
```

### Option 2: Docker Containers

#### 1. Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

#### 2. Deploy with Docker Compose
```bash
cd Xwift
docker compose up -d
```

## Network Configuration

### Firewall Setup
```bash
# Allow SSH
sudo ufw allow ssh

# Allow Xwift ports
sudo ufw allow 18080/tcp  # Mainnet P2P
sudo ufw allow 18081/tcp  # Mainnet RPC
sudo ufw allow 28080/tcp  # Testnet P2P
sudo ufw allow 28081/tcp  # Testnet RPC

# Enable firewall
sudo ufw enable
```

## Monitoring and Management

### Check Node Status
```bash
# Use the provided monitoring script
./utils/scripts/check-nodes.sh

# Or check manually
curl -s http://localhost:18081/get_info | jq '.height, .difficulty'
curl -s http://localhost:28081/get_info | jq '.height, .difficulty'
```

### View Logs
```bash
# Native installation
sudo journalctl -u xwift-mainnet -f
sudo journalctl -u xwift-testnet -f

# Docker logs
docker logs -f xwift-mainnet
docker logs -f xwift-testnet
```

### Service Management
```bash
# Start/stop services
sudo systemctl start xwift-mainnet
sudo systemctl stop xwift-testnet

# Check status
sudo systemctl status xwift-mainnet
sudo systemctl status xwift-testnet
```

## Wallet Operations

### Create Testnet Wallet
```bash
xwift-wallet-cli --testnet --generate-wallet xwift-test-wallet
```

### Create Mainnet Wallet
```bash
xwift-wallet-cli --generate-wallet xwift-main-wallet
```

## Network Verification

### Verify Network Isolation
The following commands should return different results, confirming network separation:

```bash
# Mainnet genesis block
curl -s http://localhost:19081/get_info | jq '.genesis_block_hash'

# Testnet genesis block
curl -s http://localhost:29081/get_info | jq '.genesis_block_hash'
```

### Verify Address Prefixes
```bash
# Testnet address should start with different prefix than mainnet
xwift-wallet-cli --testnet --address
xwift-wallet-cli --address
```

## Security Considerations

1. **RPC Security**: Nodes are configured with `restricted-rpc=1` for public safety
2. **Network Isolation**: Testnet and mainnet use completely different network IDs
3. **User Permissions**: Services run as non-privileged `xwift` user
4. **Firewall**: Only essential ports are exposed

## Backup Strategy

### Wallet Backups
```bash
# Backup testnet wallets
sudo tar -czf xwift-testnet-wallets-$(date +%Y%m%d).tar.gz /var/lib/xwift-testnet/wallets/

# Backup mainnet wallets
sudo tar -czf xwift-mainnet-wallets-$(date +%Y%m%d).tar.gz /var/lib/xwift-mainnet/wallets/
```

### Configuration Backups
```bash
sudo cp /etc/xwift-*.conf ./backup/
sudo cp /etc/systemd/system/xwift-*.service ./backup/
```

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure ports 18080/18081 and 28080/28081 are available
2. **Permission Errors**: Verify xwift user owns data directories
3. **Network Issues**: Check firewall settings and network connectivity
4. **Disk Space**: Monitor disk usage, blockchain grows over time

### Recovery Commands
```bash
# Reset corrupted blockchain (DESTRUCTIVE)
sudo systemctl stop xwift-mainnet
sudo mv /var/lib/xwift-mainnet /var/lib/xwift-mainnet.backup
sudo mkdir -p /var/lib/xwift-mainnet
sudo chown xwift:xwift /var/lib/xwift-mainnet
sudo systemctl start xwift-mainnet
```

## Performance Optimization

### System Tuning
```bash
# Optimize for SSD storage
echo 'vm.dirty_ratio = 15' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_background_ratio = 5' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Increase file descriptor limits
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf
```

### Node Configuration
Edit `/etc/xwift-mainnet.conf` to add:
```
# Increase peer connections for better sync
out-peers=24
in-peers=12

# Optimize sync speed
block-sync-size=50
```

## Conclusion

Your Xwift cryptocurrency network is now deployed with:
- ✅ Unique network identity (separate from Monero)
- ✅ Independent testnet and mainnet instances
- ✅ Secure configuration and monitoring
- ✅ Both Docker and native deployment options
- ✅ Comprehensive backup and recovery procedures

The network is ready for wallet creation, transaction testing on testnet, and eventual mainnet deployment.