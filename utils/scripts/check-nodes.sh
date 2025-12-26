#!/bin/bash
# Xwift Node Status Check Script

echo "=== Xwift Node Status Check ==="
echo "Timestamp: $(date)"
echo ""

echo "=== Mainnet Status ==="
if curl -s http://localhost:18081/get_info > /dev/null 2>&1; then
    HEIGHT=$(curl -s http://localhost:18081/get_info | jq -r '.height')
    DIFFICULTY=$(curl -s http://localhost:18081/get_info | jq -r '.difficulty')
    CONNECTIONS=$(curl -s http://localhost:18081/get_info | jq -r '.outgoing_connections_count')
    echo "✅ Mainnet: ONLINE (Height: $HEIGHT, Difficulty: $DIFFICULTY, Connections: $CONNECTIONS)"
else
    echo "❌ Mainnet: OFFLINE"
fi

echo ""
echo "=== Testnet Status ==="
if curl -s http://localhost:28081/get_info > /dev/null 2>&1; then
    HEIGHT=$(curl -s http://localhost:28081/get_info | jq -r '.height')
    DIFFICULTY=$(curl -s http://localhost:28081/get_info | jq -r '.difficulty')
    CONNECTIONS=$(curl -s http://localhost:28081/get_info | jq -r '.outgoing_connections_count')
    echo "✅ Testnet: ONLINE (Height: $HEIGHT, Difficulty: $DIFFICULTY, Connections: $CONNECTIONS)"
else
    echo "❌ Testnet: OFFLINE"
fi

echo ""
echo "=== System Resource Usage ==="
echo "Memory Usage: $(free -h | grep Mem)"
echo "Disk Usage: $(df -h /var/lib/xwift-* | tail -n +2)"
echo "CPU Load: $(uptime)"

echo ""
echo "=== Service Status ==="
systemctl is-active xwift-mainnet 2>/dev/null || echo "mainnet: service not found"
systemctl is-active xwift-testnet 2>/dev/null || echo "testnet: service not found"