// Xwift Consensus Engine Validation Test
// Tests all consensus functionality offline

#include <iostream>
#include <cassert>
#include <cstdint>

#include "consensus/consensus_engine.h"
#include "cryptonote_basic/cryptonote_basic.h"
#include "cryptonote_config.h"
#include "cryptonote_core/cryptonote_tx_utils.h"

using namespace xwift_consensus;
using namespace cryptonote;

void test_uncle_reward_calculation() {
    std::cout << "Testing uncle reward calculation..." << std::endl;

    const uint64_t base_reward = 1000000000000; // 1 XFT

    // Test depth 1: should be 70%
    uint64_t reward_depth1 = ConsensusEngine::calculate_uncle_reward(base_reward, 1);
    assert(reward_depth1 == 700000000000);
    std::cout << "✓ Depth 1 (70%): " << reward_depth1 << std::endl;

    // Test depth 2: should be 60%
    uint64_t reward_depth2 = ConsensusEngine::calculate_uncle_reward(base_reward, 2);
    assert(reward_depth2 == 600000000000);
    std::cout << "✓ Depth 2 (60%): " << reward_depth2 << std::endl;

    // Test depth 3: should be 55%
    uint64_t reward_depth3 = ConsensusEngine::calculate_uncle_reward(base_reward, 3);
    assert(reward_depth3 == 550000000000);
    std::cout << "✓ Depth 3 (55%): " << reward_depth3 << std::endl;

    // Test depth 4: should be 50%
    uint64_t reward_depth4 = ConsensusEngine::calculate_uncle_reward(base_reward, 4);
    assert(reward_depth4 == 500000000000);
    std::cout << "✓ Depth 4 (50%): " << reward_depth4 << std::endl;

    // Test depth 8: should also be 50%
    uint64_t reward_depth8 = ConsensusEngine::calculate_uncle_reward(base_reward, 8);
    assert(reward_depth8 == 500000000000);
    std::cout << "✓ Depth 8 (50%): " << reward_depth8 << std::endl;

    // Test invalid depth 0: should return 0
    uint64_t reward_invalid = ConsensusEngine::calculate_uncle_reward(base_reward, 0);
    assert(reward_invalid == 0);
    std::cout << "✓ Invalid depth 0: " << reward_invalid << std::endl;

    std::cout << "✅ Uncle reward calculation tests passed!" << std::endl;
}

void test_difficulty_bounds() {
    std::cout << "\nTesting difficulty bounds..." << std::endl;

    const uint64_t base_difficulty = 1000;

    // Test normal increase within bounds
    uint64_t diff_increase = ConsensusEngine::apply_difficulty_bounds(base_difficulty, 2000);
    assert(diff_increase == 2000);
    std::cout << "✓ 2x increase: " << diff_increase << std::endl;

    // Test maximum allowed increase (4x)
    uint64_t diff_max_increase = ConsensusEngine::apply_difficulty_bounds(base_difficulty, 4000);
    assert(diff_max_increase == 4000);
    std::cout << "✓ 4x increase (max): " << diff_max_increase << std::endl;

    // Test excessive increase (should be clamped to 4x)
    uint64_t diff_excessive = ConsensusEngine::apply_difficulty_bounds(base_difficulty, 8000);
    assert(diff_excessive == 4000);
    std::cout << "✓ 8x increase (clamped to 4x): " << diff_excessive << std::endl;

    // Test normal decrease within bounds
    uint64_t diff_decrease = ConsensusEngine::apply_difficulty_bounds(base_difficulty, 500);
    assert(diff_decrease == 500);
    std::cout << "✓ 2x decrease: " << diff_decrease << std::endl;

    // Test maximum allowed decrease (4x)
    uint64_t diff_max_decrease = ConsensusEngine::apply_difficulty_bounds(base_difficulty, 250);
    assert(diff_max_decrease == 250);
    std::cout << "✓ 4x decrease (max): " << diff_max_decrease << std::endl;

    // Test excessive decrease (should be clamped to 4x)
    uint64_t diff_excessive_decrease = ConsensusEngine::apply_difficulty_bounds(base_difficulty, 100);
    assert(diff_excessive_decrease == 250);
    std::cout << "✓ 10x decrease (clamped to 4x): " << diff_excessive_decrease << std::endl;

    std::cout << "✅ Difficulty bounds tests passed!" << std::endl;
}

void test_publish_deadline() {
    std::cout << "\nTesting publish deadline calculation..." << std::endl;

    const uint64_t base_timestamp = 1640000000;

    // Test deadline calculation for 10-second target
    uint64_t deadline1 = ConsensusEngine::calculate_publish_deadline(1, base_timestamp);
    uint64_t expected1 = base_timestamp + 12; // 10s * 1.25 = 12.5s, rounded down to 12s
    assert(deadline1 == expected1);
    std::cout << "✓ Block 1 deadline: " << deadline1 << " (expected: " << expected1 << ")" << std::endl;

    // Test deadline calculation for higher height
    uint64_t deadline100 = ConsensusEngine::calculate_publish_deadline(100, base_timestamp + 1000);
    uint64_t expected100 = base_timestamp + 1000 + 12;
    assert(deadline100 == expected100);
    std::cout << "✓ Block 100 deadline: " << deadline100 << " (expected: " << expected100 << ")" << std::endl;

    std::cout << "✅ Publish deadline calculation tests passed!" << std::endl;
}

