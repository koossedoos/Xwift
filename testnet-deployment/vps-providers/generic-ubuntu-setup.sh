#!/bin/bash
# Generic Ubuntu VPS Setup for Xwift Testnet Seed Node
# Works on any Ubuntu 20.04+ or Debian 11+ VPS

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
NODE_NUMBER=1
XWIFT_REPO_URL="https://github.com/xwift/xwift.git"
XWIFT_BRANCH="testnet"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --node)
            NODE_NUMBER="$2"
            shift 2
            ;;
        --repo)
            XWIFT_REPO_URL="$2"
            shift 2
            ;;
        --branch)
            XWIFT_BRANCH="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_info "========================================"
print_info "Xwift Testnet Seed Node Setup"
print_info "Node Number: $NODE_NUMBER"
print_info "========================================"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

# Step 1: Update system
print_info "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y

# Step 2: Install dependencies
print_info "Installing build dependencies..."
apt install -y \
    build-essential cmake pkg-config \
    libboost-all-dev libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libunwind8-dev \
    liblzma-dev libreadline-dev libexpat1-dev \
    libgtest-dev doxygen graphviz libhidapi-dev \
    libusb-1.0-0-dev libprotobuf-dev protobuf-compiler \
    git curl wget jq htop iotop nethogs \
    python3 python3-pip bc ufw fail2ban

# Install Python packages for monitoring
pip3 install requests pandas matplotlib

# Step 3: Configure firewall
print_info "Configuring firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 29080/tcp comment "Xwift Testnet P2P"
ufw allow 29081/tcp comment "Xwift Testnet RPC"
ufw --force enable

# Step 4: Create xwift user
print_info "Creating xwift system user..."
if ! id -u xwift > /dev/null 2>&1; then
    adduser --system --group --disabled-password --home /home/xwift xwift
fi

# Step 5: Clone and build Xwift
print_info "Cloning Xwift repository..."
cd /opt
if [ -d "xwift" ]; then
    rm -rf xwift
fi

# For local testing, copy from mounted directory if it exists
if [ -d "/home/engine/project" ]; then
    print_info "Using local repository..."
    cp -r /home/engine/project /opt/xwift
    cd /opt/xwift
    git config --global --add safe.directory /opt/xwift || true
else
    print_info "Cloning from repository..."
    git clone --branch "$XWIFT_BRANCH" "$XWIFT_REPO_URL" xwift
    cd /opt/xwift
fi

# Initialize submodules
print_info "Initializing submodules..."
git submodule init
git submodule update

# Build Xwift
print_info "Building Xwift (this will take 20-60 minutes)..."
make release -j$(nproc)

# Find build directory
BUILD_OS=$(uname | sed 's|[:/\\ \(\)]|_|g')
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "testnet")
SANITIZED_BRANCH=$(echo "$CURRENT_BRANCH" | sed 's|[:/\\ \(\)]|_|g')
BUILD_ROOT="build/${BUILD_OS}/${SANITIZED_BRANCH}/release"
if [ ! -d "$BUILD_ROOT/bin" ]; then
    BUILD_ROOT="build/release"
fi
BUILD_BIN="${BUILD_ROOT}/bin"

# Verify build
if [ ! -f "$BUILD_BIN/xwiftd" ]; then
    print_error "Build failed - xwiftd binary not found"
    exit 1
fi

# Step 6: Install binaries
print_info "Installing binaries..."
cp "$BUILD_BIN/xwiftd" /usr/local/bin/
cp "$BUILD_BIN/monero-wallet-cli" /usr/local/bin/xwift-wallet-cli
chmod +x /usr/local/bin/xwiftd
chmod +x /usr/local/bin/xwift-wallet-cli

# Step 7: Create data directories
print_info "Creating data directories..."
mkdir -p /var/lib/xwift-testnet
mkdir -p /var/log/xwift-testnet
chown -R xwift:xwift /var/lib/xwift-testnet /var/log/xwift-testnet

# Step 8: Create configuration file
print_info "Creating configuration file..."
cat > /etc/xwift-testnet.conf << EOF
# Xwift Testnet Seed Node ${NODE_NUMBER} Configuration
# Generated: $(date)

# Data and logging
data-dir=/var/lib/xwift-testnet
log-file=/var/log/xwift-testnet/xwift.log
log-level=1

