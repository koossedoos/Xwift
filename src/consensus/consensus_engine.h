// Copyright (c) 2024, The Xwift Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met (see LICENSE file).

#pragma once

#include <cstdint>
#include <vector>
#include <unordered_map>
#include "crypto/hash.h"

// Forward declarations
namespace cryptonote {
  struct block;
  class Blockchain;
  struct block_header;
}

namespace xwift_consensus {

/**
 * @class ConsensusEngine
 * @brief Xwift-specific consensus rules including uncle blocks and publish-or-perish
 *
 * This consensus engine implements:
 * 1. Uncle block validation and rewards (50-70% of base reward based on depth)
 * 2. Publish-or-perish defense (prevents selfish mining attacks)
 * 3. Difficulty bounds (4x maximum change per adjustment)
 */
class ConsensusEngine {
public:
  /**
   * Validate uncle blocks in a block
   * @param block Block containing uncles
   * @param chain Blockchain reference for orphan lookup
   * @return true if all uncles valid, false otherwise
   */
  static bool validate_uncle_blocks(const cryptonote::block& block, const cryptonote::Blockchain& chain);

  /**
   * Calculate reward for an uncle block
   * @param base_reward Normal block reward
   * @param uncle_depth Depth of uncle (1-7, where 1 is immediate previous block)
   * @return Uncle reward in atomic units
   *
   * Reward schedule:
   * - Depth 1: 70% of base reward
   * - Depth 2: 60% of base reward
   * - Depth 3: 55% of base reward
   * - Depth 4+: 50% of base reward
   */
  static uint64_t calculate_uncle_reward(uint64_t base_reward, uint32_t uncle_depth);

  /**
   * Check publish-or-perish defense rule
   * @param block Block being validated
   * @param chain Blockchain reference
   * @return true if block passes pub-or-perish check, false otherwise
   *
   * Detects if a single miner has >25% hashrate and enforces publication deadline.
   * Blocks from concentrated entities published after deadline are rejected.
   */
  static bool check_publish_or_perish(const cryptonote::block& block, const cryptonote::Blockchain& chain);

  /**
   * Estimate hashrate concentration in recent blocks
   * @param chain Blockchain reference
   * @param window_size Number of recent blocks to analyze (default 100)
   * @return true if >25% hashrate concentration detected, false otherwise
   */
  static bool estimate_hashrate_concentration(const cryptonote::Blockchain& chain, uint64_t window_size = 100);

  /**
   * Calculate publish deadline for current block height
   * @param current_height Block height
   * @param last_block_timestamp Timestamp of previous block
   * @return Deadline timestamp in seconds
   *
   * Formula: deadline = last_block.timestamp + (DIFFICULTY_TARGET_V2 * 1.25)
   * For Xwift: 10s blocks → 12.5 second deadline (2.5s buffer for network propagation)
   */
  static uint64_t calculate_publish_deadline(uint64_t current_height, uint64_t last_block_timestamp);

  /**
   * Detect potential selfish mining attempts
   * @param chain Blockchain reference
   * @return true if suspicious mining pattern detected, false otherwise
   *
   * Heuristics:
   * - Concentrated entity publishes blocks at deadline boundary
   * - Unusual gap followed by block burst
   * - Triggers logging for monitoring
   */
  static bool detect_selfish_mining_attempt(const cryptonote::Blockchain& chain);

  /**
   * Apply difficulty bounds (4x maximum change)
   * @param old_difficulty Previous difficulty
   * @param new_difficulty Proposed new difficulty
   * @return Bounded difficulty in range [old/4, old*4]
   */
  static uint64_t apply_difficulty_bounds(uint64_t old_difficulty, uint64_t new_difficulty);

private:
  // Constants for uncle block validation
  static constexpr uint32_t MAX_UNCLE_BLOCKS_PER_BLOCK = 2;
  static constexpr uint32_t MAX_UNCLE_DEPTH = 7;
  static constexpr uint32_t PUBLISH_OR_PERISH_THRESHOLD = 25; // 25% hashrate concentration
  static constexpr uint64_t PUBLISH_DEADLINE_MULTIPLIER = 125; // 1.25x block time

  // Private constructor - utility class with static methods
  ConsensusEngine() = delete;
};

} // namespace xwift_consensus
