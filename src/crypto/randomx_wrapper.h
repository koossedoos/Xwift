// Copyright (c) 2014-2024, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Xwift: RandomX PoW wrapper for mining and validation

#pragma once

#include <cstdint>
#include <vector>
#include "hash.h"

namespace cryptonote {

/**
 * @class RandomXMiner
 * @brief Wrapper for RandomX mining algorithm
 *
 * Xwift uses standard RandomX (unmodified) for ASIC resistance.
 * This wrapper provides a clean interface for block mining and validation.
 */
class RandomXMiner {
public:
  /**
   * Initialize RandomX context with a seed
   * @param seed Seed data for VM initialization (typically previous block hash)
   */
  static void init_context(const uint8_t* seed);

  /**
   * Hash a block using RandomX
   * @param block_header Block data to hash
   * @return 256-bit hash result
   */
  static crypto::hash hash_block(const std::vector<uint8_t>& block_header);

  /**
   * Verify proof of work
   * @param hash Block hash
   * @param difficulty Difficulty target
   * @return true if hash meets difficulty threshold, false otherwise
   */
  static bool verify_proof_of_work(const crypto::hash& hash, uint64_t difficulty);

  /**
   * Cleanup RandomX resources
   */
  static void cleanup();

private:
  // Private constructor - this is a utility class with static methods only
  RandomXMiner() = delete;
};

} // namespace cryptonote