# Network settings
testnet=1
p2p-bind-ip=0.0.0.0
p2p-bind-port=29080
rpc-bind-ip=0.0.0.0
rpc-bind-port=29081
zmq-pub=tcp://0.0.0.0:29082
restricted-rpc=1
confirm-external-bind=1

# Performance
max-concurrency=$(nproc)
block-sync-size=100
db-sync-mode=safe

# P2P settings
out-peers=24
in-peers=12
limit-rate-up=2048
limit-rate-down=8192

# Seed nodes (will be populated with other seeds)
# add-priority-node=seed1.xwift-testnet.network:29080
# add-priority-node=seed2.xwift-testnet.network:29080
# add-priority-node=seed3.xwift-testnet.network:29080
EOF

# Step 9: Create systemd service
print_info "Creating systemd service..."
cat > /etc/systemd/system/xwift-testnet.service << EOF
[Unit]
Description=Xwift Testnet Seed Node ${NODE_NUMBER}
After=network.target

[Service]
Type=simple
User=xwift
Group=xwift
ExecStart=/usr/local/bin/xwiftd --config-file /etc/xwift-testnet.conf --detach --non-interactive
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=xwift-testnet

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true

[Install]
WantedBy=multi-user.target
EOF

# Step 10: Enable and start service
print_info "Enabling and starting Xwift testnet service..."
systemctl daemon-reload
systemctl enable xwift-testnet
systemctl start xwift-testnet

# Step 11: Install monitoring scripts
print_info "Installing monitoring scripts..."
mkdir -p /opt/xwift-monitoring

cat > /opt/xwift-monitoring/check-node-status.sh << 'EOF'
#!/bin/bash
# Quick node status check

echo "=== Xwift Testnet Node Status ==="
echo "Time: $(date)"
echo ""

# Service status
systemctl is-active --quiet xwift-testnet && echo "Service: RUNNING" || echo "Service: STOPPED"

# RPC status
if curl -s http://localhost:29081/get_info > /dev/null 2>&1; then
    echo "RPC: RESPONSIVE"
    info=$(curl -s http://localhost:29081/get_info)
    echo "Height: $(echo $info | jq -r '.height')"
    echo "Connections: $(echo $info | jq -r '.outgoing_connections_count') out / $(echo $info | jq -r '.incoming_connections_count') in"
    echo "Difficulty: $(echo $info | jq -r '.difficulty')"
    echo "Hash rate: $(echo $info | jq -r '.difficulty / 30' | bc) H/s (estimated)"
else
    echo "RPC: NOT RESPONSIVE"
fi

echo ""
echo "=== Recent Logs ==="
journalctl -u xwift-testnet -n 10 --no-pager
EOF

chmod +x /opt/xwift-monitoring/check-node-status.sh
ln -sf /opt/xwift-monitoring/check-node-status.sh /usr/local/bin/check-xwift-status

# Step 12: Setup log rotation
print_info "Setting up log rotation..."
cat > /etc/logrotate.d/xwift-testnet << EOF
/var/log/xwift-testnet/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0640 xwift xwift
    postrotate
        systemctl reload xwift-testnet > /dev/null 2>&1 || true
    endscript
}
EOF

# Step 13: Wait for initialization and check status
print_info "Waiting for node to initialize..."
sleep 30

print_info "========================================"
print_info "Installation Complete!"
print_info "========================================"
print_info ""
print_info "Node Information:"
print_info "  - Type: Testnet Seed Node ${NODE_NUMBER}"
print_info "  - P2P Port: 29080"
print_info "  - RPC Port: 29081"
print_info "  - Data: /var/lib/xwift-testnet"
print_info "  - Logs: /var/log/xwift-testnet"
print_info ""
print_info "Useful commands:"
print_info "  - Check status: check-xwift-status"
print_info "  - View logs: journalctl -u xwift-testnet -f"
print_info "  - Restart: systemctl restart xwift-testnet"
print_info "  - RPC info: curl http://localhost:29081/get_info | jq"
print_info ""
print_info "External IP: $(curl -s ifconfig.me || echo 'Unable to determine')"
print_info ""

# Display initial status
/opt/xwift-monitoring/check-node-status.sh

print_info "Setup completed at: $(date)"
