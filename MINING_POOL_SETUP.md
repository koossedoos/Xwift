# Xwift Mining Pool Setup Guide

## Overview

This guide provides complete instructions for setting up a production-ready Xwift mining pool using nodejs-pool, the most popular open-source mining pool software for CryptoNote/Monero-based cryptocurrencies.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Mining Pool Stack                     │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Frontend   │  │   API Server │  │ Pool Backend │  │
│  │  (Web UI)    │◄─┤  (REST API)  │◄─┤  (nodejs)    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         │                  │                  │          │
│         └──────────────────┴──────────────────┘          │
│                            │                             │
│                   ┌────────▼─────────┐                   │
│                   │   Redis Cache    │                   │
│                   └────────┬─────────┘                   │
│                            │                             │
│                   ┌────────▼─────────┐                   │
│                   │  Xwift Daemon    │                   │
│                   │  (RPC enabled)   │                   │
│                   └────────┬─────────┘                   │
│                            │                             │
│                   ┌────────▼─────────┐                   │
│                   │ Xwift Wallet RPC │                   │
│                   │  (for payouts)   │                   │
│                   └──────────────────┘                   │
└─────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### System Requirements

**Minimum:**
- 4 CPU cores
- 8GB RAM
- 200GB SSD storage
- Ubuntu 20.04+ or Debian 11+
- Static IP address
- Domain name (e.g., pool.xwift.network)

**Recommended:**
- 8+ CPU cores
- 16GB+ RAM
- 500GB+ NVMe SSD
- 100 Mbps+ internet connection
- DDoS protection (Cloudflare)

### Software Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 16.x
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Install build dependencies
sudo apt install -y build-essential cmake pkg-config libssl-dev \
    libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev \
    liblzma-dev libreadline6-dev libexpat1-dev git redis-server \
    nginx certbot python3-certbot-nginx

# Install PM2 for process management
sudo npm install -g pm2

# Verify installations
node --version   # Should be v16.x.x
npm --version
redis-cli ping   # Should return PONG
```

---

## Part 1: Xwift Daemon Setup

### 1.1 Build Xwift Daemon

```bash
# Clone repository (if not already done)
cd /opt
sudo git clone https://github.com/diamondsteel259/Xwift.git
cd Xwift

# Build daemon
make clean
make release -j$(nproc)

# Install binaries
sudo cp build/release/bin/xwiftd /usr/local/bin/
sudo cp build/release/bin/xwift-wallet-rpc /usr/local/bin/

# Verify
xwiftd --version
```

### 1.2 Configure Daemon for Pool

Create `/etc/xwift-pool-daemon.conf`:

```ini
# Xwift Pool Daemon Configuration
data-dir=/var/lib/xwift-pool
log-file=/var/log/xwift-pool/xwift.log
log-level=0

# Network
p2p-bind-ip=0.0.0.0
p2p-bind-port=19080
rpc-bind-ip=127.0.0.1
rpc-bind-port=19081

# RPC Configuration
restricted-rpc=0
rpc-login=pool:YOUR_SECURE_RPC_PASSWORD_HERE
confirm-external-bind=1

# Performance
max-concurrency=8
db-sync-mode=safe

# Mining
start-mining=0
enable-blocklist=1

# Add your seed nodes here once deployed
# add-priority-node=seed1.xwift.network:19080
# add-priority-node=seed2.xwift.network:19080
```

### 1.3 Create Systemd Service

Create `/etc/systemd/system/xwift-pool-daemon.service`:

```ini
[Unit]
Description=Xwift Pool Daemon
After=network-online.target

[Service]
Type=simple
User=xwift
Group=xwift
ExecStart=/usr/local/bin/xwiftd --config-file /etc/xwift-pool-daemon.conf --non-interactive
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### 1.4 Create User and Directories