void test_xwift_configuration() {
    std::cout << "\nTesting Xwift configuration constants..." << std::endl;

    // Test 10-second block target
    assert(DIFFICULTY_TARGET_V2 == 10);
    std::cout << "✓ 10-second block target: " << DIFFICULTY_TARGET_V2 << "s" << std::endl;

    // Test XFT supply
    const uint64_t expected_supply = 108800000000000ULL; // 108.8M XFT
    assert(MONEY_SUPPLY == expected_supply);
    std::cout << "✓ XFT total supply: " << MONEY_SUPPLY << " atomic units" << std::endl;

    // Test ring size hard fork
    assert(HF_VERSION_RING_SIZE_16 == 1);
    std::cout << "✓ Ring size 16 hard fork: " << HF_VERSION_RING_SIZE_16 << std::endl;

    // Test tail emission
    const uint64_t expected_tail = 600000000ULL; // 0.6 XFT
    assert(FINAL_SUBSIDY_PER_MINUTE == expected_tail);
    std::cout << "✓ Tail emission: " << FINAL_SUBSIDY_PER_MINUTE << " atomic units/block" << std::endl;

    std::cout << "✅ Xwift configuration tests passed!" << std::endl;
}

void test_genesis_block_validation() {
    std::cout << "\nTesting genesis block validation..." << std::endl;

    // Test that we can generate a genesis block with testnet configuration
    block genesis_block;
    const std::string testnet_genesis_tx = config::get_config(TESTNET).GENESIS_TX;
    const uint32_t testnet_nonce = config::get_config(TESTNET).GENESIS_NONCE;

    bool result = generate_genesis_block(genesis_block, testnet_genesis_tx, testnet_nonce);
    assert(result);
    std::cout << "✓ Genesis block generation successful" << std::endl;

    // Verify genesis block structure
    assert(genesis_block.major_version == CURRENT_BLOCK_MAJOR_VERSION);
    assert(genesis_block.minor_version == CURRENT_BLOCK_MINOR_VERSION);
    assert(genesis_block.timestamp == 0);
    assert(!genesis_block.miner_tx.vin.empty());
    assert(!genesis_block.miner_tx.vout.empty());
    std::cout << "✓ Genesis block structure valid" << std::endl;

    // Calculate genesis block hash
    crypto::hash genesis_hash = get_block_hash(genesis_block);
    std::cout << "✓ Generated genesis block hash: " << epee::string_tools::pod_to_hex(genesis_hash) << std::endl;

    std::cout << "✅ Genesis block validation tests passed!" << std::endl;
}

void test_consensus_edge_cases() {
    std::cout << "\nTesting consensus engine edge cases..." << std::endl;

    // Test uncle reward with very large base reward
    uint64_t large_reward = 1000000000000000ULL; // 1000 XFT
    uint64_t large_uncle_reward = ConsensusEngine::calculate_uncle_reward(large_reward, 1);
    assert(large_uncle_reward == 700000000000000ULL); // 70% of 1000 XFT
    std::cout << "✓ Large base reward handling: " << large_uncle_reward << std::endl;

    // Test difficulty bounds with zero base (edge case)
    uint64_t zero_base_result = ConsensusEngine::apply_difficulty_bounds(0, 1000);
    assert(zero_base_result == 0); // 0/4 = 0, so result should be 0
    std::cout << "✓ Zero base difficulty handling: " << zero_base_result << std::endl;

    // Test publish deadline with maximum timestamp
    uint64_t max_timestamp = UINT64_MAX - 100;
    uint64_t max_deadline = ConsensusEngine::calculate_publish_deadline(1000000, max_timestamp);
    // Should handle overflow gracefully
    assert(max_deadline > max_timestamp);
    std::cout << "✓ Maximum timestamp handling: " << max_deadline << std::endl;

    std::cout << "✅ Consensus edge case tests passed!" << std::endl;
}

int main() {
    std::cout << "=== Xwift Consensus Engine Validation Test Suite ===" << std::endl;
    std::cout << "Testing Xwift-specific consensus rules and functionality\n" << std::endl;

    try {
        test_uncle_reward_calculation();
        test_difficulty_bounds();
        test_publish_deadline();
        test_xwift_configuration();
        test_genesis_block_validation();
        test_consensus_edge_cases();

        std::cout << "\n=== SUMMARY ===" << std::endl;
        std::cout << "✅ All consensus engine validation tests passed!" << std::endl;
        std::cout << "✅ Xwift consensus rules are working correctly" << std::endl;
        std::cout << "✅ Ready for integration with blockchain core" << std::endl;

        return 0;
    }
    catch (const std::exception& e) {
        std::cerr << "❌ Test failed with exception: " << e.what() << std::endl;
        return 1;
    }
    catch (...) {
        std::cerr << "❌ Test failed with unknown exception" << std::endl;
        return 1;
    }
}