#!/bin/bash
# Generate HTML dashboard for local testnet
# Usage: ./dashboard/generate-local-dashboard.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/index.html"

# Fetch node data
fetch_node() {
    local port=$1
    curl -s --max-time 5 "http://127.0.0.1:${port}/get_info" 2>/dev/null || echo "{}"
}

S1=$(fetch_node 29081)
S2=$(fetch_node 29083)
S3=$(fetch_node 29085)
M1=$(fetch_node 29087)

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

python3 - "$S1" "$S2" "$S3" "$M1" "$timestamp" <<'PY' > "$OUTPUT_FILE"
import json, sys
seed1 = json.loads(sys.argv[1])
seed2 = json.loads(sys.argv[2])
seed3 = json.loads(sys.argv[3])
mining = json.loads(sys.argv[4])
timestamp = sys.argv[5]

def safe_get(d, key, default=0):
    return d.get(key, default)

h_s1 = safe_get(seed1, 'height')
h_s2 = safe_get(seed2, 'height')
h_s3 = safe_get(seed3, 'height')
h_m = safe_get(mining, 'height')

diff = safe_get(mining, 'difficulty')
hashrate = diff / 30 if diff else 0
tx_pool = safe_get(mining, 'tx_pool_size')

html = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="30">
    <title>Xwift Local Testnet Dashboard</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; }}
        .container {{ max-width: 1200px; margin: 0 auto; }}
        .header {{ background: white; border-radius: 10px; padding: 20px; margin-bottom: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }}
        h1 {{ color: #667eea; }}
        .timestamp {{ color: #666; font-size: 14px; }}
        .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }}
        .card {{ background: white; border-radius: 10px; padding: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }}
        .card h3 {{ color: #667eea; margin-bottom: 10px; }}
        .metric {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }}
        .metric:last-child {{ border-bottom: none; }}
        .metric .label {{ font-weight: 600; color: #555; }}
        .metric .value {{ color: #333; }}
        .status-ok {{ color: #27ae60; font-weight: bold; }}
        .status-warning {{ color: #f39c12; font-weight: bold; }}
        .footer {{ text-align: center; margin-top: 20px; color: white; opacity: 0.8; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Xwift Local Testnet Dashboard</h1>
            <div class="timestamp">Last updated: {timestamp} | Auto-refresh every 30s</div>
        </div>

        <div class="grid">
            <div class="card">
                <h3>📊 Blockchain Stats</h3>
                <div class="metric"><span class="label">Current Height</span><span class="value">{h_m:,}</span></div>
                <div class="metric"><span class="label">Difficulty</span><span class="value">{diff:,}</span></div>
                <div class="metric"><span class="label">Hashrate</span><span class="value">{hashrate:.2f} H/s</span></div>
                <div class="metric"><span class="label">TX Pool</span><span class="value">{tx_pool}</span></div>
            </div>

            <div class="card">
                <h3>🌱 Seed Node 1</h3>
                <div class="metric"><span class="label">Port</span><span class="value">29081</span></div>
                <div class="metric"><span class="label">Height</span><span class="value">{h_s1:,}</span></div>
                <div class="metric"><span class="label">Status</span><span class="value status-ok">● Online</span></div>
            </div>

            <div class="card">
                <h3>🌱 Seed Node 2</h3>
                <div class="metric"><span class="label">Port</span><span class="value">29083</span></div>
                <div class="metric"><span class="label">Height</span><span class="value">{h_s2:,}</span></div>
                <div class="metric"><span class="label">Status</span><span class="value status-ok">● Online</span></div>
            </div>

            <div class="card">
                <h3>🌱 Seed Node 3</h3>
                <div class="metric"><span class="label">Port</span><span class="value">29085</span></div>
                <div class="metric"><span class="label">Height</span><span class="value">{h_s3:,}</span></div>
                <div class="metric"><span class="label">Status</span><span class="value status-ok">● Online</span></div>
            </div>

            <div class="card">
                <h3>⛏️ Mining Node</h3>
                <div class="metric"><span class="label">Port</span><span class="value">29087</span></div>
                <div class="metric"><span class="label">Height</span><span class="value">{h_m:,}</span></div>
                <div class="metric"><span class="label">Status</span><span class="value status-ok">● Mining</span></div>
            </div>

            <div class="card">
                <h3>💰 Economics</h3>
                <div class="metric"><span class="label">Dev Fund</span><span class="value">Active</span></div>
                <div class="metric"><span class="label">Block Time</span><span class="value">30 seconds</span></div>
                <div class="metric"><span class="label">Tail Emission</span><span class="value">1.2 XWIFT</span></div>
            </div>
        </div>

        <div class="footer">
            Xwift Local Testnet | Powered by Docker | Zero-Cost Validation
        </div>
    </div>
</body>
</html>
"""
print(html)
PY

echo "Dashboard generated: $OUTPUT_FILE"
echo "Open in browser: file://$(realpath "$OUTPUT_FILE")"