```bash
# Create system user
sudo useradd -r -s /bin/bash -m -d /home/xwift xwift

# Create directories
sudo mkdir -p /var/lib/xwift-pool
sudo mkdir -p /var/log/xwift-pool
sudo chown -R xwift:xwift /var/lib/xwift-pool /var/log/xwift-pool

# Enable and start daemon
sudo systemctl daemon-reload
sudo systemctl enable xwift-pool-daemon
sudo systemctl start xwift-pool-daemon

# Check status
sudo systemctl status xwift-pool-daemon
sudo journalctl -u xwift-pool-daemon -f
```

---

## Part 2: Wallet RPC Setup

### 2.1 Create Pool Wallet

```bash
# Generate pool wallet
sudo -u xwift xwift-wallet-cli --generate-new-wallet /home/xwift/pool-wallet

# Follow prompts:
# - Set a strong password
# - Write down 25-word seed phrase (CRITICAL - store securely offline)
# - Note the primary address
```

### 2.2 Configure Wallet RPC

Create `/etc/xwift-pool-wallet.conf`:

```ini
daemon-address=127.0.0.1:19081
daemon-login=pool:YOUR_SECURE_RPC_PASSWORD_HERE
rpc-bind-ip=127.0.0.1
rpc-bind-port=19082
rpc-login=wallet:YOUR_SECURE_WALLET_RPC_PASSWORD_HERE
wallet-file=/home/xwift/pool-wallet
password=YOUR_WALLET_PASSWORD_HERE
log-file=/var/log/xwift-pool/wallet-rpc.log
log-level=0
confirm-external-bind=1
trusted-daemon=1
```

### 2.3 Create Wallet RPC Service

Create `/etc/systemd/system/xwift-pool-wallet.service`:

```ini
[Unit]
Description=Xwift Pool Wallet RPC
After=xwift-pool-daemon.service
Requires=xwift-pool-daemon.service

[Service]
Type=simple
User=xwift
Group=xwift
ExecStart=/usr/local/bin/xwift-wallet-rpc --config-file /etc/xwift-pool-wallet.conf
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### 2.4 Start Wallet RPC

```bash
# Set proper permissions
sudo chown xwift:xwift /home/xwift/pool-wallet*
sudo chmod 600 /etc/xwift-pool-wallet.conf

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable xwift-pool-wallet
sudo systemctl start xwift-pool-wallet

# Check status
sudo systemctl status xwift-pool-wallet
```

---

## Part 3: Mining Pool Software Setup

### 3.1 Install nodejs-pool (Fork for Xwift)

```bash
# Clone nodejs-pool
cd /opt
sudo git clone https://github.com/Snipa22/nodejs-pool.git xwift-pool
cd xwift-pool

