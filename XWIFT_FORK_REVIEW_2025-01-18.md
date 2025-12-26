# XWIFT Fork Verification – January 2025

## Executive Summary
The XWIFT fork diverges cleanly from upstream Monero and will not connect to the Monero network. Consensus parameters, branding, network identifiers, and genesis blocks are all customized. Economic parameters were also adjusted (30 second blocks, 2 % development fund, 8 decimals, custom fees, etc.).

**Launch readiness:** ⚠️ _Not yet production ready_. The development fund address is still a placeholder, wallet binaries keep their Monero names, and some documentation is inconsistent with the new ports. These items should be resolved before mainnet launch.

## Confirmed Customizations
| Area | Status | Notes |
|------|--------|-------|
| Network identity | ✅ | `CRYPTONOTE_NAME="xwift"`, unique peer IDs, distinct ports (19080/19081/19082 for mainnet, 2908x for testnet), custom message signing key, genesis TX & nonce replaced. |
| Address prefixes | ✅ | Base58 prefixes 65/66/67 (mainnet) and 85/86/87 (testnet). |
| Economic parameters | ✅ | 30 s block target, 8 decimal places, COIN=1e8, emission cut/long-term weight tuned for faster cadence, fee constants rescaled. |
| Development fund logic | ✅* | 2 % divert for first 1,051,200 blocks is implemented in `construct_miner_tx` (cryptonote_tx_utils.cpp). **Address still needs to be set.** |
| Update/DNS infra | ✅ | Auto-update DNS list emptied, download URLs point at `xwift.org`, DNSSEC probe moved to `cloudflare.com`, OpenAlias tag changed to `oa1:xwift`, log messaging references `xwiftd`. |
| Build outputs | ✅ | Daemon target renamed to `xwiftd`. |
| Documentation set | ✅ | Extensive docs shipped (deployment, economics, marketing, etc.). |

## Outstanding Issues
1. **Development fund address placeholder (critical)**  
   `src/cryptonote_config.h` line 230 still reads `"DEVELOPMENT_FUND_ADDRESS_TO_BE_SET"`. Until this is replaced with a valid _mainnet_ XWIFT address the 2 % allocation will silently fail (parsing returns false and the reward stays with the miner).

2. **Wallet binaries keep Monero names (high priority)**  
   - CLI wallet target still outputs `monero-wallet-cli` (`src/simplewallet/CMakeLists.txt`).
   - RPC wallet target still outputs `monero-wallet-rpc` (`src/wallet/CMakeLists.txt`).
   For a polished release, rename to `xwift-wallet-cli` / `xwift-wallet-rpc` (and adjust documentation, scripts, service files, Dockerfiles, etc.).

3. **Documentation port mismatch (high priority)**  
   `README_XWIFT.md` still states the Monero ports (1808x/2808x). Update docs (and any scripts) to reflect the 1908x/2908x assignments already used in `cryptonote_config.h` and systemd/docker assets.

4. **Stagenet left as upstream Monero (medium priority)**  
   The `config::stagenet` block still carries Monero IDs, prefixes, and genesis information. If XWIFT does not intend to support stagenet, disable it or mirror mainnet/testnet values to avoid accidental cross-network behavior.

5. **Branding residue in UI/tests/translations (low priority)**  
   There remain hundreds of instances of the word "Monero" across translations, comments, docs, and some help text. Not a blocker, but worth cleaning gradually for a cohesive brand.

6. **Seed nodes and update endpoints (operational)**  
   DNS update list is currently empty, so no automatic update checks will occur. Plan the infrastructure (domains, HTTPS artifact hosting, DNS seeds) before public release.

## Recommended Next Steps
1. Generate the production dev-fund wallet, replace the placeholder address, rebuild, and verify the fund receives payouts on fresh blocks.
2. Rename wallet binaries and update scripts/services/Dockerfiles to match.
3. Audit documentation for outdated ports, binary names, and Monero references.
4. Decide on stagenet support; either customize or build out an XWIFT-specific equivalent.
5. Stand up seed nodes and publish their hostnames/IPs so new nodes can bootstrap.
6. Run an end-to-end testnet rehearsal to confirm block cadence, difficulty adjustments, dev fund accrual, wallet operations, and RPC behavior.

## Conclusion
The core consensus and network identity work for XWIFT are solid. Finish the configuration polish—especially the development fund address and wallet binary renaming—before announcing or launching a mainnet. Once the remaining cleanup is complete and testnet trials pass, the fork will be ready for public deployment.
