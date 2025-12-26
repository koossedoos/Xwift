#!/bin/bash
# Xwift Deployment Script
# This script automates the complete deployment of Xwift testnet and mainnet

set -e

echo "=== Xwift Deployment Script ==="
echo "Timestamp: $(date)"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

print_status "Starting Xwift deployment..."

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
print_status "Using repository at $REPO_DIR"

# Allow git commands under sudo/root when repository is owned by another user
if command -v git >/dev/null 2>&1; then
    git config --global --add safe.directory "$REPO_DIR" >/dev/null 2>&1 || true
fi

cd "$REPO_DIR"

# 1. Install dependencies
print_status "Installing system dependencies..."
apt update && apt install -y \
    build-essential cmake pkg-config libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libunwind8-dev liblzma-dev \
    libreadline6-dev libexpat1-dev git curl autoconf libtool \
    gperf python3 ccache libboost-dev zlib1g-dev \
    libboost-filesystem-dev libboost-thread-dev libboost-date-time-dev \
    libboost-chrono-dev libboost-serialization-dev libboost-program-options-dev

# 2. Create xwift user
print_status "Creating xwift system user..."
adduser --system --group --disabled-password xwift || true

# 3. Create directories
print_status "Creating data directories..."
mkdir -p /var/lib/xwift-testnet /var/lib/xwift-mainnet
mkdir -p /var/log/xwift-testnet /var/log/xwift-mainnet
chown -R xwift:xwift /var/lib/xwift-* /var/log/xwift-*

# 4. Build Xwift
print_status "Building Xwift from source..."

# Initialize submodules
print_status "Initializing git submodules..."
git submodule init && git submodule update

# Build (this will take time)
print_status "Compiling Xwift (this will take 20-60 minutes)..."
make release -j$(nproc)

BUILD_OS=$(uname | sed 's|[:/\\ \(\)]|_|g')
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "master")
SANITIZED_BRANCH=$(echo "$CURRENT_BRANCH" | sed 's|[:/\\ \(\)]|_|g')
BUILD_ROOT="build/${BUILD_OS}/${SANITIZED_BRANCH}/release"
if [ ! -d "$BUILD_ROOT/bin" ]; then
    BUILD_ROOT="build/release"
fi
BUILD_BIN="${BUILD_ROOT}/bin"

# Check if build was successful
if [ ! -f "$BUILD_BIN/xwiftd" ]; then
    print_error "Build failed - xwiftd binary not found in $BUILD_BIN"
    exit 1
fi

# 5. Install binaries
print_status "Installing binaries..."
cp "$BUILD_BIN/xwiftd" /usr/local/bin/
cp "$BUILD_BIN/monero-wallet-cli" /usr/local/bin/

# 6. Install systemd services
print_status "Installing systemd services..."
cp utils/systemd/xwift-testnet.service /etc/systemd/system/
cp utils/systemd/xwift-mainnet.service /etc/systemd/system/

# 7. Install configuration files
print_status "Installing configuration files..."
cp utils/conf/xwift-testnet.conf /etc/
cp utils/conf/xwift-mainnet.conf /etc/

# 8. Configure firewall
print_status "Configuring firewall..."
# Allow SSH (if not already allowed)
ufw allow ssh || true

# Allow Xwift ports
ufw allow 19080/tcp comment "Xwift Mainnet P2P"
ufw allow 19081/tcp comment "Xwift Mainnet RPC"
ufw allow 29080/tcp comment "Xwift Testnet P2P"
ufw allow 29081/tcp comment "Xwift Testnet RPC"

# Enable firewall if not already enabled
ufw --force enable || true

# 9. Reload systemd and enable services
print_status "Enabling and starting services..."
systemctl daemon-reload
systemctl enable xwift-testnet
systemctl enable xwift-mainnet
systemctl start xwift-testnet
systemctl start xwift-mainnet

# 10. Wait a moment for services to start
print_status "Waiting for services to initialize..."
sleep 10

# 11. Check service status
print_status "Checking service status..."
systemctl status xwift-testnet --no-pager -l
systemctl status xwift-mainnet --no-pager -l

# 12. Install monitoring script
print_status "Installing monitoring script..."
cp utils/scripts/check-nodes.sh /usr/local/bin/
chmod +x /usr/local/bin/check-nodes.sh

# 13. Final verification
print_status "Performing final verification..."
sleep 5

# Check if RPC ports are responding
if curl -s http://localhost:19081/get_info > /dev/null 2>&1; then
    print_status "✅ Mainnet RPC is responding"
else
    print_warning "⚠️  Mainnet RPC not responding yet (may still be starting)"
fi

if curl -s http://localhost:29081/get_info > /dev/null 2>&1; then
    print_status "✅ Testnet RPC is responding"
else
    print_warning "⚠️  Testnet RPC not responding yet (may still be starting)"
fi

# Display deployment summary
echo ""
print_status "=== Xwift Deployment Complete! ==="
echo ""
echo "📁 Important Locations:"
echo "   - Mainnet data: /var/lib/xwift-mainnet"
echo "   - Testnet data: /var/lib/xwift-testnet"
echo "   - Mainnet logs: /var/log/xwift-mainnet/xwift.log"
echo "   - Testnet logs: /var/log/xwift-testnet/xwift.log"
echo "   - Config files: /etc/xwift-*.conf"
echo ""
echo "🔧 Useful Commands:"
echo "   - Check status: /usr/local/bin/check-nodes.sh"
echo "   - View logs: journalctl -u xwift-mainnet -f"
echo "   - Start/stop: systemctl start/stop xwift-mainnet"
echo ""
echo "🌐 Network Information:"
echo "   - Mainnet RPC: http://localhost:19081"
echo "   - Testnet RPC: http://localhost:29081"
echo "   - Mainnet P2P: 19080"
echo "   - Testnet P2P: 29080"
echo ""
echo "🎯 Next Steps:"
echo "   1. Create wallets using monero-wallet-cli"
echo "   2. Test transactions on testnet first"
echo "   3. Monitor blockchain sync progress"
echo "   4. Set up additional security as needed"
echo ""
print_status "Deployment completed successfully! 🚀"
