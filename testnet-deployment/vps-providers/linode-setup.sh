#!/bin/bash
# Linode VPS Setup for Xwift Testnet Seed Node

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

NODE_NUMBER=2
LINODE_TOKEN="${linode_token:-}"
LINODE_REGION="${linode_default_region:-eu-central}"
LINODE_TYPE="${linode_default_type:-g6-standard-4}"
LINODE_IMAGE="linode/ubuntu22.04"
LABEL="xwift-seed${NODE_NUMBER}"
SSH_KEY_PATH="${ssh_key_path:-$HOME/.ssh/id_ed25519}"
SSH_USER="root"

usage() {
    cat << EOF
Linode Xwift Seed Node Setup

Usage: $0 [options]

Options:
  --node N           Seed node number (default: 2)
  --token TOKEN      Linode API token
  --region REGION    Linode region (default: eu-central)
  --type TYPE        Linode type (default: g6-standard-4)
  --label LABEL      Custom Linode label
  --host IP          Manual mode: existing Linode IP
  --help             Show this help

If --host is provided, script skips API provisioning and only runs
server configuration over SSH.
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
            LINODE_TOKEN="$2"
            shift 2
            ;;
        --region)
            LINODE_REGION="$2"
            shift 2
            ;;
        --type)
            LINODE_TYPE="$2"
            shift 2
            ;;
        --label)
            LABEL="$2"
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

# Load .env if available
if [ -f "$(dirname "$0")/../.env" ]; then
    source "$(dirname "$0")/../.env"
    LINODE_TOKEN="${LINODE_TOKEN:-${linode_token:-}}"
    SSH_KEY_PATH="${SSH_KEY_PATH:-${ssh_key_path:-$HOME/.ssh/id_ed25519}}"
fi

if [ -n "$MANUAL_HOST" ]; then
    print_info "Manual mode: configuring existing Linode at $MANUAL_HOST"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    scp -o StrictHostKeyChecking=no "$SCRIPT_DIR/generic-ubuntu-setup.sh" ${SSH_USER}@${MANUAL_HOST}:/tmp/
    ssh -o StrictHostKeyChecking=no ${SSH_USER}@${MANUAL_HOST} "chmod +x /tmp/generic-ubuntu-setup.sh && /tmp/generic-ubuntu-setup.sh --node $NODE_NUMBER"
    print_info "✅ Manual Linode setup complete"
    exit 0
fi

if [ -z "$LINODE_TOKEN" ]; then
    print_error "Linode API token required"
    exit 1
fi

if [ ! -f "${SSH_KEY_PATH}.pub" ]; then
    print_warning "SSH key not found at ${SSH_KEY_PATH}.pub"
    print_info "Generating new SSH key..."
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "xwift-linode"
fi

SSH_PUBLIC_KEY=$(cat "${SSH_KEY_PATH}.pub")
ROOT_PASS=$(openssl rand -base64 20 | tr -dc 'A-Za-z0-9!@#$%')

print_info "========================================"
print_info "Linode Deployment"
print_info "Node: $NODE_NUMBER"
print_info "Region: $LINODE_REGION"
print_info "Type: $LINODE_TYPE"
print_info "Label: $LABEL"
print_info "========================================"

CREATE_RESPONSE=$(curl -s -H "Authorization: Bearer $LINODE_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST https://api.linode.com/v4/linode/instances \
    -d '{
        "label":"'$LABEL'",
        "region":"'$LINODE_REGION'",
        "type":"'$LINODE_TYPE'",
        "image":"'$LINODE_IMAGE'",
        "root_pass":"'$ROOT_PASS'",
        "authorized_keys":["'$SSH_PUBLIC_KEY'"],
        "tags":["xwift","testnet","seed"]
    }')

LINODE_ID=$(echo "$CREATE_RESPONSE" | jq -r '.id')

if [ -z "$LINODE_ID" ] || [ "$LINODE_ID" = "null" ]; then
    print_error "Failed to create Linode"
    echo "$CREATE_RESPONSE" | jq .
    exit 1
fi

print_info "Linode created (ID: $LINODE_ID). Waiting for provisioning..."

# Wait for IP assignment
for i in {1..60}; do
    LINODE_INFO=$(curl -s -H "Authorization: Bearer $LINODE_TOKEN" "https://api.linode.com/v4/linode/instances/$LINODE_ID")
    STATUS=$(echo "$LINODE_INFO" | jq -r '.status')
    PUBLIC_IP=$(echo "$LINODE_INFO" | jq -r '.ipv4[0] // empty')
    if [ "$STATUS" = "running" ] && [ -n "$PUBLIC_IP" ]; then
        break
    fi
    print_info "Status: $STATUS (waiting for IP)..."
    sleep 10
done

if [ -z "$PUBLIC_IP" ]; then
    print_error "Failed to obtain Linode IP"
    exit 1
fi

print_info "Linode IP: $PUBLIC_IP"
print_info "Waiting for SSH..."
sleep 30

# Configure server
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scp -o StrictHostKeyChecking=no "$SCRIPT_DIR/generic-ubuntu-setup.sh" ${SSH_USER}@${PUBLIC_IP}:/tmp/
ssh -o StrictHostKeyChecking=no ${SSH_USER}@${PUBLIC_IP} "chmod +x /tmp/generic-ubuntu-setup.sh && /tmp/generic-ubuntu-setup.sh --node $NODE_NUMBER"

print_info "========================================"
print_info "✅ Linode seed node deployed"
print_info "Linode ID: $LINODE_ID"
print_info "IP: $PUBLIC_IP"
print_info "Node: $NODE_NUMBER"
print_info "========================================"

mkdir -p "$(dirname "$0")/../data"
echo "$PUBLIC_IP" > "$(dirname "$0")/../data/seed${NODE_NUMBER}-ip.txt"
echo "linode,$NODE_NUMBER,$PUBLIC_IP,$LINODE_ID,$(date)" >> "$(dirname "$0")/../data/deployments.csv"
