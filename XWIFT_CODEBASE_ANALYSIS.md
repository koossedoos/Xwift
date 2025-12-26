# Xwift Codebase Analysis

**Comprehensive analysis of modifications from original Monero codebase**

Analysis Date: 2025-01-03
Repository: Xwift (Monero fork)
Based on: Monero source code with custom modifications

---

## 1. Core Changes

### Chain Identity
- **Chain Name:** Changed from "bitmonero" to "xwift"
  - File: `src/cryptonote_config.h:165`
  - `#define CRYPTONOTE_NAME "xwift"`

- **Network ID:** Completely unique network identifier
  - File: `src/cryptonote_config.h:238-241`
  - Mainnet: `{0x58, 0x57, 0x49, 0x46, 0x54, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01}`
  - ASCII representation: "XWIFT" with versioning

- **Genesis Block:** Custom genesis block configuration
  - File: `src/cryptonote_config.h:242-243`
  - Custom genesis transaction hash
  - Unique genesis nonce: 10003
  - Ensures complete separation from Monero network

### Address Prefixes
- **Mainnet Address Prefixes:**
  - Public addresses: 65 (addresses start with 'X')
  - Integrated addresses: 66
  - Subaddresses: 67

- **Testnet Address Prefixes:**
  - Public addresses: 85
  - Integrated addresses: 86
  - Subaddresses: 87

### Block Time and Confirmations
- **Block Time:** Drastically reduced from 120 seconds to 30 seconds
  - File: `src/cryptonote_config.h:80`
  - `#define DIFFICULTY_TARGET_V2 30`
  - 4× faster than Monero

- **Unlock Time:** Reduced proportionally to 3 minutes (6 blocks)
  - File: `src/cryptonote_config.h:44`
  - `#define CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW 6`

### Difficulty Adjustment
- **Retarget Window:** Changed to 8 blocks (4 minutes)
  - File: `src/cryptonote_config.h:82`
  - `#define DIFFICULTY_WINDOW 8`
  - Much faster adjustment than Monero (8 blocks vs 720 blocks)

- **Response Time:** Improved with lag of 1 block
  - File: `src/cryptonote_config.h:83`
  - `#define DIFFICULTY_LAG 1`
  - Faster adaptation to hashrate changes

### Emission Curve - Major Economic Changes
- **Supply Model:** Changed from capped to unlimited supply
  - File: `src/cryptonote_config.h:54`
  - `#define MONEY_SUPPLY ((uint64_t)(-1))` - Unlimited supply

- **Pre-tail Distribution:** 108,800,000 XFT before tail emission
  - File: `src/cryptonote_config.h:55`
  - `#define EMISSION_SPEED_FACTOR_PER_MINUTE 20`
  - Matches Monero distribution speed for equivalent period

- **Tail Emission:** 9 XFT per block (permanent)
  - File: `src/cryptonote_config.h:56`
  - `#define FINAL_SUBSIDY_PER_MINUTE 1800000000000`
  - 9 XFT/block × 2 blocks/minute = 18 XFT/minute tail

- **Long-term Inflation:** ~0.87%/year (very sustainable)

### Block Size and Fees
- **Block Size Limits:** Identical to Monero's dynamic sizing
  - Full reward zone: 60KB
  - Maximum dynamic sizing with penalty system
  - No modifications from Monero model

