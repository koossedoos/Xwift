#!/bin/bash
# Xwift Build Verification Script
# Run this after build completes to verify all binaries were created successfully

echo "=========================================="
echo "Xwift Build Verification"
echo "=========================================="
echo ""

BUILD_DIR="build/release/bin"
SUCCESS=0
FAILED=0

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ ERROR: Build directory not found: $BUILD_DIR"
    echo "   Make sure you ran: make release -j\$(nproc)"
    exit 1
fi

echo "✅ Build directory exists: $BUILD_DIR"
echo ""

# List of expected binaries
BINARIES=(
    "xwiftd"
    "xwift-wallet-cli"
    "xwift-wallet-rpc"
    "xwift-blockchain-export"
    "xwift-blockchain-import"
    "xwift-blockchain-stats"
    "xwift-gen-trusted-multisig"
)

echo "Checking for required binaries..."
echo ""

for binary in "${BINARIES[@]}"; do
    if [ -f "$BUILD_DIR/$binary" ]; then
        SIZE=$(ls -lh "$BUILD_DIR/$binary" | awk '{print $5}')
        echo "✅ $binary ($SIZE)"
        ((SUCCESS++))
    else
        echo "❌ $binary (NOT FOUND)"
        ((FAILED++))
    fi
done

echo ""
echo "=========================================="
echo "Summary: $SUCCESS found, $FAILED missing"
echo "=========================================="
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ BUILD VERIFICATION PASSED!"
    echo ""
    echo "Testing daemon version:"
    ./$BUILD_DIR/xwiftd --version
    echo ""
    echo "Next steps:"
    echo "1. Create testnet config: mkdir -p ~/.xwift-testnet"
    echo "2. Follow LOCAL_TESTING_GUIDE.md Step 5"
    exit 0
else
    echo "❌ BUILD VERIFICATION FAILED!"
    echo "Some binaries are missing. Build may have failed."
    echo "Check build output for errors."
    exit 1
fi
