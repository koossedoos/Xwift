#!/usr/bin/env python3
"""
Xwift Emission Schedule Validator
Validates actual block rewards against expected emission curve
"""

import json
import sys
import argparse
from datetime import datetime
import requests

# Xwift constants (8 decimal places)
COIN = 100_000_000  # 1 XFT = 100M atomic units
MONEY_SUPPLY = 72_500_000 * COIN  # Pre-tail supply
EMISSION_SPEED_FACTOR_PER_MINUTE = 20
FINAL_SUBSIDY_PER_MINUTE = 240_000_000  # 2.4 XFT/minute tail
TARGET_BLOCK_TIME = 30  # seconds

def calculate_expected_reward(already_generated):
    """Calculate expected block reward based on Xwift emission curve"""
    base_reward = (MONEY_SUPPLY - already_generated) >> EMISSION_SPEED_FACTOR_PER_MINUTE
    base_reward = base_reward * TARGET_BLOCK_TIME // 60
    final_subsidy = FINAL_SUBSIDY_PER_MINUTE * TARGET_BLOCK_TIME // 60
    return max(base_reward, final_subsidy)

def rpc_call(endpoint, method, params=None):
    """Make JSON-RPC call to Xwift daemon"""
    if params is None:
        params = {}
    
    payload = {
        "jsonrpc": "2.0",
        "id": "0",
        "method": method,
        "params": params
    }
    
    try:
        response = requests.post(
            f"http://{endpoint}/json_rpc",
            json=payload,
            timeout=10
        )
        return response.json()
    except Exception as e:
        print(f"RPC Error: {e}", file=sys.stderr)
        return None

def get_block_header(endpoint, height):
    """Get block header by height"""
    result = rpc_call(endpoint, "get_block_header_by_height", {"height": height})
    if result and "result" in result:
        return result["result"]["block_header"]
    return None

def validate_emission(endpoint, checkpoints, output_file=None):
    """Validate emission at specific checkpoints"""
    print("=" * 60)
    print("Xwift Emission Schedule Validation")
    print(f"Node: {endpoint}")
    print(f"Timestamp: {datetime.utcnow().isoformat()}")
    print("=" * 60)
    
    results = []
    already_generated = 0
    
    for height in checkpoints:
        print(f"\nValidating height {height}...")
        
        # Get block header
        header = get_block_header(endpoint, height)
        
        if header is None:
            print(f"  ❌ Failed to fetch block {height}")
            results.append({
                "height": height,
                "status": "error",
                "message": "Failed to fetch block"
            })
            continue
        
        # Get actual reward
        actual_reward = header.get("reward", 0)
        
        # Calculate expected reward
        expected_reward = calculate_expected_reward(already_generated)
        
        # Convert to XFT for display
        actual_xft = actual_reward / COIN
        expected_xft = expected_reward / COIN
        
        # Calculate difference
        diff_percent = 0
        if expected_reward > 0:
            diff_percent = ((actual_reward - expected_reward) / expected_reward) * 100
        
        # Check if within tolerance (0.1%)
        passed = abs(diff_percent) < 0.1
        
        status_icon = "✅" if passed else "❌"
        print(f"  {status_icon} Height {height}:")
        print(f"     Expected: {expected_xft:.8f} XFT ({expected_reward} atomic)")
        print(f"     Actual:   {actual_xft:.8f} XFT ({actual_reward} atomic)")
        print(f"     Diff:     {diff_percent:.4f}%")
        
        results.append({
            "height": height,
            "expected_reward": expected_reward,
            "actual_reward": actual_reward,
            "expected_xft": expected_xft,
            "actual_xft": actual_xft,
            "diff_percent": diff_percent,
            "passed": passed
        })
        
        # Update already_generated for next iteration
        # (This is approximate - would need to sum all previous blocks for perfect accuracy)
        already_generated += actual_reward
    
    # Summary
    print("\n" + "=" * 60)
    passed_count = sum(1 for r in results if r.get("passed", False))
    total_count = len([r for r in results if "passed" in r])
    print(f"Summary: {passed_count}/{total_count} checkpoints passed")
    
    if passed_count == total_count:
        print("✅ PASS: Emission schedule is accurate")
    else:
        print("❌ FAIL: Emission schedule has discrepancies")
    
    print("=" * 60)
    
    # Save to file if requested
    if output_file:
        with open(output_file, 'w') as f:
            json.dump({
                "timestamp": datetime.utcnow().isoformat(),
                "node": endpoint,
                "checkpoints": results,
                "passed": passed_count,
                "total": total_count
            }, f, indent=2)
        print(f"\nResults saved to: {output_file}")
    
    return passed_count == total_count

def main():
    parser = argparse.ArgumentParser(description="Validate Xwift emission schedule")
    parser.add_argument("--node", default="localhost:29081", help="RPC endpoint (default: localhost:29081)")
    parser.add_argument("--checkpoints", nargs="+", type=int, 
                        default=[1, 100, 1000, 10000, 100000],
                        help="Block heights to validate")
    parser.add_argument("--output", help="Output JSON file")
    
    args = parser.parse_args()
    
    # Validate emission
    success = validate_emission(args.node, args.checkpoints, args.output)
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
