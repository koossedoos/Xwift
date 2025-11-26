#!/bin/bash
# Digital Ocean VPS Setup for Xwift Testnet Seed Node
# Uses Digital Ocean API to create and configure seed node

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Configuration
NODE_NUMBER=1
DO_TOKEN="${digitalocean_token:-}"
DO_REGION="${digitalocean_default_region:-nyc3}"
DO_SIZE="${digitalocean_default_size:-s-2vcpu-4gb}"
DO_IMAGE="ubuntu-22-04-x64"
DROPLET_NAME="xwift-testnet-seed${NODE_NUMBER}"
SSH_KEY_ID=""

usage() {
    cat << EOF
Digital Ocean Xwift Seed Node Setup

Usage: $0 [options]

Options:
  --node N            Seed node number (default: 1)
  --token TOKEN       Digital Ocean API token
  --region REGION     DO region (default: nyc3)
  --size SIZE         Droplet size (default: s-2vcpu-4gb)
  --ssh-key-id ID     SSH key ID (or will use all account keys)
  --manual            Setup existing droplet manually (no API)
  --help              Show this help

Manual Mode:
  If --manual is specified, script assumes droplet already exists
  and sets it up via SSH. Requires:
    --host HOSTNAME or IP

Examples:
  # Automatic deployment with API
  ./digitalocean-setup.sh --token \$DO_TOKEN --node 1

  # Manual setup of existing droplet
  ./digitalocean-setup.sh --manual --host 192.168.1.100 --node 1
EOF
}

MANUAL_MODE=false
MANUAL_HOST=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --node)
            NODE_NUMBER="$2"
            shift 2
            ;;
        --token)
            DO_TOKEN="$2"
            shift 2
            ;;
        --region)
            DO_REGION="$2"
            shift 2
            ;;
        --size)
            DO_SIZE="$2"
            shift 2
            ;;
        --ssh-key-id)
            SSH_KEY_ID="$2"
            shift 2
            ;;
        --manual)
            MANUAL_MODE=true
            shift
            ;;
        --host)
            MANUAL_HOST="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

DROPLET_NAME="xwift-testnet-seed${NODE_NUMBER}"

if [ "$MANUAL_MODE" = true ]; then
    print_info "Running in MANUAL mode"
    
    if [ -z "$MANUAL_HOST" ]; then
        print_error "Manual mode requires --host parameter"
        exit 1
    fi
    
    print_info "========================================"
    print_info "Manual Xwift Seed Node Setup"
    print_info "Host: $MANUAL_HOST"
    print_info "Node: $NODE_NUMBER"
    print_info "========================================"
    
    # Copy generic setup script to host and run it
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    print_info "Copying setup script to host..."
    scp "$SCRIPT_DIR/generic-ubuntu-setup.sh" "root@${MANUAL_HOST}:/tmp/"
    
    print_info "Running setup script on host..."
    ssh "root@${MANUAL_HOST}" "chmod +x /tmp/generic-ubuntu-setup.sh && /tmp/generic-ubuntu-setup.sh --node $NODE_NUMBER"
    
    print_info "✅ Manual setup complete!"
    print_info "Node ${NODE_NUMBER} is ready at ${MANUAL_HOST}"
    exit 0
fi

# Automatic deployment mode
print_info "========================================"
print_info "Digital Ocean Xwift Seed Node Deployment"
print_info "Node Number: $NODE_NUMBER"
print_info "Region: $DO_REGION"
print_info "Size: $DO_SIZE"
print_info "========================================"

# Check for API token
if [ -z "$DO_TOKEN" ]; then
    # Try loading from .env
    if [ -f "$(dirname "$0")/../.env" ]; then
        source "$(dirname "$0")/../.env"
        DO_TOKEN="${digitalocean_token:-}"
    fi
    
    if [ -z "$DO_TOKEN" ]; then
        print_error "Digital Ocean API token required"
        print_info "Set via --token or in .env file (digitalocean_token)"
        exit 1
    fi
fi

# Check if doctl is installed (optional)
if ! command -v doctl &> /dev/null; then
    print_warning "doctl CLI not found. Install for easier management:"
    print_info "  snap install doctl"
    print_info ""
    print_info "Proceeding with curl API calls..."
