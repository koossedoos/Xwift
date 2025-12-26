# Xwift Cryptocurrency

## Overview
Xwift is a privacy-focused cryptocurrency fork based on Monero, customized with unique network parameters and branding. This deployment provides complete testnet and mainnet infrastructure ready for production use.

## 🚀 Quick Start

### Automated Deployment (Recommended)
```bash
cd Xwift
sudo ./utils/scripts/deploy-xwift.sh
```

### Manual Deployment
Follow the comprehensive guide in [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

## 🌐 Network Configuration

### Mainnet
- **P2P Port**: 19080
- **RPC Port**: 19081
- **ZMQ Port**: 19082
- **Address Prefix**: 65
- **Network ID**: XWIFT unique identifier

### Testnet
- **P2P Port**: 29080
- **RPC Port**: 29081
- **ZMQ Port**: 29082
- **Address Prefix**: 85
- **Network ID**: XWIFT testnet identifier

## 📊 Monitoring & Management

### Check Node Status
```bash
# Quick status check
/usr/local/bin/check-nodes.sh

# Service status
systemctl status xwift-mainnet
systemctl status xwift-testnet
```

### View Logs
```bash
# Mainnet logs
journalctl -u xwift-mainnet -f

# Testnet logs
journalctl -u xwift-testnet -f
```

### RPC Access
```bash
# Mainnet info
curl http://localhost:19081/get_info

# Testnet info
curl http://localhost:29081/get_info
```

## 💼 Wallet Operations

### Create Testnet Wallet
```bash
xwift-wallet-cli --testnet --generate-wallet my-test-wallet
```

### Create Mainnet Wallet
```bash
xwift-wallet-cli --generate-wallet my-main-wallet
```

## 🔧 Configuration Files

- `/etc/xwift-mainnet.conf` - Mainnet configuration
- `/etc/xwift-testnet.conf` - Testnet configuration
- `/var/lib/xwift-mainnet/` - Mainnet blockchain data
- `/var/lib/xwift-testnet/` - Testnet blockchain data

## 🛡️ Security Features

- **Network Isolation**: Separate testnet/mainnet with unique genesis blocks
- **Restricted RPC**: Public nodes run with restricted RPC access
- **Non-privileged User**: Services run as dedicated `xwift` user
- **Firewall Configured**: Only essential ports exposed

## 📁 Project Structure

```
Xwift/
├── src/                          # Core source code
├── utils/
│   ├── systemd/                  # Systemd service files
│   ├── conf/                     # Configuration files
│   └── scripts/                  # Management scripts
├── Dockerfile.mainnet           # Mainnet Docker image
├── Dockerfile.testnet           # Testnet Docker image
├── docker-compose.yml          # Multi-container deployment
├── DEPLOYMENT_GUIDE.md         # Comprehensive deployment guide
└── README_XWIFT.md            # This file
```

## 🔍 Key Fork Customizations

This Xwift implementation includes critical customizations to ensure network independence:

- **Unique Identity**: Changed from "Monero" to "Xwift" branding
- **Network Separation**: Completely separate testnet/mainnet networks
- **Unique Address Prefixes**: Different from Monero's addressing scheme
- **Custom Genesis Blocks**: Independent blockchain genesis
- **Network IDs**: Unique 16-byte network identifiers

## 🐳 Docker Deployment

Alternative deployment using Docker containers:

```bash
cd Xwift
docker compose up -d
```

This creates isolated containers for both testnet and mainnet with persistent volumes.

## 📈 Performance Notes

- **Initial Sync**: 2-3 days on consumer hardware
- **Memory Usage**: 2-4GB RAM during sync, 1-2GB steady state
- **Disk Space**: 200GB+ for mainnet, 45GB+ for testnet
- **Network**: 1-5 MB/s during sync, 100KB/s steady

## 🤝 Support

### Troubleshooting
1. Check service status: `systemctl status xwift-*`
2. View logs: `journalctl -u xwift-* -f`
3. Verify ports: `netstat -tlnp | grep -E ':1908[0-2]|:2908[0-2]'`
4. Monitor resources: `htop`, `df -h`

### Recovery
If blockchain corruption occurs:
```bash
sudo systemctl stop xwift-mainnet
sudo mv /var/lib/xwift-mainnet /var/lib/xwift-mainnet.backup
sudo mkdir -p /var/lib/xwift-mainnet
sudo chown xwift:xwift /var/lib/xwift-mainnet
sudo systemctl start xwift-mainnet
```

## 📜 License

This project maintains compatibility with the original Monero license while incorporating custom network configurations.

## 🎯 Next Steps

1. **Monitor Sync Progress**: Wait for initial blockchain synchronization
2. **Test Transactions**: Use testnet for initial testing
3. **Create Wallets**: Set up secure wallet storage
4. **Configure Additional Security**: Consider VPN/Tor for privacy
5. **Set Up Monitoring**: Implement alerting for node status
6. **Network Participation**: Connect with other Xwift nodes

---

**Your Xwift cryptocurrency network is now operational with both testnet and mainnet instances!** 🎉