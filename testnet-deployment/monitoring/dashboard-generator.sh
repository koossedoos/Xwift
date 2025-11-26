#!/bin/bash
# Dashboard Generator for Xwift Testnet Metrics

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="$SCRIPT_DIR/../reports"
OUTPUT_FILE="$REPORT_DIR/dashboard.html"
LATEST_METRICS=$(ls -t "$REPORT_DIR"/metrics-*.json 2>/dev/null | head -1)

if [ -z "$LATEST_METRICS" ]; then
    echo "No metrics JSON files found. Run collect-metrics.sh first." >&2
    exit 1
fi

cat > "$OUTPUT_FILE" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Xwift Testnet Dashboard</title>
<style>
body { font-family: Arial, sans-serif; background: #0d1117; color: #c9d1d9; }
.container { max-width: 900px; margin: 40px auto; padding: 20px; background: #161b22; border-radius: 12px; }
h1 { color: #58a6ff; }
table { width: 100%; border-collapse: collapse; margin-top: 20px; }
th, td { padding: 12px; border-bottom: 1px solid #30363d; text-align: left; }
th { background: #21262d; }
.status-pass { color: #3fb950; }
.status-warn { color: #d29922; }
.status-fail { color: #f85149; }
.metric-card { padding: 15px; border-radius: 8px; background: #21262d; margin-bottom: 10px; }
small { color: #8b949e; }
code { background: #21262d; padding: 2px 4px; border-radius: 4px; }
</style>
</head>
<body>
<div class="container">
<h1>🚀 Xwift Testnet Dashboard</h1>
<p>Last updated: $(date -r "$LATEST_METRICS" +"%Y-%m-%d %H:%M:%S %Z")</p>
EOF

# Node table
echo "<h2>Node Status</h2>" >> "$OUTPUT_FILE"
echo "<table>" >> "$OUTPUT_FILE"
echo "<tr><th>Node</th><th>Height</th><th>Difficulty</th><th>Hashrate (H/s)</th><th>Connections (out/in)</th></tr>" >> "$OUTPUT_FILE"

cat "$LATEST_METRICS" | jq -c '.nodes[]' | while read -r node; do
    name=$(echo "$node" | jq -r '.node')
    height=$(echo "$node" | jq -r '.height')
    difficulty=$(echo "$node" | jq -r '.difficulty')
    hashrate=$(echo "$node" | jq -r '.hashrate')
    outgoing=$(echo "$node" | jq -r '.outgoing_connections')
    incoming=$(echo "$node" | jq -r '.incoming_connections')
    echo "<tr><td>$name</td><td>$height</td><td>$difficulty</td><td>$hashrate</td><td>$outgoing / $incoming</td></tr>" >> "$OUTPUT_FILE"
done

echo "</table>" >> "$OUTPUT_FILE"

# Metrics summary
echo "<h2>Key Metrics</h2>" >> "$OUTPUT_FILE"

latest_orphan=$(ls -t "$REPORT_DIR"/orphan-rate-*.log 2>/dev/null | head -1)
if [ -n "$latest_orphan" ]; then
    orphan_rate=$(grep -oP 'Orphan rate: \K[0-9.]+' "$latest_orphan" | tail -1)
else
    orphan_rate="N/A"
fi

latest_diff=$(ls -t "$REPORT_DIR"/difficulty-*.csv 2>/dev/null | head -1)
if [ -n "$latest_diff" ]; then
    avg_block_time=$(tail -100 "$latest_diff" | awk -F',' 'NR>1 {sum+=$4; count++} END {if(count>0) printf "%.2f", sum/count; else print "N/A"}')
else
    avg_block_time="N/A"
fi

cat >> "$OUTPUT_FILE" << EOF
<div class="metric-card">
<strong>Orphan Rate:</strong> $orphan_rate% <small>(target < 5%)</small>
</div>
<div class="metric-card">
<strong>Average Block Time:</strong> $avg_block_time seconds <small>(target 30±3s)</small>
</div>
<div class="metric-card">
<strong>Metrics Source:</strong> <code>$(basename "$LATEST_METRICS")</code>
</div>
EOF

cat >> "$OUTPUT_FILE" << EOF
<h2>Next Actions</h2>
<ul>
  <li>Run <code>./automation/run-all-tests.sh --duration 30</code> to start full validation</li>
  <li>Generate daily report via <code>./monitoring/collect-metrics.sh --daily-report</code></li>
  <li>Update <code>reports/TESTNET_VALIDATION_REPORT.md</code> with latest findings</li>
</ul>

<p style="margin-top:30px;">Generated on $(date).</p>
</div>
</body>
</html>
EOF

echo "Dashboard generated: $OUTPUT_FILE"
