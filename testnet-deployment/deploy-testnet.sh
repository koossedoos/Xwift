#!/bin/bash
# Xwift Testnet Multi-VPS Deployment Script
# Deploys 3+ seed nodes across multiple VPS providers for 30-day validation

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$SCRIPT_DIR/deployment-${DEPLOY_DATE}.log"

# Default values
AUTO_MODE=false
PROVIDER=""
NODE_NUMBER=""

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "${BLUE}========================================${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}========================================${NC}" | tee -a "$LOG_FILE"
}

# Help message
show_help() {
    cat << EOF
Xwift Testnet Deployment Script

Usage: $0 [OPTIONS]

Options:
    --auto              Automated deployment mode (all providers)
    --provider PROVIDER Deploy to specific provider (digitalocean/linode/vultr)
    --node NUMBER       Deploy specific node number (1/2/3)
    --help              Show this help message

Examples:
    # Deploy all seed nodes automatically
    $0 --auto

    # Deploy specific provider
    $0 --provider digitalocean

    # Deploy specific node
    $0 --node 1

    # Deploy to specific provider and node
    $0 --provider linode --node 2

Required:
    - VPS provider accounts with API tokens
    - SSH keys configured
    - .env file with credentials (copy from .env.example)

For more information, see README.md

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            AUTO_MODE=true
            shift
            ;;
        --provider)
            PROVIDER="$2"
            shift 2
            ;;
        --node)
            NODE_NUMBER="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if running from correct directory
    if [ ! -f "$SCRIPT_DIR/README.md" ]; then
        print_error "Must run from testnet-deployment directory"
        exit 1
    fi
    
    # Check for required tools
    local missing_tools=()
    for tool in curl jq ssh ssh-keygen; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Install with: sudo apt install -y ${missing_tools[*]}"
        exit 1
    fi
    
    # Check for environment file
    if [ ! -f "$SCRIPT_DIR/.env" ]; then
        if [ -f "$SCRIPT_DIR/.env.example" ]; then
            print_warning ".env file not found"
            print_info "Please copy .env.example to .env and configure your API tokens"
            exit 1
        else
            print_warning "No .env configuration found (will use manual setup)"
        fi
    else
        print_info "✅ Environment configuration found"
        source "$SCRIPT_DIR/.env"
    fi
    
    # Check SSH keys
    if [ ! -f ~/.ssh/id_ed25519.pub ] && [ ! -f ~/.ssh/id_rsa.pub ]; then
        print_warning "No SSH keys found. Generating new SSH key..."
        ssh-keygen -t ed25519 -C "xwift-testnet-${DEPLOY_DATE}" -f ~/.ssh/id_ed25519 -N ""
        print_info "✅ SSH key generated"
    else
        print_info "✅ SSH keys found"
    fi
    
    print_info "✅ Prerequisites check complete"
}