fi

# Create droplet via API
print_info "Creating Digital Ocean droplet: $DROPLET_NAME"

# Get SSH keys (if not specified, use all account keys)
if [ -z "$SSH_KEY_ID" ]; then
    SSH_KEYS=$(curl -s -X GET "https://api.digitalocean.com/v2/account/keys" \
        -H "Authorization: Bearer $DO_TOKEN" | jq -r '.ssh_keys[].id' | paste -sd,)
    SSH_KEYS_JSON=$(echo "$SSH_KEYS" | tr ',' '\n' | jq -R . | jq -s .)
else
    SSH_KEYS_JSON="[$SSH_KEY_ID]"
fi

DROPLET_RESPONSE=$(curl -s -X POST "https://api.digitalocean.com/v2/droplets" \
    -H "Authorization: Bearer $DO_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "name":"'$DROPLET_NAME'",
        "region":"'$DO_REGION'",
        "size":"'$DO_SIZE'",
        "image":"'$DO_IMAGE'",
        "ssh_keys":'$SSH_KEYS_JSON',
        "backups":false,
        "ipv6":true,
        "monitoring":true,
        "tags":["xwift","testnet","seed"]
    }')

DROPLET_ID=$(echo "$DROPLET_RESPONSE" | jq -r '.droplet.id')

if [ -z "$DROPLET_ID" ] || [ "$DROPLET_ID" = "null" ]; then
    print_error "Failed to create droplet"
    echo "$DROPLET_RESPONSE" | jq .
    exit 1
fi

print_info "✅ Droplet created (ID: $DROPLET_ID)"
print_info "Waiting for droplet to become active..."

# Wait for droplet to be active
for i in {1..60}; do
    STATUS=$(curl -s -X GET "https://api.digitalocean.com/v2/droplets/$DROPLET_ID" \
        -H "Authorization: Bearer $DO_TOKEN" | jq -r '.droplet.status')
    
    if [ "$STATUS" = "active" ]; then
        print_info "✅ Droplet is active"
        break
    fi
    
    print_info "Status: $STATUS (waiting...)"
    sleep 10
done

# Get droplet IP
DROPLET_IP=$(curl -s -X GET "https://api.digitalocean.com/v2/droplets/$DROPLET_ID" \
    -H "Authorization: Bearer $DO_TOKEN" | jq -r '.droplet.networks.v4[0].ip_address')

print_info "Droplet IP: $DROPLET_IP"
print_info "Waiting for SSH to become available..."
sleep 30

# Wait for SSH
for i in {1..30}; do
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "root@${DROPLET_IP}" "echo OK" >/dev/null 2>&1; then
        print_info "✅ SSH is ready"
        break
    fi
    print_info "Waiting for SSH... ($i/30)"
    sleep 10
done

# Copy and run setup script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_info "Copying setup script..."
scp -o StrictHostKeyChecking=no "$SCRIPT_DIR/generic-ubuntu-setup.sh" "root@${DROPLET_IP}:/tmp/"

print_info "Running setup script..."
ssh -o StrictHostKeyChecking=no "root@${DROPLET_IP}" "chmod +x /tmp/generic-ubuntu-setup.sh && /tmp/generic-ubuntu-setup.sh --node $NODE_NUMBER"

print_info "========================================"
print_info "✅ Digital Ocean seed node deployed!"
print_info "Droplet ID: $DROPLET_ID"
print_info "IP Address: $DROPLET_IP"
print_info "Node Number: $NODE_NUMBER"
print_info "Region: $DO_REGION"
print_info ""
print_info "Access: ssh root@${DROPLET_IP}"
print_info "Status: check-xwift-status"
print_info "========================================"

# Save droplet info
echo "${DROPLET_IP}" > "$(dirname "$0")/../data/seed${NODE_NUMBER}-ip.txt"
echo "digitalocean,${NODE_NUMBER},${DROPLET_IP},${DROPLET_ID},$(date)" >> "$(dirname "$0")/../data/deployments.csv"
