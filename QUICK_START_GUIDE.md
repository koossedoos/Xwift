# Xwift Quick Start Guide

**Get started with Xwift in 5 minutes!**

---

## 🎯 What is Xwift?

Xwift is a **privacy cryptocurrency** that's **4× faster than Monero** while maintaining the same level of privacy.

- ⚡ **30-second blocks** (vs 120 seconds for Monero)
- 🔒 **Complete privacy** (all transactions are private)
- ⛏️ **CPU-friendly mining** (RandomX algorithm)
- 💎 **Fair launch** (no premine, no ICO)

---

## 🚀 Choose Your Path

### 👤 For Users: Get & Use XFT

**Step 1: Get a Wallet**

Download the official wallet:
- **Desktop Wallet (GUI):** [DOWNLOAD_LINK] ⭐ Recommended
- **CLI Wallet:** [DOWNLOAD_LINK] (Advanced users)
- **Mobile Wallet:** Coming soon

**Step 2: Create Your Wallet**

1. Open wallet software
2. Click "Create New Wallet"
3. **Write down your 25-word seed phrase** ✍️
   - Store it safely offline
   - Never share it with anyone
   - You'll need it to recover your wallet
4. Set a strong password
5. Done! Your wallet is ready

**Step 3: Get Some XFT**

Three ways to get XFT:
- 🛒 **Buy:** Purchase on exchanges (see xwift.io/exchanges)
- ⛏️ **Mine:** Follow mining guide below
- 💰 **Earn:** Community bounties and contributions

**Step 4: Send Private Transactions**

1. Click "Send"
2. Enter recipient's Xwift address
3. Enter amount
4. Click "Send"
5. Wait ~3 minutes for confirmation

**That's it!** All transactions are automatically private.

---

### ⛏️ For Miners: Start Mining XFT

**What You Need:**
- Any modern CPU (AMD Ryzen or Intel Core recommended)
- Xwift wallet address
- XMRig mining software

**Mining in 4 Steps:**

**Step 1: Get Wallet Address**
- Create wallet (see above)
- Copy your wallet address (starts with X...)

**Step 2: Download XMRig**
- Download: https://xmrig.com/download
- Extract to a folder
- Windows: `xmrig.exe` / Linux/Mac: `xmrig`

**Step 3: Choose Mining Pool**

Popular pools:
- pool.xwift.io:3333
- xwift.hashvault.pro:3333
- See full list: xwift.io/pools

**Step 4: Start Mining**

**Windows:**
```cmd
xmrig.exe -o pool.xwift.io:3333 -u YOUR_XWIFT_ADDRESS -p x
```

**Linux/Mac:**
```bash
./xmrig -o pool.xwift.io:3333 -u YOUR_XWIFT_ADDRESS -p x
```

**Replace `YOUR_XWIFT_ADDRESS` with your actual address!**

**That's it!** You're now mining XFT. Rewards will arrive in your wallet automatically.

**Expected Earnings:**
- Use calculator: xwift.io/calculator
- Early mining = higher rewards (lower competition)

---

### 💻 For Developers: Build on Xwift

**Clone Repository:**
```bash
git clone https://github.com/xwift/xwift.git
cd xwift
git submodule init && git submodule update
```

**Build on Ubuntu/Debian:**
```bash
# Install dependencies
sudo apt update && sudo apt install -y \
    build-essential cmake pkg-config libssl-dev libzmq3-dev \
    libunbound-dev libsodium-dev libunwind8-dev liblzma-dev \
    libreadline6-dev libexpat1-dev libboost-all-dev

# Build (takes 20-60 minutes)
make release -j$(nproc)

# Binaries in: build/release/bin/
```

**Run Node:**
```bash
./build/release/bin/xwiftd
```

**Documentation:**
- API Reference: docs.xwift.io/api
- Developer Guide: docs.xwift.io/developers
- RPC Reference: docs.xwift.io/rpc

---

## 📊 Key Information

### Network Stats
- **Block Time:** 30 seconds
- **Confirmations:** 6 blocks (3 minutes)
- **Mining Algorithm:** RandomX (CPU-friendly)
- **Ticker:** XFT
- **Decimals:** 8 (0.00000001 XFT)

### Economics
- **Pre-tail Supply:** 108,800,000 XFT
- **Tail Emission:** 9 XFT per block (forever)
- **Current Block Reward:** ~54 XFT (decreasing smoothly)
- **Daily Emission:** ~8,640 XFT (initial)
- **Long-term Inflation:** 0.87%/year

### Privacy Features
- ✅ Ring Signatures (CLSAG)
- ✅ Stealth Addresses
- ✅ RingCT with Bulletproof+
- ✅ Dandelion++ Network Privacy
- ✅ Mandatory Privacy (no transparent transactions)

---

## 🔗 Important Links

