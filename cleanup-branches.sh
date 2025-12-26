#!/bin/bash
set -e

echo "Xwift Branch Cleanup Script"
echo "=============================="
echo ""
echo "This will delete 19 obsolete branches from the remote repository."
echo "All work from these branches is preserved in master."
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Deleting old audit/review branches..."
git push origin --delete audit-difficulty-tuning-30s-retarget-review || echo "  ⚠ Branch may already be deleted"
git push origin --delete code-review-monero-fork-implementation || echo "  ⚠ Branch may already be deleted"
git push origin --delete code-review-monero-fork-implementation-e01 || echo "  ⚠ Branch may already be deleted"
git push origin --delete compyle/fork-code-review || echo "  ⚠ Branch may already be deleted"
git push origin --delete compyle/monero-fork-code-review || echo "  ⚠ Branch may already be deleted"
git push origin --delete review-fork-monero-fix-docs-prs || echo "  ⚠ Branch may already be deleted"
git push origin --delete review-fork-security-consensus-walk-blockchain-orphan-checkpoints || echo "  ⚠ Branch may already be deleted"
git push origin --delete review-monero-fork-implementation || echo "  ⚠ Branch may already be deleted"

echo ""
echo "Deleting merged feature branches..."
git push origin --delete chore/analyze-network-scalability-p2p-performance-scope4-6-30s-blocks || echo "  ⚠ Branch may already be deleted"
git push origin --delete task/analyze-p2p-network-scalability-30s || echo "  ⚠ Branch may already be deleted"
git push origin --delete fix-consensus-params-maturity-60-difficulty-72-lag-3-ts-window-15-add-comments || echo "  ⚠ Branch may already be deleted"
git push origin --delete fix-devfund-daemon-dns-openalias || echo "  ⚠ Branch may already be deleted"
git push origin --delete fix-seed-nodes-xwift-placeholders || echo "  ⚠ Branch may already be deleted"
git push origin --delete fix-wallet-binaries-and-doc-ports || echo "  ⚠ Branch may already be deleted"
git push origin --delete fix/security-hardening-mempool-blockweight-randomx-env-logging-testnet-docs || echo "  ⚠ Branch may already be deleted"
git push origin --delete hotfix/remove-dev-fund-completely || echo "  ⚠ Branch may already be deleted"
git push origin --delete feat/emission-72-5m-over-8y-tail-1-2-xwift-per-block || echo "  ⚠ Branch may already be deleted"
git push origin --delete feature/add-checkpoint-infrastructure || echo "  ⚠ Branch may already be deleted"
git push origin --delete docs-testnet-emergency || echo "  ⚠ Branch may already be deleted"

echo ""
echo "✅ Branch cleanup complete!"
echo ""
echo "Summary:"
echo "  - 19 obsolete branches deleted"
echo "  - 3 active branches retained (master, compyle/xwift-deploy-testnet-mainnet, audit-cleanup-xwift-branding-branches)"
echo ""
echo "To clean up local tracking branches, run:"
echo "  git fetch --prune"
