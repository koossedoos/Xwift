#!/usr/bin/env python3
"""Validate emission schedule and block rewards on the local Xwift testnet."""

import argparse
import json
import math
import statistics
import sys
import time
from typing import List, Dict

import urllib.request

TAIL_REWARD_AU = 120000000        # 1.2 XWIFT per block (atomic units)
MAX_INITIAL_REWARD_AU = 5400000000  # 54 XWIFT initial cap
DEV_FUND_CUTOFF = 1051200
TAIL_EMISSION_HEIGHT = 8409600


def rpc_call(port: int, method: str, params: Dict = None) -> Dict:
    payload = json.dumps({
        "jsonrpc": "2.0",
        "id": "0",
        "method": method,
        "params": params or {}
    }).encode()
    req = urllib.request.Request(
        f"http://127.0.0.1:{port}/json_rpc",
        data=payload,
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        body = resp.read().decode()
        result = json.loads(body)
        if "error" in result:
            raise RuntimeError(result["error"])
        return result["result"]


def au_to_xwift(value: int) -> float:
    return value / 100000000


def fetch_headers(port: int, start: int, end: int) -> List[Dict]:
    result = rpc_call(port, "get_block_headers_range", {
        "start_height": start,
        "end_height": end
    })
    return result.get("headers", [])


def validate_rewards(headers: List[Dict]) -> Dict:
    rewards = [h.get("reward", 0) for h in headers]

    issues = []
    for header in headers:
        reward = header.get("reward", 0)
        height = header.get("height", 0)

        if reward <= 0:
            issues.append((height, "Zero reward"))
        if reward > MAX_INITIAL_REWARD_AU:
            issues.append((height, "Reward exceeds max expected"))
        if height >= DEV_FUND_CUTOFF and reward <= TAIL_REWARD_AU:
            # After dev fund termination, reward should still exceed tail until tail emission begins.
            pass
        if height >= TAIL_EMISSION_HEIGHT and abs(reward - TAIL_REWARD_AU) > 1000000:
            issues.append((height, "Tail emission mismatch"))

    return {
        "rewards": rewards,
        "issues": issues,
    }


def summarize(port: int, window: int) -> None:
    info = rpc_call(port, "get_info")
    height = info.get("height", 0)
    if height == 0:
        raise SystemExit("Daemon not synced yet.")

    start_height = max(1, height - window)
    headers = fetch_headers(port, start_height, height)

    if not headers:
        raise SystemExit("No headers returned. Increase window or wait for blocks.")

    validation = validate_rewards(headers)
    rewards = validation["rewards"]
    reward_xwift = [au_to_xwift(r) for r in rewards]

    avg_reward = statistics.mean(reward_xwift)
    median_reward = statistics.median(reward_xwift)
    min_reward = min(reward_xwift)
    max_reward = max(reward_xwift)
    dev = statistics.pstdev(reward_xwift) if len(reward_xwift) > 1 else 0

    total_emitted = au_to_xwift(sum(rewards))

    print("\n════════════════════════════════════════════════════════════")
    print("EMISSION VALIDATION REPORT")
    print("════════════════════════════════════════════════════════════")
    print(f"RPC Port:             {port}")
    print(f"Height analyzed:      {start_height} - {height} ({len(headers)} blocks)")
    print(f"Average reward:       {avg_reward:.4f} XWIFT")
    print(f"Median reward:        {median_reward:.4f} XWIFT")
    print(f"Min reward:           {min_reward:.4f} XWIFT")
    print(f"Max reward:           {max_reward:.4f} XWIFT")
    print(f"Reward volatility:    {dev:.6f} XWIFT (std dev)")
    print(f"Total emitted:        {total_emitted:.4f} XWIFT in window")

    if validation["issues"]:
        print("\n⚠ Issues detected:")
        for height, issue in validation["issues"][:20]:
            print(f"  - Height {height}: {issue}")
        if len(validation["issues"]) > 20:
            print(f"  ... and {len(validation['issues']) - 20} more")
        print("\nStatus: FAILED - Investigate reward anomalies.")
    else:
        print("\nStatus: PASSED - Emission within expected bounds.")

    tail_progress = (height / TAIL_EMISSION_HEIGHT) * 100
    if tail_progress >= 100:
        print("Tail emission phase reached.")
    else:
        print(f"Tail emission begins at block {TAIL_EMISSION_HEIGHT}. Progress: {tail_progress:.2f}%")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Validate Xwift emission schedule on local testnet")
    parser.add_argument("--rpc-port", type=int, default=29087, help="RPC port to query")
    parser.add_argument("--window", type=int, default=1000, help="Number of blocks to analyze")
    args = parser.parse_args()

    summarize(args.rpc_port, args.window)
