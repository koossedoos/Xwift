#!/bin/bash
# Xwift Testnet Metrics Collection Script
# Collects metrics from all seed nodes for validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
METRICS_FILE="$OUTPUT_DIR/metrics-${TIMESTAMP}.json"

# Seed nodes (update with actual IPs/hostnames)
declare -a SEED_NODES=(
    "localhost:29081"  # Seed 1
    # "seed2.xwift-testnet.network:29081"
    # "seed3.xwift-testnet.network:29081"
)

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
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to query node RPC
query_node() {
    local node=$1
    local endpoint=$2
    
    curl -s "http://${node}/${endpoint}" 2>/dev/null || echo "{}"
}

# Function to query JSON-RPC
query_jsonrpc() {
    local node=$1
    local method=$2
    local params=$3
    
    if [ -z "$params" ]; then
        params="{}"
    fi
    
    curl -s "http://${node}/json_rpc" \
        -H 'Content-Type: application/json' \
        -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"${method}\",\"params\":${params}}" \
        2>/dev/null || echo "{}"
}

# Collect metrics from all nodes
collect_all_metrics() {
    print_info "Collecting metrics from all seed nodes..."
    
    mkdir -p "$OUTPUT_DIR"
    
    echo "{" > "$METRICS_FILE"
    echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$METRICS_FILE"
    echo "  \"nodes\": [" >> "$METRICS_FILE"
    
    local first=true
    for node in "${SEED_NODES[@]}"; do
        if [ "$first" = false ]; then
            echo "," >> "$METRICS_FILE"
        fi
        first=false
        
        print_info "Querying node: $node"
        
        # Get node info
        local info=$(query_node "$node" "get_info")
        local height=$(echo "$info" | jq -r '.height // 0')
        local difficulty=$(echo "$info" | jq -r '.difficulty // 0')
        local tx_count=$(echo "$info" | jq -r '.tx_count // 0')
        local tx_pool_size=$(echo "$info" | jq -r '.tx_pool_size // 0')
        local alt_blocks_count=$(echo "$info" | jq -r '.alt_blocks_count // 0')
        local outgoing_conns=$(echo "$info" | jq -r '.outgoing_connections_count // 0')
        local incoming_conns=$(echo "$info" | jq -r '.incoming_connections_count // 0')
        
        # Get last block header
        local last_block=$(query_jsonrpc "$node" "get_last_block_header" "{}")
        local block_reward=$(echo "$last_block" | jq -r '.result.block_header.reward // 0')
        local block_size=$(echo "$last_block" | jq -r '.result.block_header.block_size // 0')
        local block_timestamp=$(echo "$last_block" | jq -r '.result.block_header.timestamp // 0')
        
        # Calculate metrics
        local hashrate=$(echo "scale=2; $difficulty / 30" | bc)
        
        cat >> "$METRICS_FILE" << EOF
    {
      "node": "$node",
      "height": $height,
      "difficulty": $difficulty,
      "hashrate": $hashrate,
      "tx_count": $tx_count,
      "tx_pool_size": $tx_pool_size,
      "alt_blocks_count": $alt_blocks_count,
      "outgoing_connections": $outgoing_conns,
      "incoming_connections": $incoming_conns,
      "last_block": {
        "reward": $block_reward,
        "size": $block_size,
        "timestamp": $block_timestamp
      }
    }
EOF
        
        print_info "  Height: $height | Difficulty: $difficulty | Connections: $outgoing_conns out / $incoming_conns in"
    done
    
    echo "" >> "$METRICS_FILE"
    echo "  ]" >> "$METRICS_FILE"
    echo "}" >> "$METRICS_FILE"
    
    print_info "✅ Metrics saved to: $METRICS_FILE"
}

# Check seed node connectivity
check_seeds() {
    print_info "Checking seed node connectivity..."
    
    local all_online=true
    
    for node in "${SEED_NODES[@]}"; do
        print_info "Checking: $node"
        
        local info=$(query_node "$node" "get_info")
        local height=$(echo "$info" | jq -r '.height // null')
        
        if [ "$height" = "null" ] || [ -z "$height" ]; then
            print_error "  ❌ Node is OFFLINE or not responding"
            all_online=false
        else
            print_info "  ✅ Node is ONLINE (height: $height)"
        fi
    done
    
    if [ "$all_online" = true ]; then
        print_info "✅ All seed nodes are online"
        return 0
    else
        print_warning "⚠️  Some seed nodes are offline"
        return 1
    fi
}

# Generate daily report
daily_report() {
    print_info "Generating daily report..."
    
    collect_all_metrics
    
    local report_file="$OUTPUT_DIR/daily-report-$(date +%Y%m%d).md"
    
    cat > "$report_file" << EOF
# Xwift Testnet Daily Report

**Date:** $(date)

## Network Status

EOF
    
    for node in "${SEED_NODES[@]}"; do
        local info=$(query_node "$node" "get_info")
        local height=$(echo "$info" | jq -r '.height // 0')
        local difficulty=$(echo "$info" | jq -r '.difficulty // 0')
        local hashrate=$(echo "scale=2; $difficulty / 30" | bc)
        local conns=$(echo "$info" | jq -r '.outgoing_connections_count // 0')
        
        cat >> "$report_file" << EOF
### Node: $node
- **Height:** $height
- **Difficulty:** $difficulty
- **Est. Hashrate:** $hashrate H/s
- **Connections:** $conns

EOF
    done
    
    cat >> "$report_file" << EOF
## Key Metrics

- **Orphan Rate:** To be calculated
- **Block Time:** ~30 seconds (target)
- **Network Health:** Active

## Next Actions

- Continue monitoring
- Run weekly tests
- Collect block propagation data

---
Generated: $(date)
EOF
    
    print_info "✅ Daily report saved to: $report_file"
    cat "$report_file"
}

# Parse command line arguments
case "${1:-}" in
    --check-seeds)
        check_seeds
        ;;
    --daily-report)
        daily_report
        ;;
    --collect)
        collect_all_metrics
        ;;
    *)
        echo "Usage: $0 [--check-seeds|--daily-report|--collect]"
        echo ""
        echo "Options:"
        echo "  --check-seeds   Check if all seed nodes are online"
        echo "  --daily-report  Generate daily validation report"
        echo "  --collect       Collect metrics to JSON file"
        exit 1
        ;;
esac
