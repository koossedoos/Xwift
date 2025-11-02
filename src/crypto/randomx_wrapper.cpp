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
// Xwift: RandomX PoW wrapper - Simple implementation for mining

#include "hash.h"
#include "int-util.h"
#include <cstring>
#include <memory>

// RandomX includes
#include "randomx.h"

#undef MONERO_DEFAULT_LOG_CATEGORY
#define MONERO_DEFAULT_LOG_CATEGORY "randomx"

namespace cryptonote {

// Simple RandomX cache for Xwift
struct RandomXCache {
    randomx_cache *cache;
    std::string seed_hash;

    RandomXCache() : cache(nullptr) {}
    ~RandomXCache() {
        if (cache) {
            randomx_release_cache(cache);
        }
    }
};

static std::unique_ptr<RandomXCache> g_rx_cache;

bool rx_slow_hash(const char* seed_hash, const void* data, size_t length, crypto::hash& hash) {
    // Initialize RandomX cache if needed
    if (!g_rx_cache) {
        g_rx_cache = std::make_unique<RandomXCache>();
        g_rx_cache->cache = randomx_alloc_cache(RANDOMX_FLAG_DEFAULT);
        if (!g_rx_cache->cache) {
            return false;
        }
    }

    // Update cache if seed hash changed
    if (g_rx_cache->seed_hash != std::string(seed_hash, 32)) {
        g_rx_cache->seed_hash = std::string(seed_hash, 32);
        randomx_init_cache(g_rx_cache->cache, seed_hash, 32);
    }

    // Create VM (no dataset needed for simple hashing)
    randomx_vm* vm = randomx_create_vm(RANDOMX_FLAG_DEFAULT, g_rx_cache->cache, nullptr);
    if (!vm) {
        return false;
    }

    // Compute hash
    randomx_calculate_hash(vm, data, length, &hash);

    // Cleanup
    randomx_destroy_vm(vm);

    return true;
}

// Xwift-specific difficulty integration
uint64_t calculate_difficulty(const std::vector<uint64_t>& timestamps,
                             const std::vector<uint64_t>& cumulative_difficulties) {
    // Simple difficulty calculation for Xwift's 10-second blocks
    // This can be enhanced later with more sophisticated algorithms

    if (timestamps.size() < 2) {
        return 1;
    }

    // Use last 10 blocks for difficulty calculation
    const size_t window = 10;
    size_t start = timestamps.size() > window ? timestamps.size() - window : 0;

    if (timestamps.size() - start < 2) {
        return 1;
    }

    uint64_t work_difficulty = cumulative_difficulties.back() - cumulative_difficulties[start];
    uint64_t time_span = timestamps.back() - timestamps[start];

    if (time_span == 0) {
        return cumulative_difficulties.back();
    }

    uint64_t difficulty = work_difficulty / time_span;

    // Apply Xwift's 4x bounds (will be enforced by consensus engine)
    return difficulty;
}

} // namespace cryptonote