### Official Resources
- 🌐 **Website:** https://xwift.io
- 💻 **GitHub:** https://github.com/xwift/xwift
- 📖 **Documentation:** https://docs.xwift.io
- 🔍 **Block Explorer:** https://explorer.xwift.io
- 📊 **Transparency Dashboard:** https://transparency.xwift.io

### Community
- 💬 **Discord:** [DISCORD_LINK]
- 📱 **Telegram:** [TELEGRAM_LINK]
- 🐦 **Twitter/X:** @xwiftcrypto
- 📖 **Reddit:** r/xwift

### Support
- 📚 **FAQ:** Read COMMUNITY_FAQ.md
- 🎓 **Tutorials:** docs.xwift.io/tutorials
- 💬 **Community Help:** Join Discord/Telegram
- 📧 **Email:** support@xwift.io

---

## 🛡️ Security Tips

### Protect Your Wallet
- ✅ **Write down your 25-word seed phrase**
- ✅ Store seed phrase offline (paper/metal backup)
- ✅ Never share seed phrase with anyone
- ✅ Use strong password for wallet file
- ✅ Keep wallet software updated
- ❌ Never store seed phrase digitally (no photos, no cloud)

### Stay Safe
- ✅ Only download wallets from official sources
- ✅ Verify download signatures
- ✅ Use official pools for mining
- ✅ Double-check addresses before sending
- ❌ Don't trust unsolicited DMs
- ❌ Never share your private keys

### Report Security Issues
- 🔒 **Email:** security@xwift.io (DO NOT post publicly)
- 💰 **Bug Bounty:** Rewards available for responsible disclosure

---

## 💡 Quick Tips

### For Best Privacy
1. Run your own node (don't trust remote nodes with your IP)
2. Use Tor or VPN when connecting to nodes
3. Don't publish your Xwift address publicly
4. Use subaddresses for different purposes
5. Don't link your identity to your wallet

### For Mining Success
1. Enable large pages for better performance
2. Close unnecessary applications while mining
3. Join a pool for regular payouts (unless you have >50 KH/s)
4. Monitor your hashrate and temperature
5. Start early (lower difficulty = higher rewards)

### For Transaction Speed
1. Use standard priority (default)
2. Wait for 6 confirmations (3 minutes) for security
3. 10+ confirmations for exchanges
4. Double-check address before sending
5. Send test transaction first for large amounts

---

## 📈 Next Steps

### Learn More
- 📖 Read the complete FAQ: `COMMUNITY_FAQ.md`
- 🎓 Browse tutorials: docs.xwift.io/tutorials
- 📺 Watch video guides: youtube.com/@xwift
- 💬 Join community discussions

### Get Involved
- 🗣️ Join Discord/Telegram community
- 🐛 Report bugs on GitHub
- ✍️ Create content (earn bounties!)
- 🌐 Translate documentation
- 💻 Contribute code
- ⛏️ Run a seed node

### Stay Updated
- 🐦 Follow @xwiftcrypto on Twitter
- 📧 Subscribe to newsletter: xwift.io/newsletter
- 📢 Join announcement channel on Telegram
- 📖 Check roadmap: xwift.io/roadmap

---

## ❓ Common Questions

**Q: How long do transactions take?**
A: 3 minutes for 6 confirmations (standard security). First confirmation in ~30 seconds.

**Q: Are my transactions really private?**
A: Yes! Every transaction is 100% private using ring signatures, stealth addresses, and RingCT. No one can see sender, receiver, or amount.

**Q: Can I mine with my CPU?**
A: Yes! Xwift uses RandomX, a CPU-friendly algorithm. Any modern CPU can mine.

**Q: What if I lose my wallet?**
A: If you have your 25-word seed phrase, you can recover it. Without the seed phrase, funds are permanently lost. ALWAYS backup your seed phrase!

**Q: Where can I buy XFT?**
A: See exchange list at xwift.io/exchanges. You can also mine it or earn it through community contributions.

**Q: Is Xwift legal?**
A: Privacy is legal in most jurisdictions. However, laws vary by country. Users are responsible for complying with local regulations.

**Q: How is Xwift different from Monero?**
A: Same privacy technology, but 4× faster. 30-second blocks vs 120-second blocks. 3-minute confirmations vs 20-minute confirmations.

**Q: What's the development fund?**
A: 2% of block rewards go to development for the first year only. After 1 year, it automatically terminates. All collections and spending are publicly reported.

For more questions, see the complete FAQ: `COMMUNITY_FAQ.md`

---

## 🎉 Welcome to Xwift!

You're now ready to use the fastest private cryptocurrency. Whether you're mining, transacting, or developing, welcome to the Xwift community!

**Need help?** Join our Discord/Telegram - our community is here to help!

---

**Xwift - Privacy at the Speed of Innovation** ⚡🔒

*Fair Launch • No Premine • Community-Driven*

---

*Last Updated: 2025-01-03*
*For detailed information, see LAUNCH_ANNOUNCEMENT_PACKAGE.md and COMMUNITY_FAQ.md*
