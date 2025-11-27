#!/bin/bash
# Start Xwift Local Testnet (4 Nodes)
# Usage: ./scripts/start-testnet.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTNET_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$TESTNET_ROOT"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Xwift Local Testnet - Startup Script                ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed.${NC}"
    echo "Please install Docker first. See docs/DOCKER_SETUP_GUIDE.md"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose is not installed.${NC}"
    echo "Please install Docker Compose. See docs/DOCKER_SETUP_GUIDE.md"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found${NC}"
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo -e "${RED}❌ Please update MINER_ADDRESS in .env before starting.${NC}"
    echo ""
    echo "Steps:"
    echo "1. Create a testnet wallet:"
    echo "   docker run --rm -it -v \$(pwd)/wallet:/wallet local-xwift:testnet xwift-wallet-cli --testnet --generate-new-wallet /wallet/miner-wallet"
    echo ""
    echo "2. Copy the wallet address from the output above"
    echo ""
    echo "3. Edit .env and set MINER_ADDRESS=<your_wallet_address>"
    echo ""
    echo "4. Run this script again: ./scripts/start-testnet.sh"
    exit 1
fi

# Load .env
source .env

# Validate MINER_ADDRESS is set
if [ -z "$MINER_ADDRESS" ]; then
    echo -e "${RED}❌ MINER_ADDRESS is not set in .env${NC}"
    echo "Please edit .env and set your testnet wallet address."
    exit 1
fi

# Create data directories if they don't exist
echo -e "${CYAN}📁 Creating data directories...${NC}"
mkdir -p data/seed1 data/seed2 data/seed3 data/mining

# Build/pull Docker images
echo -e "${CYAN}🐳 Building Docker images (this may take 10-20 minutes on first run)...${NC}"
if docker compose version &> /dev/null 2>&1; then
    docker compose build
else
    docker-compose build
fi

# Start all nodes
echo -e "${GREEN}🚀 Starting all testnet nodes...${NC}"
if docker compose version &> /dev/null 2>&1; then
    docker compose up -d
else
    docker-compose up -d
fi

# Wait for nodes to initialize
echo -e "${CYAN}⏳ Waiting for nodes to initialize (60 seconds)...${NC}"
sleep 60

# Check node status
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}NODE STATUS${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"

check_node() {
    local name=$1
    local port=$2
    
    if docker ps | grep -q "$name"; then
        if curl -sf http://localhost:$port/get_info > /dev/null 2>&1; then
            echo -e "$name: ${GREEN}✓ Running${NC} (Port $port)"
        else
            echo -e "$name: ${YELLOW}⚠ Starting${NC} (Port $port)"
        fi
    else
        echo -e "$name: ${RED}✗ Stopped${NC}"
    fi
}

check_node "xwift-seed-1" 29081
check_node "xwift-seed-2" 29083
check_node "xwift-seed-3" 29085
check_node "xwift-mining" 29087

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Testnet startup complete!${NC}"
echo ""
echo "Monitor nodes:       ./scripts/status-testnet.sh"
echo "View logs:           ./scripts/logs-testnet.sh"
echo "Stop testnet:        ./scripts/stop-testnet.sh"
echo "Reset testnet:       ./scripts/reset-testnet.sh"
echo ""
echo "Dashboard:           ./dashboard/generate-local-dashboard.sh"
echo "Monitoring:          ./monitoring/monitor-nodes.sh"
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
