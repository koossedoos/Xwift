#!/bin/bash
# Vultr VPS Setup for Xwift Testnet Seed Node

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

NODE_NUMBER=3
VULTR_TOKEN="${vultr_token:-}"
VULTR_REGION="${vultr_default_region:-sgp}"
VULTR_PLAN="${vultr_default_plan:-vc2-4c-8gb}"
LABEL="xwift-seed${NODE_NUMBER}"
SSH_KEY_PATH="${ssh_key_path:-$HOME/.ssh/id_ed25519}"
SSH_USER="root"

usage() {
    cat << EOF
Vultr Xwift Seed Node Setup

Usage: $0 [options]

Options:
  --node N           Seed node number (default: 3)
  --token TOKEN      Vultr API token
  --region REGION    Vultr region (default: sgp for Singapore)
  --plan PLAN        Vultr plan (default: vc2-4c-8gb)
  --host IP          Manual mode: existing Vultr IP
  --help             Show this help

Common Vultr Regions:
  sgp - Singapore
  fra - Frankfurt
  sea - Seattle
  nyc - New York
EOF
}

MANUAL_HOST=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --node)
            NODE_NUMBER="$2"
            shift 2
            ;;
        --token)
            VULTR_TOKEN="$2"
            shift 2
            ;;
        --region)
            VULTR_REGION="$2"
            shift 2
            ;;
        --plan)
            VULTR_PLAN="$2"
            shift 2
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

LABEL="xwift-seed${NODE_NUMBER}"

# Load env
if [ -f "$(dirname "$0")/../.env" ]; then
    source "$(dirname "$0")/../.env"
    VULTR_TOKEN="${VULTR_TOKEN:-${vultr_token:-}}"
    SSH_KEY_PATH="${SSH_KEY_PATH:-${ssh_key_path:-$HOME/.ssh/id_ed25519}}"
fi

if [ -n "$MANUAL_HOST" ]; then
    print_info "Manual mode: configuring existing Vultr instance at $MANUAL_HOST"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    scp -o StrictHostKeyChecking=no "$SCRIPT_DIR/generic-ubuntu-setup.sh" ${SSH_USER}@${MANUAL_HOST}:/tmp/
    ssh -o StrictHostKeyChecking=no ${SSH_USER}@${MANUAL_HOST} "chmod +x /tmp/generic-ubuntu-setup.sh && /tmp/generic-ubuntu-setup.sh --node $NODE_NUMBER"
    print_info "✅ Manual Vultr setup complete"
    exit 0
fi

if [ -z "$VULTR_TOKEN" ]; then
    print_error "Vultr API token required"
    exit 1
fi

if [ ! -f "${SSH_KEY_PATH}.pub" ]; then
    print_warning "SSH key not found, generating..."
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "xwift-vultr"
fi

SSH_PUBLIC_KEY=$(cat "${SSH_KEY_PATH}.pub")

print_info "========================================"
print_info "Vultr Deployment"
print_info "Node: $NODE_NUMBER"
print_info "Region: $VULTR_REGION"
print_info "Plan: $VULTR_PLAN"
print_info "Label: $LABEL"
print_info "========================================"

# Upload SSH key to Vultr
SSH_KEY_RESPONSE=$(curl -s "https://api.vultr.com/v2/ssh-keys" \
    -H "Authorization: Bearer $VULTR_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"name\":\"xwift-testnet\",\"ssh_key\":\"$SSH_PUBLIC_KEY\"}")

SSH_KEY_ID=$(echo "$SSH_KEY_RESPONSE" | jq -r '.ssh_key.id // empty')

if [ -z "$SSH_KEY_ID" ]; then
    print_warning "SSH key upload failed or already exists, continuing..."
    # Get existing keys
    SSH_KEYS_LIST=$(curl -s "https://api.vultr.com/v2/ssh-keys" -H "Authorization: Bearer $VULTR_TOKEN")
    SSH_KEY_ID=$(echo "$SSH_KEYS_LIST" | jq -r '.ssh_keys[0].id // empty')
fi

# Get OS ID (Ubuntu 22.04)
OS_ID=1743  # Ubuntu 22.04 x64

# Create instance
CREATE_RESPONSE=$(curl -s "https://api.vultr.com/v2/instances" \
    -H "Authorization: Bearer $VULTR_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{
        \"region\":\"$VULTR_REGION\",
        \"plan\":\"$VULTR_PLAN\",
        \"os_id\":$OS_ID,
        \"label\":\"$LABEL\",
        \"hostname\":\"$LABEL\",
        \"sshkey_id\":[\"$SSH_KEY_ID\"],
        \"backups\":\"disabled\",
        \"enable_ipv6\":true,
        \"tags\":[\"xwift\",\"testnet\",\"seed\"]
    }")

INSTANCE_ID=$(echo "$CREATE_RESPONSE" | jq -r '.instance.id')

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "null" ]; then
    print_error "Failed to create Vultr instance"
    echo "$CREATE_RESPONSE" | jq .
    exit 1
fi

print_info "Instance created (ID: $INSTANCE_ID). Waiting for IP..."

# Wait for instance to become active and get IP
for i in {1..60}; do
    INSTANCE_INFO=$(curl -s "https://api.vultr.com/v2/instances/$INSTANCE_ID" -H "Authorization: Bearer $VULTR_TOKEN")
    STATUS=$(echo "$INSTANCE_INFO" | jq -r '.instance.status')
    PUBLIC_IP=$(echo "$INSTANCE_INFO" | jq -r '.instance.main_ip // empty')
    
    if [ "$STATUS" = "active" ] && [ -n "$PUBLIC_IP" ] && [ "$PUBLIC_IP" != "0.0.0.0" ]; then
        break
    fi
    
    print_info "Status: $STATUS, IP: ${PUBLIC_IP:-pending} (waiting)..."
    sleep 10
done

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "0.0.0.0" ]; then
    print_error "Failed to obtain instance IP"
    exit 1
fi

print_info "Instance IP: $PUBLIC_IP"
print_info "Waiting for SSH..."
sleep 40

# SSH might take a bit longer on Vultr
for i in {1..30}; do
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ${SSH_USER}@${PUBLIC_IP} "echo OK" >/dev/null 2>&1; then
        print_info "SSH is ready"
        break
    fi
    print_info "Waiting for SSH... ($i/30)"
    sleep 10
done

# Configure server
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scp -o StrictHostKeyChecking=no "$SCRIPT_DIR/generic-ubuntu-setup.sh" ${SSH_USER}@${PUBLIC_IP}:/tmp/
ssh -o StrictHostKeyChecking=no ${SSH_USER}@${PUBLIC_IP} "chmod +x /tmp/generic-ubuntu-setup.sh && /tmp/generic-ubuntu-setup.sh --node $NODE_NUMBER"

print_info "========================================"
print_info "✅ Vultr seed node deployed"
print_info "Instance ID: $INSTANCE_ID"
print_info "IP: $PUBLIC_IP"
print_info "Node: $NODE_NUMBER"
print_info "========================================"

mkdir -p "$(dirname "$0")/../data"
echo "$PUBLIC_IP" > "$(dirname "$0")/../data/seed${NODE_NUMBER}-ip.txt"
echo "vultr,$NODE_NUMBER,$PUBLIC_IP,$INSTANCE_ID,$(date)" >> "$(dirname "$0")/../data/deployments.csv"
