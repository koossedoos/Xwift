// Xwift Wallet Integration Test
// Tests basic wallet functionality

#include <iostream>
#include <cassert>
#include <string>

#include "wallet/wallet2.h"
#include "cryptonote_config.h"

using namespace tools;

void test_wallet_creation() {
    std::cout << "Testing wallet creation..." << std::endl;

    try {
        // Test wallet creation
        wallet2 wallet(cryptonote::TESTNET);

        // Generate new wallet
        crypto::secret_key recovery_val;
        std::string seed_language = "English";
        wallet.generate("", "", recovery_val, false, false);

        std::cout << "✅ Wallet created successfully" << std::endl;
        std::cout << "   Address: " << wallet.get_account().get_public_address_str(cryptonote::TESTNET) << std::endl;

        // Test subaddress creation
        wallet.add_subaddress_account(0);
        cryptonote::subaddress_index index = {0, 1};
        std::string subaddress = wallet.get_subaddress(index);
        std::cout << "   Subaddress: " << subaddress << std::endl;
        std::cout << "✅ Subaddress creation successful" << std::endl;

    } catch (const std::exception& e) {
        std::cerr << "❌ Wallet creation failed: " << e.what() << std::endl;
        throw;
    }
}

void test_wallet_security() {
    std::cout << "\nTesting wallet security features..." << std::endl;

    try {
        wallet2 wallet(cryptonote::TESTNET);
        crypto::secret_key recovery_val;

        // Create wallet with password
        std::string password = "test_password_123";
        wallet.generate("", "", recovery_val, false, false);
        wallet.encrypt_keys(password);
        wallet.encrypt_store(password);

        std::cout << "✅ Wallet encryption successful" << std::endl;

        // Test decryption
        wallet.decrypt_keys(password);
        wallet.decrypt_store(password);
        std::cout << "✅ Wallet decryption successful" << std::endl;

        // Test seed phrase
        std::string seed = wallet.get_seed(language);
        std::cout << "✅ Mnemonic seed generated: " << seed.substr(0, 20) << "..." << std::endl;

    } catch (const std::exception& e) {
        std::cerr << "❌ Wallet security test failed: " << e.what() << std::endl;
        throw;
    }
}

void test_balance_operations() {
    std::cout << "\nTesting balance operations..." << std::endl;

    try {
        wallet2 wallet(cryptonote::TESTNET);
        crypto::secret_key recovery_val;
        wallet.generate("", "", recovery_val, false, false);

        // Test balance queries (should be 0 for new wallet)
        uint64_t balance = wallet.balance();
        uint64_t unlocked_balance = wallet.unlocked_balance();

        std::cout << "✅ Balance query successful" << std::endl;
        std::cout << "   Total balance: " << balance << " atomic units" << std::endl;
        std::cout << "   Unlocked balance: " << unlocked_balance << " atomic units" << std::endl;

        assert(balance == 0);
        assert(unlocked_balance == 0);
        std::cout << "✅ New wallet has zero balance as expected" << std::endl;

    } catch (const std::exception& e) {
        std::cerr << "❌ Balance operations test failed: " << e.what() << std::endl;
        throw;
    }
}

int main() {
    std::cout << "=== Xwift Wallet Integration Test ===" << std::endl;

    try {
        test_wallet_creation();
        test_wallet_security();
        test_balance_operations();

        std::cout << "\n=== WALLET TEST SUMMARY ===" << std::endl;
        std::cout << "✅ All wallet integration tests passed!" << std::endl;
        std::cout << "✅ Xwift wallet system is functioning correctly" << std::endl;

        return 0;
    } catch (const std::exception& e) {
        std::cerr << "\n❌ Wallet integration test failed: " << e.what() << std::endl;
        return 1;
    }
}