# Install dependencies
sudo npm install
```

### 3.2 Configure Pool

Edit `/opt/xwift-pool/config.json`:

```json
{
    "coin": "xwift",
    "symbol": "XFT",
    "coinUnits": 100000000,
    "coinDecimalPlaces": 8,
    "coinDifficultyTarget": 30,

    "logging": {
        "files": {
            "level": "info",
            "directory": "/var/log/xwift-pool",
            "flushInterval": 5
        },
        "console": {
            "level": "info",
            "colors": true
        }
    },

    "poolServer": {
        "enabled": true,
        "clusterForks": "auto",
        "poolAddress": "YOUR_POOL_WALLET_ADDRESS_HERE",
        "intAddressPrefix": 66,
        "subAddressPrefix": 67,
        "blockRefreshInterval": 1000,
        "minerTimeout": 900,
        "sslCert": "/etc/letsencrypt/live/pool.xwift.network/fullchain.pem",
        "sslKey": "/etc/letsencrypt/live/pool.xwift.network/privkey.pem",
        "sslCA": "/etc/letsencrypt/live/pool.xwift.network/chain.pem",
        "ports": [
            {
                "port": 3333,
                "difficulty": 5000,
                "desc": "Low end hardware"
            },
            {
                "port": 4444,
                "difficulty": 15000,
                "desc": "Mid range hardware"
            },
            {
                "port": 5555,
                "difficulty": 50000,
                "desc": "High end hardware"
            },
            {
                "port": 6666,
                "difficulty": 200000,
                "desc": "Mining farms"
            },
            {
                "port": 7777,
                "difficulty": 5000,
                "desc": "SSL Low end",
                "ssl": true
            },
            {
                "port": 8888,
                "difficulty": 15000,
                "desc": "SSL Mid range",
                "ssl": true
            }
        ],
        "varDiff": {
            "minDiff": 2000,
            "maxDiff": 100000000,
            "targetTime": 60,
            "retargetTime": 30,
            "variancePercent": 30,
            "maxJump": 100
        },
        "paymentId": {
            "addressSeparator": "."
        },
        "fixedDiff": {
            "enabled": true,
            "addressSeparator": "+"
        },
        "shareTrust": {
            "enabled": true,
            "min": 10,
            "stepDown": 3,
            "threshold": 10,
            "penalty": 30
        },
        "banning": {
            "enabled": true,
            "time": 600,
            "invalidPercent": 25,
            "checkThreshold": 30
        },
        "slushMining": {
            "enabled": false,
            "weight": 300,
            "blockTime": 30,
            "lastBlockCheckRate": 1
        }
    },

    "payments": {
        "enabled": true,
        "interval": 1800,
        "maxAddresses": 50,
        "mixin": 10,
        "priority": 0,
        "transferFee": 400000,
        "dynamicTransferFee": true,
        "minerPayFee": true,
        "minPayment": 100000000,
        "maxPayment": null,
        "maxTransactionAmount": 0,
        "denomination": 10000000
    },

    "blockUnlocker": {
        "enabled": true,
        "interval": 30,
        "depth": 10,
        "poolFee": 1.0,
        "devDonation": 0.0
    },

    "api": {
        "enabled": true,
        "hashrateWindow": 600,
        "updateInterval": 5,
        "bindIp": "127.0.0.1",
        "port": 8117,
        "blocks": 30,
        "payments": 30,
        "password": "YOUR_API_PASSWORD_HERE",
        "ssl": false,
        "sslPort": 8119,
        "sslCert": "/etc/letsencrypt/live/pool.xwift.network/fullchain.pem",
        "sslKey": "/etc/letsencrypt/live/pool.xwift.network/privkey.pem",
        "sslCA": "/etc/letsencrypt/live/pool.xwift.network/chain.pem",
        "trustProxyIP": true
    },

    "daemon": {
        "host": "127.0.0.1",
        "port": 19081,
        "user": "pool",
        "password": "YOUR_SECURE_RPC_PASSWORD_HERE"
    },

    "wallet": {
        "host": "127.0.0.1",
        "port": 19082,
        "user": "wallet",
        "password": "YOUR_SECURE_WALLET_RPC_PASSWORD_HERE"
    },

    "redis": {
        "host": "127.0.0.1",
        "port": 6379,
        "auth": null,
        "db": 0,
        "cleanupInterval": 15
    },

    "notifications": {
        "emailTemplate": "email_templates/default.txt",
        "emailSubject": {
            "emailAdded": "Your email was registered",
            "workerConnected": "Worker %WORKER_NAME% connected",
            "workerTimeout": "Worker %WORKER_NAME% stopped hashing",
            "workerBanned": "Worker %WORKER_NAME% banned",
            "blockFound": "Block %HEIGHT% found !",
            "blockUnlocked": "Block %HEIGHT% unlocked !",
            "blockOrphaned": "Block %HEIGHT% orphaned !",
            "payment": "We sent you a payment !"
        },
        "emailMessage": {
            "emailAdded": "Your email has been registered to receive pool notifications.",
            "workerConnected": "Your worker %WORKER_NAME% for address %MINER% is now connected from ip %IP%.",
            "workerTimeout": "Your worker %WORKER_NAME% for address %MINER% has stopped submitting hashes on %LAST_HASH%.",
            "workerBanned": "Your worker %WORKER_NAME% for address %MINER% has been banned.",
            "blockFound": "Block found at height %HEIGHT% by miner %MINER% on %TIME%. Waiting maturity.",
            "blockUnlocked": "Block mined at height %HEIGHT% with value %REWARD% has been unlocked.",
            "blockOrphaned": "Block orphaned at height %HEIGHT% :(",
            "payment": "A payment of %AMOUNT% has been sent to %ADDRESS% wallet."
        },
        "telegramMessage": {
            "workerConnected": "Your worker _%WORKER_NAME%_ for address _%MINER%_ is now connected from ip _%IP%_.",
            "workerTimeout": "Your worker _%WORKER_NAME%_ for address _%MINER%_ has stopped submitting hashes on _%LAST_HASH%_.",
            "workerBanned": "Your worker _%WORKER_NAME%_ for address _%MINER%_ has been banned.",
            "blockFound": "*Block found at height* _%HEIGHT%_ *by miner* _%MINER%_*! Waiting maturity.*",
            "blockUnlocked": "*Block mined at height* _%HEIGHT%_ *with value* _%REWARD%_ *has been unlocked.*",
            "blockOrphaned": "*Block orphaned at height* _%HEIGHT%_ *:(*",
            "payment": "A payment of _%AMOUNT%_ has been sent."
        }
    },

    "email": {
        "enabled": false,
        "fromAddress": "pool@xwift.network",
        "transport": "sendmail",
        "sendmail": {
            "path": "/usr/sbin/sendmail"
        },
        "smtp": {
            "host": "smtp.example.com",
            "port": 587,
            "secure": false,
            "auth": {
                "user": "username",
                "pass": "password"
            },
            "tls": {
                "rejectUnauthorized": false
            }
        },
        "mailgun": {
            "key": "your-private-key",
            "domain": "mg.yourdomain"
        }
    },

    "telegram": {
        "enabled": false,
        "botName": "",
        "token": "",
        "channel": "",
        "channelStats": {
            "enabled": false,
            "interval": 30
        },
        "botCommands": {
            "stats": "/stats",
            "report": "/report",
            "notify": "/notify",
            "blocks": "/blocks"
        }
    },

    "monitoring": {
        "daemon": {
            "checkInterval": 60,
            "rpcMethod": "getblockcount"
        },
        "wallet": {
            "checkInterval": 60,
            "rpcMethod": "get_address"
        }
    },

    "prices": {
        "source": "cryptonator",
        "currency": "USD"
    },

    "charts": {
        "pool": {
            "hashrate": {
                "enabled": true,
                "updateInterval": 60,
                "stepInterval": 1800,
                "maximumPeriod": 86400
            },
            "miners": {
                "enabled": true,
                "updateInterval": 60,
                "stepInterval": 1800,
                "maximumPeriod": 86400
            },
            "workers": {
                "enabled": true,
                "updateInterval": 60,
                "stepInterval": 1800,
                "maximumPeriod": 86400
            },
            "difficulty": {
                "enabled": true,
                "updateInterval": 1800,
                "stepInterval": 10800,
                "maximumPeriod": 604800
            },
            "price": {
                "enabled": true,
                "updateInterval": 1800,
                "stepInterval": 10800,
                "maximumPeriod": 604800
            },
            "profit": {
                "enabled": true,
                "updateInterval": 1800,
                "stepInterval": 10800,
                "maximumPeriod": 604800
            }
        },
        "user": {
            "hashrate": {
                "enabled": true,
                "updateInterval": 180,
                "stepInterval": 1800,
                "maximumPeriod": 86400
            },
            "worker_hashrate": {
                "enabled": true,
                "updateInterval": 60,
                "stepInterval": 60,
                "maximumPeriod": 86400
            },
            "payments": {
                "enabled": true
            }
        },
        "blocks": {
            "enabled": true,
            "days": 30
        }
    }
}
```

### 3.3 Create Xwift Coin Module

Create `/opt/xwift-pool/lib/coins/xwift.js`:

```javascript
"use strict";
const bignum = require('bignum');
const cnUtil = require('cryptoforknote-util');
const multiHashing = require('cryptonight-hashing');
const crypto = require('crypto');
const debug = require('debug')('coinFuncs');

