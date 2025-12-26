# Pre-Launch Fixes Required for XWIFT

## Critical Fixes (Must Complete Before Mainnet Launch)

### 1. ❌ Set Development Fund Address
**File:** `src/cryptonote_config.h`  
**Line:** 230  
**Current:**
```cpp
const char DEV_FUND_ADDRESS[] = "DEVELOPMENT_FUND_ADDRESS_TO_BE_SET";
```
**Required Action:**
1. Generate a XWIFT mainnet wallet using: `./build/bin/xwiftd --generate-wallet` or use wallet CLI
2. Copy the primary address (starts with "X")
3. Replace the placeholder in cryptonote_config.h
4. Rebuild the entire project

**Why Critical:** Without a valid address, the 2% development fund will fail silently and miners will receive 100% of the rewards. Your funding mechanism won't work.

---

## High Priority Fixes (Should Complete Before Launch)

### 2. ⚠️ Rename Wallet Binaries
**Files to modify:**
- `src/simplewallet/CMakeLists.txt` (line 64)
- `src/wallet/CMakeLists.txt` (line 102)

**Current:**
```cmake
# In simplewallet/CMakeLists.txt
OUTPUT_NAME "monero-wallet-cli"

# In wallet/CMakeLists.txt
OUTPUT_NAME "monero-wallet-rpc"
```

**Should be:**
```cmake
# In simplewallet/CMakeLists.txt
OUTPUT_NAME "xwift-wallet-cli"

# In wallet/CMakeLists.txt
OUTPUT_NAME "xwift-wallet-rpc"
```

**Why Important:** Professional appearance, avoids confusion with Monero wallets, and prevents users from accidentally using the wrong wallet software.

---

### 3. ⚠️ Fix Documentation Port Mismatch
**File:** `README_XWIFT.md`  
**Lines:** ~20-29

**Current values in docs:**
```yaml
Mainnet:
- P2P Port: 18080  # WRONG - conflicts with Monero
- RPC Port: 18081  # WRONG - conflicts with Monero

Testnet:
- P2P Port: 28080  # WRONG
- RPC Port: 28081  # WRONG
```

**Correct values (already in code):**
```yaml
Mainnet:
- P2P Port: 19080  # Correct
- RPC Port: 19081  # Correct
- ZMQ Port: 19082  # Correct

Testnet:
- P2P Port: 29080  # Correct
- RPC Port: 29081  # Correct
- ZMQ Port: 29082  # Correct
```

**Additional Files to Check:**
- All `*.md` files with port references
- `Dockerfile*` files
- systemd service files in `utils/systemd/`
- `docker-compose.yml`
- Any shell scripts in `utils/scripts/`

**Why Important:** Incorrect documentation will lead to:
- Port conflicts with Monero nodes on the same machine
- Connection failures
- User confusion and support burden

---

## Medium Priority (Recommended)

### 4. 📝 Customize or Disable Stagenet
**File:** `src/cryptonote_config.h`  
**Lines:** 290-303

**Current:** Stagenet still uses Monero parameters

**Options:**
A. **Customize for XWIFT:**
```cpp
namespace stagenet
{
  uint64_t const CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX = 45;  // Different
  uint64_t const CRYPTONOTE_PUBLIC_INTEGRATED_ADDRESS_BASE58_PREFIX = 46;
  uint64_t const CRYPTONOTE_PUBLIC_SUBADDRESS_BASE58_PREFIX = 47;
  uint16_t const P2P_DEFAULT_PORT = 39080;  // Unique port
  uint16_t const RPC_DEFAULT_PORT = 39081;  // Unique port
  uint16_t const ZMQ_RPC_DEFAULT_PORT = 39082;  // Unique port
  boost::uuids::uuid const NETWORK_ID = { {
      0x58, 0x57, 0x49, 0x46, 0x54, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03  // XWIFT stagenet
    } };
  // Generate new GENESIS_TX and GENESIS_NONCE
}
```

B. **Or document that stagenet is not supported**

**Why Medium:** Most projects only use mainnet + testnet. Stagenet is optional.

---

### 5. 🌐 Set Up Network Infrastructure
**Required Infrastructure:**

1. **Seed Nodes:**
   - Set up at least 2-3 seed nodes with static IPs
   - Add them to your config files and documentation
   - Example: `seed1.xwift.org:19080`, `seed2.xwift.org:19080`

2. **DNS Updates (Optional but Recommended):**
   - If you want auto-update functionality, set up DNS TXT records
   - Host binaries at `downloads.xwift.org` and `updates.xwift.org`
   - Or leave disabled as currently configured

3. **Website and Documentation:**
   - Official website with download links
   - Block explorer (optional but helpful)
   - Mining pool software/documentation

**Why Important:** Users need seed nodes to discover peers and bootstrap the network.

---

## Testing Checklist Before Launch

### Pre-Launch Testing (1-2 days recommended)

1. **Build Test:**
   ```bash
   cd /home/engine/project
   make clean
   make -j$(nproc)
   ```

2. **Testnet Launch:**
   ```bash
   ./build/bin/xwiftd --testnet --detach
   # Let it run for 1 hour, mine some blocks
   ./build/bin/xwiftd --testnet status
   ```

3. **Wallet Test:**
   ```bash
   ./build/bin/xwift-wallet-cli --testnet --generate-wallet test-wallet
   # Test sending and receiving
   ```

4. **Development Fund Verification:**
   - Mine 100+ blocks on testnet
   - Check that dev fund address receives 2% of rewards
   - Verify it stops after DEV_FUND_DURATION_BLOCKS

5. **Network Parameters:**
   - Confirm block time is ~30 seconds
   - Check difficulty adjusts properly
   - Verify unlock time is 3 minutes (6 blocks)

6. **Port Verification:**
   ```bash
   netstat -tlnp | grep xwiftd
   # Should show 19080, 19081, 19082 for mainnet
   # Should show 29080, 29081, 29082 for testnet
   ```

---

## Quick Fix Commands

### After making the address change:
```bash
cd /home/engine/project
make clean
make -j$(nproc)
make install  # or copy binaries manually
```

### To test dev fund address parsing:
```bash
./build/bin/xwiftd --print-genesis-tx
# Should show your custom genesis without errors
```

---

## Estimated Time to Complete

| Task | Time Estimate |
|------|---------------|
| Generate dev fund wallet & update code | 15 minutes |
| Rename wallet binaries | 10 minutes |
| Fix documentation ports | 30 minutes |
| Rebuild and test | 1-2 hours |
| Testnet validation | 1-2 days |
| **Total** | **~2-3 days** |

---

## Summary

Your XWIFT fork is **90% complete**. The core blockchain mechanics, network identity, economic parameters, and development fund logic are all properly implemented. 

The remaining work is:
1. **One critical configuration value** (dev fund address)
2. **Polish and consistency** (wallet names, documentation)
3. **Infrastructure preparation** (seed nodes, optional update servers)
4. **Thorough testing** before mainnet launch

Complete the critical fix first, then the high-priority items. Test extensively on testnet. Once everything passes validation, you'll be ready for mainnet launch.

---

**Current Status:** ⚠️ 90% Ready - Critical fixes required before launch  
**Recommended Timeline:** Fix + test for 2-3 days before mainnet  
**Risk Level:** Low risk if fixes are completed; High risk if launched as-is