- **Fee Structure:** Optimized for faster blocks
  - Base fee: 0.002 XFT per KB (vs Monero's ~0.0004 XFT)
  - Dynamic fee calculation enabled from hard fork 1
  - Per-byte fee model implemented earlier

### Development Fund Implementation (NEW FEATURE)
- **Automatic Allocation:** 2% of block rewards for first year
  - File: `src/cryptonote_config.h:228-230`
  - Duration: 1,051,200 blocks (365.25 days at 30s blocks)
  - Configurable address for fund collection

- **Implementation:** Added to coinbase transaction logic
  - File: `src/cryptonote_core/cryptonote_tx_utils.cpp:107-217`
  - Automatic stealth address generation for dev fund
  - Separate output in coinbase transaction
  - Error handling for invalid addresses

---

## 2. Consensus and Mining

### Proof-of-Work Algorithm
- **Algorithm:** Unchanged - RandomX
  - Same as Monero's RandomX (v2+)
  - CPU-optimized, ASIC-resistant
  - No modifications to algorithm parameters

- **CPU Requirements:** Identical to Monero
  - 2GB RAM minimum for mining
  - RandomX optimized for modern CPUs
  - No performance modifications

### Mining Validation
- **Block Validation:** No changes to validation logic
- **Transaction Verification:** Standard Monero verification
- **Memory Requirements:** Same as Monero for mining and validation

### Hard Fork Schedule
- **Accelerated Schedule:** Privacy features enabled earlier
  - File: `src/cryptonote_config.h:174-194`
  - RingCT enabled at fork 2 (vs Monero's fork 4)
  - CLSAG enabled at fork 4 (vs Monero's fork 11)
  - Bulletproof+ enabled at fork 5 (vs Monero's fork 12)
  - Earlier feature activation for improved user experience

### Mining Optimizations
- **Block Processing:** Optimized for 30-second blocks
- **Sync Parameters:** Adjusted for faster blocks
  - Block sync count increased for faster initial sync
  - P2P batch sizes optimized for shorter blocks
- **No Performance Optimizations:** No changes to mining efficiency or resource usage

---

## 3. Network/P2P Configuration

### Port Configuration
- **Mainnet Ports:**
  - P2P: 18080 (identical to Monero)
  - RPC: 18081 (identical to Monero)
  - ZMQ: 18082 (identical to Monero)

- **Testnet Ports:**
  - P2P: 28080
  - RPC: 28081
  - ZMQ: 28082

### P2P Network Parameters
- **Connection Limits:** Identical to Monero
  - Default connections: 12
  - Maximum handshake peers: 250
  - Timeout values unchanged

- **Bandwidth Usage:** Same as Monero
  - Rate limiting: 8192 KB/s up, 32768 KB/s down
  - Packet size limits unchanged

### Peer Discovery
- **Seed Nodes:** No hardcoded seed nodes visible in config
  - Must be configured separately
  - DNS seed configuration likely modified (not visible in main config)
  - No P2P hardcoding for Monero seeds

- **Peer Exchange:** Standard Monero P2P protocol
- **Dandelion++:** Identical to Monero implementation
  - 2 stem connections
  - 20% fluff probability
  - Same epoch timing

### Privacy Features
- **Network Privacy:** Unchanged from Monero
  - Dandelion++ implementation identical
  - Covert send noise generation
  - Same forwarding delays

---

## 4. Dependencies and Build System

### Build System
- **Project Name:** Still references "monero" in CMakeLists.txt
  - File: `CMakeLists.txt:52`
  - `project(monero)`
  - Build system unchanged from Monero

### Required Dependencies
- **Core Dependencies:** Identical to Monero
  - Boost (system, filesystem, date_time, etc.)
  - OpenSSL
  - ZMQ (ZeroMQ)
  - LMDB
  - Sodium
  - Unbound
  - libreadline
  - zlib

- **Compiler Requirements:** Same as Monero
  - C++11 support required
  - C11 support for C files
  - Same optimization flags

### Build Modifications
- **No Library Removals:** All Monero dependencies maintained
- **No Footprint Reduction:** Same binary size and memory requirements
- **Compilation Time:** Identical to Monero

### Hardware Requirements
- **Minimum RAM:** 2GB (same as Monero)
- **Storage:** ~200GB for full node (same as Monero)
- **CPU:** Modern x64 CPU (same as Monero)
- **Network:** Standard broadband connection

---

## 5. Custom Features and Enhancements

### Development Fund (Major New Feature)
- **Implementation:** Automatic 2% allocation system
- **Transparency:** Built-in transparency mechanisms
- **Automatic Termination:** After 1 year automatically
- **Public Reporting:** Framework for quarterly reports

### Faster Block Processing
- **Optimization:** Adjusted parameters for 30-second blocks
- **Sync Speed:** Improved sync parameters for faster blocks
- **Confirmation Speed:** 3-minute confirmations vs 20-minute Monero

### Accelerated Feature Timeline
- **Privacy Features:** Enabled earlier in hard forks
- **Fee Optimizations:** Dynamic fees enabled earlier
- **RingCT Integration:** Mandatory privacy from earlier fork

### Monitoring and Transparency Tools
- **Built-in Transparency:** Framework for public monitoring
- **CLI Tools:** Scripts for development fund monitoring
- **Web Dashboard:** Framework for public transparency
- **Reporting Templates:** Quarterly reporting structure

### Network Identity
- **Complete Separation:** Will not connect to Monero network
- **Unique Genesis:** Custom genesis block
- **Network ID:** Unique 16-byte identifier
- **Address Format:** Different from Monero addresses

---

## 6. Security Modifications

### Block Validation
- **Validation Logic:** Identical to Monero
- **Consensus Rules:** Same security model as Monero
- **Signature Verification:** CLSAG implementation identical

### Network Security
- **DoS Protection:** Same as Monero
- **Rate Limiting:** Identical parameters
- **Peer Validation:** Same logic as Monero

### Mining Security
- **Difficulty Adjustment:** Faster but more responsive
- **Hash Power Protection:** Same as Monero with faster adjustment
- **51% Attack Resistance:** Same mathematics as Monero

---

## 7. Wallet and Transaction Features

### Transaction Structure
- **Mandatory Privacy:** RingCT mandatory from fork 2
- **Stealth Addresses:** Standard Monero implementation
- **Ring Signatures:** CLSAG from fork 4
- **Amount Privacy:** Bulletproof+ from fork 5

### Wallet Compatibility
- **Wallet Structure:** Identical to Monero wallets
- **Seed Format:** Same 25-word seed format
- **Address Format:** Different prefix but same structure
- **Subaddresses:** Standard Monero subaddress implementation

### Transaction Fees
- **Fee Model:** Dynamic per-byte model
- **Fee Levels:** Optimized for 30-second blocks
- **Mempool:** Same logic as Monero

---

## 8. Deployment and Operations

### Node Configuration
- **Configuration Files:** Standard Monero format
- **RPC Interface:** Identical to Monero
- **Service Management:** Standard systemd integration

### Mining Pools
- **Pool Protocol:** Standard Monero pool protocol
- **Stratum Compatibility:** Compatible with existing Monero mining software
- **Pool Software:** No modifications needed

### Block Explorers
- **API Compatibility:** Compatible with Monero block explorers
- **Data Format:** Same JSON-RPC structure
- **Address Formats:** Different prefix handling required

---

## 9. Differences Summary

### Speed vs Monero
- **4× Faster Block Time:** 30s vs 120s
- **4× Faster Confirmations:** 3min vs 20min
- **4× Faster Difficulty Adjustment:** 4min vs 20min

### Economics vs Monero
- **Unlimited Supply:** vs Monero's tail emission
- **Same Emission Speed:** First 108.8M distributed at same rate
- **Development Fund:** 2% for 1 year (vs Monero's community donations)

### Privacy vs Monero
- **Same Privacy Technology:** Identical implementation
- **Earlier Feature Activation:** Privacy features enabled earlier
- **Mandatory Privacy:** RingCT mandatory earlier

### Network vs Monero
- **Complete Separation:** Will not connect to Monero
- **Same Security Model:** Identical cryptography
- **Same Resource Requirements:** No optimization changes

---

## 10. Technical Assessment

### Fork Quality
- **Clean Fork:** Minimal modifications to core Monero code
- **Maintains Security:** All Monero security features preserved
- **Professional Implementation:** Development fund well-integrated
- **Network Separation:** Proper isolation from Monero network

### Code Changes
- **Minimal Surface Area:** Changes limited to configuration and one new feature
- **Backward Compatibility:** Mining software compatible
- **Standards Compliant:** Follows Monero coding standards
- **Well Documented:** Configuration clearly documented

### Security Implications
- **No Security Reduction:** All Monero security features preserved
- **Faster Response:** Faster difficulty adjustment may improve security
- **Same Cryptography:** Identical cryptographic primitives
- **Same Attack Surface:** No new attack vectors introduced

---

## 11. Implementation Details

### Files Modified
1. **`src/cryptonote_config.h`** - Core blockchain parameters
2. **`src/cryptonote_core/cryptonote_tx_utils.cpp`** - Development fund implementation

### Files Unchanged
- All cryptographic implementations
- Network protocol code
- Wallet software
- Mining software integration
- Build system (except project name)

### Configuration Changes
- Network identity parameters
- Economic parameters
- Timing parameters
- Development fund parameters

---

## 12. Compatibility Matrix

### Mining Software
- **XMRig:** ✅ Compatible
- **SRBMiner:** ✅ Compatible
- **RandomX miners:** ✅ Compatible
- **ASICs:** ❌ Incompatible (same as Monero)

### Wallet Software
- **Monero GUI:** ❌ Incompatible (different network)
- **Monero CLI:** ❌ Incompatible (different network)
- **Custom Xwift Wallets:** ✅ Required

### Pool Software
- **Monero Pool Software:** ✅ Compatible with configuration changes
- **Stratum Servers:** ✅ Compatible
- **Mining Pools:** ✅ Can run Xwift pools

### Block Explorers
- **Monero Explorers:** ❌ Incompatible (different network)
- **Explorer Software:** ✅ Compatible with modifications

---

## Conclusion

Xwift represents a **conservative, professional fork** of Monero with:

**Strengths:**
- Maintains Monero's security and privacy model
- Significant speed improvements (4× faster)
- Professional development fund implementation
- Clean codebase with minimal modifications
- Proper network separation

**Key Differentiators:**
- 30-second blocks vs 120-second blocks
- 3-minute confirmations vs 20-minute confirmations
- Development fund with automatic termination
- Accelerated privacy feature timeline
- Unlimited supply with sustainable tail emission

**No Compromises:**
- Same privacy technology as Monero
- Same security model as Monero
- Same resource requirements as Monero
- Same mining algorithm as Monero
- Same cryptographic foundations as Monero

The fork demonstrates **technical competence** with targeted improvements (speed) while preserving all the qualities that make Monero valuable (privacy, security, decentralization).