let hexChars = new RegExp("[0-9a-f]+");

function Coin(data){
    this.bestExchange = global.config.payout.bestExchange;
    this.data = data;
    let instanceId = crypto.randomBytes(4);
    this.coinDevAddress = "";  // No official dev donation address
    this.poolDevAddress = "";  // Set if you want pool dev donations

    this.blockedAddresses = [
        this.coinDevAddress,
        this.poolDevAddress
    ];

    this.exchangeAddresses = []; // Add exchange addresses if needed

    this.prefix = 65;
    this.intPrefix = 66;
    this.subPrefix = 67;
    this.cnAlgorithm = "randomx";
    this.cnVariant = 0;
    this.cnBlobType = 2;

    this.supportsAutoExchange = false;

    this.niceHashDiff = 400000;

    this.getBlockHeaderByID = function(blockId, callback){
        global.support.rpcDaemon('getblockheaderbyheight', {"height": blockId}, function (body) {
            if (body.hasOwnProperty('result')){
                return callback(null, body.result.block_header);
            } else {
                console.error(JSON.stringify(body));
                return callback(true, body);
            }
        });
    };

    this.getBlockHeaderByHash = function(blockHash, callback){
        global.support.rpcDaemon('getblockheaderbyhash', {"hash": blockHash}, function (body) {
            if (typeof(body) !== 'undefined' && body.hasOwnProperty('result')){
                return callback(null, body.result.block_header);
            } else {
                console.error(JSON.stringify(body));
                return callback(true, body);
            }
        });
    };

    this.getLastBlockHeader = function(callback){
        global.support.rpcDaemon('getlastblockheader', [], function (body) {
            if (typeof(body) !== 'undefined' && body.hasOwnProperty('result')){
                return callback(null, body.result.block_header);
            } else {
                console.error(JSON.stringify(body));
                return callback(true, body);
            }
        });
    };

    this.getBlockTemplate = function(walletAddress, callback){
        global.support.rpcDaemon('getblocktemplate', {
            reserve_size: 17,
            wallet_address: walletAddress
        }, function(body){
            return callback(body);
        });
    };

    this.baseDiff = function(){
        return bignum('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', 16);
    };

    this.validateAddress = function(address){
        // This function should use the cryptoforknote-util library to verify address
        try {
            let addressDecoded = cnUtil.address_decode(Buffer.from(address));
            return addressDecoded.intPaymentId === null && addressDecoded.spend.length === 64 && addressDecoded.view.length === 64;
        } catch(e){
            return false;
        }
    };

    this.convertBlob = function(blobBuffer){
        return cnUtil.convert_blob(blobBuffer);
    };

    this.constructNewBlob = function(blockTemplate, NonceBuffer){
        return cnUtil.construct_block_blob(blockTemplate, NonceBuffer);
    };

    this.getBlockID = function(blockBuffer){
        return cnUtil.get_block_id(blockBuffer);
    };

    this.BlockTemplate = function(template) {
        this.blob = template.blocktemplate_blob;
        this.difficulty = template.difficulty;
        this.height = template.height;
        this.reserveOffset = template.reserved_offset;
        this.buffer = Buffer.from(this.blob, 'hex');
        instanceId.copy(this.buffer, this.reserveOffset + 4, 0, 4);
        this.previousHash = Buffer.alloc(32);
        this.buffer.copy(this.previousHash, 0, 7, 39);
        this.extraNonce = 0;
    };

    this.cryptoNight = function(convertedBlob) {
        return multiHashing.randomx(convertedBlob, Buffer.from(""), 0);
    };
}