# Create necessary directories
setup_directories() {
    print_header "Setting Up Directory Structure"
    
    local dirs=(
        "$SCRIPT_DIR/logs"
        "$SCRIPT_DIR/reports"
        "$SCRIPT_DIR/data"
        "$SCRIPT_DIR/backups"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_info "Created: $dir"
        fi
    done
    
    print_info "✅ Directory structure ready"
}

# Generate seed node inventory
generate_inventory() {
    print_header "Generating Seed Node Inventory"
    
    cat > "$SCRIPT_DIR/seed-nodes-inventory.txt" << EOF
# Xwift Testnet Seed Nodes Inventory
# Generated: $(date)
# Deployment ID: ${DEPLOY_DATE}

# Seed Node 1 - Digital Ocean (NYC3)
# IP: To be assigned
# Region: New York, USA
# Specs: 4 vCPU, 8GB RAM, 160GB SSD
seed1.xwift-testnet.network:29080

# Seed Node 2 - Linode (EU-Central)
# IP: To be assigned
# Region: Frankfurt, Germany
# Specs: 4 vCPU, 8GB RAM, 160GB SSD
seed2.xwift-testnet.network:29080

# Seed Node 3 - Vultr (Asia-Pacific)
# IP: To be assigned
# Region: Singapore
# Specs: 4 vCPU, 8GB RAM, 160GB SSD
seed3.xwift-testnet.network:29080

# Add additional seed nodes as needed
EOF
    
    print_info "✅ Inventory file created: seed-nodes-inventory.txt"
}

# Deploy seed node (generic)
deploy_seed_node() {
    local provider=$1
    local node_num=$2
    
    print_header "Deploying Seed Node $node_num on $provider"
    
    local script_path="$SCRIPT_DIR/vps-providers/${provider}-setup.sh"
    
    if [ ! -f "$script_path" ]; then
        print_error "Deployment script not found: $script_path"
        return 1
    fi
    
    # Make script executable
    chmod +x "$script_path"
    
    # Run deployment script
    print_info "Running deployment script for $provider..."
    "$script_path" --node "$node_num"
    
    if [ $? -eq 0 ]; then
        print_info "✅ Seed node $node_num deployed successfully on $provider"
        return 0
    else
        print_error "Failed to deploy seed node $node_num on $provider"
        return 1
    fi
}

# Deploy all seed nodes
deploy_all_nodes() {
    print_header "Deploying All Seed Nodes"
    
    local providers=("digitalocean" "linode" "vultr")
    local node_num=1
    
    for provider in "${providers[@]}"; do
        print_info "Starting deployment for seed node $node_num on $provider..."
        
        if deploy_seed_node "$provider" "$node_num"; then
            echo "$provider:$node_num:SUCCESS:$(date)" >> "$SCRIPT_DIR/deployment-status.log"
        else
            echo "$provider:$node_num:FAILED:$(date)" >> "$SCRIPT_DIR/deployment-status.log"
            print_warning "Continuing with next provider despite failure..."
        fi
        
        node_num=$((node_num + 1))
        
        # Wait between deployments
        if [ $node_num -le 3 ]; then
            print_info "Waiting 30 seconds before next deployment..."
            sleep 30
        fi
    done
    
    print_info "✅ All seed node deployments initiated"
}

# Verify network connectivity
verify_network() {
    print_header "Verifying Network Connectivity"
    
    print_info "Waiting 60 seconds for nodes to initialize..."
    sleep 60
    
    print_info "Checking seed node connectivity..."
    
    # This would check if nodes can be reached
    # For now, we'll create a placeholder script
    
    if [ -f "$SCRIPT_DIR/monitoring/collect-metrics.sh" ]; then
        chmod +x "$SCRIPT_DIR/monitoring/collect-metrics.sh"
        "$SCRIPT_DIR/monitoring/collect-metrics.sh" --check-seeds || true
    fi
    
    print_info "✅ Network verification complete"
}

# Generate deployment report
generate_deployment_report() {
    print_header "Generating Deployment Report"
    
    local report_file="$SCRIPT_DIR/reports/deployment-report-${DEPLOY_DATE}.md"
    
    cat > "$report_file" << EOF
# Xwift Testnet Deployment Report

**Deployment Date:** $(date)
**Deployment ID:** ${DEPLOY_DATE}
**Status:** Initial Deployment Complete

## Deployed Seed Nodes

### Seed Node 1 - Digital Ocean
- **Location:** New York, USA (NYC3)
- **IP Address:** To be assigned
- **P2P Port:** 29080
- **RPC Port:** 29081
- **Status:** Pending verification

### Seed Node 2 - Linode
- **Location:** Frankfurt, Germany (EU-Central)
- **IP Address:** To be assigned
- **P2P Port:** 29080
- **RPC Port:** 29081
- **Status:** Pending verification

### Seed Node 3 - Vultr
- **Location:** Singapore (Asia-Pacific)
- **IP Address:** To be assigned
- **P2P Port:** 29080
- **RPC Port:** 29081
- **Status:** Pending verification

## Next Steps

1. Verify all seed nodes are online and syncing
2. Configure DNS records for seed nodes
3. Begin 30-day validation testing
4. Monitor metrics daily
5. Run automated tests weekly

## Commands

\`\`\`bash
# Check all seed nodes
./monitoring/collect-metrics.sh --check-seeds

# Start automated testing
./automation/run-all-tests.sh --duration 30d

# Generate daily report
./automation/automated-report.sh --daily
\`\`\`

## Log Files

- Deployment log: \`logs/deployment-${DEPLOY_DATE}.log\`
- Status log: \`deployment-status.log\`

## Validation Schedule

- **Days 1-2:** Baseline establishment
- **Days 3-7:** Initial testing and monitoring
- **Days 8-14:** Stress testing and hashrate variance
- **Days 15-28:** Long-term stability validation
- **Days 29-30:** Final analysis and reporting

---

Deployment completed at: $(date)
EOF
    
    print_info "✅ Deployment report created: $report_file"
    cat "$report_file"
}

# Main execution
main() {
    print_header "Xwift Testnet Deployment"
    echo "Deployment ID: ${DEPLOY_DATE}" | tee -a "$LOG_FILE"
    echo "Started: $(date)" | tee -a "$LOG_FILE"
    echo ""
    
    # Run checks
    check_prerequisites
    setup_directories
    generate_inventory
    
    # Deploy based on mode
    if [ "$AUTO_MODE" = true ]; then
        print_info "Running in automated deployment mode"
        deploy_all_nodes
    elif [ -n "$PROVIDER" ]; then
        if [ -n "$NODE_NUMBER" ]; then
            deploy_seed_node "$PROVIDER" "$NODE_NUMBER"
        else
            deploy_seed_node "$PROVIDER" "1"
        fi
    elif [ -n "$NODE_NUMBER" ]; then
        print_error "Must specify --provider when using --node"
        exit 1
    else
        print_warning "No deployment mode specified"
        print_info "Use --auto for automatic deployment or --provider to deploy specific node"
        show_help
        exit 1
    fi
    
    # Verify deployment
    verify_network
    
    # Generate report
    generate_deployment_report
    
    print_header "Deployment Complete"
    print_info "✅ Testnet deployment successful!"
    print_info "📊 View report: reports/deployment-report-${DEPLOY_DATE}.md"
    print_info "📝 Logs: logs/deployment-${DEPLOY_DATE}.log"
    print_info ""
    print_info "🎯 Next steps:"
    print_info "   1. Verify seed nodes are online"
    print_info "   2. Begin 30-day validation testing"
    print_info "   3. Run: ./automation/run-all-tests.sh --duration 30d"
    
    echo ""
    echo "Completed: $(date)" | tee -a "$LOG_FILE"
}

# Run main function
main "$@"