module.exports = Coin;
```

### 3.4 Update Dependencies

Add to `/opt/xwift-pool/package.json`:

```json
{
  "dependencies": {
    "bignum": "^0.13.0",
    "cryptoforknote-util": "^0.0.3",
    "cryptonight-hashing": "^6.0.0",
    "debug": "^4.3.1"
  }
}
```

Then install:
```bash
cd /opt/xwift-pool
sudo npm install
```

### 3.5 Start Pool with PM2

```bash
# Change ownership
sudo chown -R xwift:xwift /opt/xwift-pool

# Create log directory
sudo mkdir -p /var/log/xwift-pool
sudo chown xwift:xwift /var/log/xwift-pool

# Start as xwift user
sudo -u xwift bash -c "cd /opt/xwift-pool && pm2 start init.js --name xwift-pool"

# Save PM2 process list
sudo -u xwift pm2 save

# Setup PM2 startup script
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u xwift --hp /home/xwift

# Check status
sudo -u xwift pm2 status
sudo -u xwift pm2 logs xwift-pool
```

---

## Part 4: Frontend Setup

### 4.1 Install Pool Frontend

```bash
# Clone pool frontend
cd /opt
sudo git clone https://github.com/dvandal/cryptonote-nodejs-pool-frontend.git xwift-pool-frontend
cd xwift-pool-frontend

# Configure
sudo cp config_example.json config.json
```

Edit `/opt/xwift-pool-frontend/config.json`:

```json
{
    "api": "http://127.0.0.1:8117",
    "poolHost": "pool.xwift.network",
    "irc": "",
    "email": "support@xwift.network",
    "cryptonatorWidget": [],
    "easyminerDownload": "",
    "blockchainExplorer": "https://explorer.xwift.network/block/{id}",
    "transactionExplorer": "https://explorer.xwift.network/tx/{id}",
    "themeCss": "themes/default.css",
    "networkStat": {
        "loki": {
            "name": "Xwift Network",
            "api": "http://127.0.0.1:8117",
            "enabled": true
        }
    }
}
```

### 4.2 Configure Nginx

Create `/etc/nginx/sites-available/xwift-pool`:

```nginx
upstream pool_api {
    server 127.0.0.1:8117;
}

server {
    listen 80;
    listen [::]:80;
    server_name pool.xwift.network;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name pool.xwift.network;

    ssl_certificate /etc/letsencrypt/live/pool.xwift.network/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pool.xwift.network/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /opt/xwift-pool-frontend;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /api/ {
        proxy_pass http://pool_api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 4.3 Enable Site and Get SSL

```bash
# Get SSL certificate
sudo certbot certonly --nginx -d pool.xwift.network

# Enable site
sudo ln -s /etc/nginx/sites-available/xwift-pool /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Set permissions
sudo chown -R www-data:www-data /opt/xwift-pool-frontend
```

---

## Part 5: Testing and Launch

### 5.1 Test Mining Connection

```bash
# Install xmrig for testing
cd /tmp
wget https://github.com/xmrig/xmrig/releases/download/v6.20.0/xmrig-6.20.0-linux-x64.tar.gz
tar xf xmrig-6.20.0-linux-x64.tar.gz
cd xmrig-6.20.0

# Test mine to your pool
./xmrig -o pool.xwift.network:3333 -u YOUR_XWIFT_ADDRESS -p x -k

# You should see:
# - Connection established
# - Job received
# - Shares accepted
```

### 5.2 Monitor Pool Health

```bash
# Check all services
sudo systemctl status xwift-pool-daemon
sudo systemctl status xwift-pool-wallet
sudo -u xwift pm2 status

# Check logs
sudo journalctl -u xwift-pool-daemon -f
sudo -u xwift pm2 logs xwift-pool

# Check Redis
redis-cli
> keys *
> exit

# Check API
curl http://localhost:8117/stats
```

### 5.3 Firewall Configuration

```bash
# Allow mining ports
sudo ufw allow 3333/tcp comment 'Xwift Pool - Low diff'
sudo ufw allow 4444/tcp comment 'Xwift Pool - Mid diff'
sudo ufw allow 5555/tcp comment 'Xwift Pool - High diff'
sudo ufw allow 6666/tcp comment 'Xwift Pool - Farm diff'
sudo ufw allow 7777/tcp comment 'Xwift Pool - SSL Low'
sudo ufw allow 8888/tcp comment 'Xwift Pool - SSL Mid'

# Allow web
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Allow P2P
sudo ufw allow 19080/tcp comment 'Xwift P2P'

# Enable firewall
sudo ufw enable
sudo ufw status
```

---

## Part 6: Maintenance and Operations

### 6.1 Regular Maintenance Tasks

```bash
# Daily backup
0 2 * * * /usr/local/bin/backup-pool.sh

# Create backup script /usr/local/bin/backup-pool.sh
#!/bin/bash
DATE=$(date +%Y%m%d)
redis-cli --rdb /backup/redis-$DATE.rdb
tar -czf /backup/pool-config-$DATE.tar.gz /opt/xwift-pool/config.json /etc/xwift-*
find /backup -mtime +7 -delete
```

### 6.2 Monitoring

```bash
# Setup monitoring alerts
# - Check if daemon is synced
# - Check if wallet RPC is responding
# - Check if pool is finding blocks
# - Check hashrate trends
# - Monitor payout queue

# Example health check script
#!/bin/bash
HEIGHT=$(curl -s http://localhost:8117/stats | jq '.network.height')
if [ "$HEIGHT" -lt 1 ]; then
    echo "Pool daemon not responding!" | mail -s "ALERT: Pool Down" admin@xwift.network
fi
```

### 6.3 Troubleshooting

**Problem: No miners connecting**
```bash
# Check if ports are open
sudo netstat -tlnp | grep :3333

# Check pool logs
sudo -u xwift pm2 logs xwift-pool

# Test from external
telnet pool.xwift.network 3333
```

**Problem: Blocks not unlocking**
```bash
# Check wallet RPC
curl -X POST http://localhost:19082/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_address"}' -H 'Content-Type: application/json' --user wallet:YOUR_PASSWORD

# Check daemon sync
curl -X POST http://localhost:19081/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' -H 'Content-Type: application/json' --user pool:YOUR_PASSWORD
```

**Problem: Payments failing**
```bash
# Check wallet balance
# Check minimum payment threshold
# Check transaction fees
# Review payment logs in PM2
```

---

## Security Checklist

- [ ] Strong RPC passwords set (daemon and wallet)
- [ ] Firewall configured (only necessary ports open)
- [ ] SSL certificates installed and auto-renewing
- [ ] Regular backups configured
- [ ] Wallet seed phrase stored securely offline
- [ ] DDoS protection enabled (Cloudflare recommended)
- [ ] SSH key-only authentication
- [ ] Fail2ban installed and configured
- [ ] Regular security updates scheduled
- [ ] Monitoring and alerting configured

---

## Cost Estimation

**Monthly Operating Costs:**
- VPS Server (16GB RAM, 8 cores): $50-$100/month
- Domain name: $1/month (amortized)
- DDoS protection: $0-$20/month (Cloudflare free tier available)
- SSL certificate: $0 (Let's Encrypt free)
- **Total: ~$60-$120/month**

**Initial Setup Time:**
- Xwift daemon setup: 2-4 hours (mostly sync time)
- Pool software setup: 2-3 hours
- Frontend setup: 1-2 hours
- Testing and fine-tuning: 2-4 hours
- **Total: 7-13 hours**

---

## Support and Resources

- **Xwift GitHub**: https://github.com/diamondsteel259/Xwift
- **nodejs-pool**: https://github.com/Snipa22/nodejs-pool
- **Monero Mining**: https://monerodocs.org/interacting/mining/
- **Pool Operators Telegram**: [Create one for Xwift]

---

**Document Version**: 1.0
**Last Updated**: 2025-11-04
**Status**: Ready for deployment

This guide will create a fully functional, production-ready mining pool for Xwift cryptocurrency. Test thoroughly on testnet before launching on mainnet!
