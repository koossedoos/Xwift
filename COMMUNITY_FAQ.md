# Xwift (XFT) - Community FAQ

**Comprehensive Frequently Asked Questions**

Last Updated: 2025-01-03

---

## General Questions

### What is Xwift?

**Simple Answer:** Xwift is a privacy cryptocurrency that's 4× faster than Monero while maintaining the same level of privacy and security.

**Technical Answer:** Xwift is a cryptocurrency based on the Monero codebase, implementing CryptoNote protocol with optimized consensus parameters. It provides mandatory transaction privacy through ring signatures (CLSAG), stealth addresses, and RingCT with Bulletproof+, while offering 30-second block times compared to Monero's 120-second blocks.

### Why was Xwift created?

Existing privacy cryptocurrencies require users to choose between privacy and speed. Monero offers excellent privacy but has 20-minute confirmation times, making it impractical for everyday transactions. Xwift solves this by maintaining Monero-level privacy while delivering confirmations in just 3 minutes.

### Who created Xwift?

Xwift is developed by a community-focused team of cryptocurrency developers and privacy advocates. The project is open source, and the code is publicly auditable on GitHub. The team believes in transparent governance with public development fund reporting.

### Is Xwift a scam or legitimate project?

**Legitimate indicators:**
- ✅ Open source code (publicly auditable)
- ✅ No premine or instamine
- ✅ No ICO or token sale
- ✅ Fair launch with transparent development fund
- ✅ Public quarterly reporting
- ✅ Based on proven Monero technology
- ✅ All development public on GitHub

**Red flags we DON'T have:**
- ❌ No "guaranteed returns" promises
- ❌ No premine for founders
- ❌ No ICO or private sale
- ❌ No centralized control
- ❌ No hidden allocations

### How is Xwift funded?

The blockchain automatically allocates 2% of block rewards to a development fund for the **first year only** (1,051,200 blocks). After one year, this allocation **automatically terminates** and miners receive 100% of rewards.

All collections and expenditures are publicly reported quarterly with transaction hashes for verification. There is no premine, no ICO, and no venture capital funding.

---

## Technical Questions

### What makes Xwift private?

Xwift uses multiple privacy technologies working together:

1. **Ring Signatures (CLSAG)** - Your transaction is mixed with 15 other decoy transactions, hiding the true sender
2. **Stealth Addresses** - Each transaction creates a unique one-time address, hiding the receiver
3. **RingCT with Bulletproof+** - Transaction amounts are encrypted and hidden from everyone except sender and receiver
4. **Dandelion++** - Your IP address is protected during transaction broadcast

**Important:** Privacy is MANDATORY. Every transaction is private - there's no way to send a transparent transaction.

### How fast is Xwift compared to other cryptocurrencies?

| Cryptocurrency | Block Time | Confirmation Time |
|---------------|-----------|-------------------|
| **Xwift** | **30 seconds** | **3 minutes** |
| Monero | 120 seconds | 20 minutes |
| Bitcoin | 10 minutes | 60 minutes |
| Ethereum | 12 seconds | 6 minutes* |
| Zcash | 75 seconds | 15 minutes |

*Ethereum has no privacy - all transactions are transparent

**Result:** Xwift is 4× faster than Monero while maintaining equal privacy.

### What is the total supply of Xwift?

**Pre-tail phase:** 108,800,000 XFT will be distributed over approximately 4 years through a smooth emission curve (no halvings).

**Tail emission phase:** After the pre-tail phase, the blockchain will emit 9 XFT per block forever (perpetual tail emission).

**Result:** Unlimited supply with decreasing inflation:
- Year 5: ~8.7% inflation
- Year 10: ~4.7% inflation
- Year 20: ~3.2% inflation
- Year 50: ~1.6% inflation
- Long-term: ~0.87% inflation

This ensures miners are always incentivized to secure the network.

### Why unlimited supply? Isn't scarcity important?

Bitcoin's model (capped supply) works for a store of value, but creates a long-term security problem: when block rewards end, miners must be paid entirely through transaction fees. If fees are too low, security decreases. If fees are too high, adoption decreases.

Xwift (like Monero) solves this with **tail emission** - a small perpetual block reward that:
- ✅ Keeps mining profitable forever
- ✅ Maintains strong network security
- ✅ Allows low transaction fees
- ✅ Results in very low inflation (~0.87%/year long-term)

The inflation rate is lower than gold mining (~1-2% per year) and much lower than fiat currencies (~3-7% per year).

### What mining algorithm does Xwift use?

**RandomX** - A CPU-optimized Proof-of-Work algorithm designed by Monero developers.

**Benefits:**
- ✅ CPU-friendly (everyone can mine)
- ✅ ASIC-resistant (prevents centralization)
- ✅ GPU-mineable but not dominant
- ✅ Fair distribution
- ✅ Decentralized mining

### Can I mine Xwift with my computer?

**Yes!** RandomX is designed for consumer CPUs.

**Expected hashrates:**
- Intel Core i7 (8 cores): ~5-8 KH/s
- AMD Ryzen 9 (16 cores): ~15-20 KH/s
- GPU (Nvidia/AMD): ~1-3 KH/s per GPU

**Getting started:**
1. Download XMRig: https://xmrig.com
2. Choose a mining pool or solo mine
3. Run: `xmrig -o pool_address:port -u YOUR_XWIFT_ADDRESS`

See our mining guide for detailed instructions.

### Is Xwift's privacy as good as Monero?

**Yes.** Xwift uses identical privacy technology:
- Same ring signature algorithm (CLSAG)
- Same stealth address system
- Same RingCT with Bulletproof+
- Same Dandelion++ network privacy
- Same mandatory privacy (no transparent transactions)

The only difference is speed - Xwift is 4× faster with the same security model.

### Can transactions be traced or deanonymized?

Not with current technology. Xwift's privacy features make tracing transactions computationally infeasible:

- **Ring signatures:** Attacker must identify the real input among 16 decoys (1 in 16 chance per input)
- **Stealth addresses:** Each transaction uses unique one-time addresses
- **Hidden amounts:** RingCT encrypts all amounts
- **Network privacy:** Dandelion++ hides transaction origin

**Important:** Privacy depends on proper usage:
- ✅ Don't reuse addresses (wallets handle this automatically)
- ✅ Don't publish your view key publicly
- ✅ Use reputable wallets
- ✅ Consider using Tor/VPN for additional network privacy

### How do I verify my transaction went through if amounts are hidden?

You (and only you) can see your transaction details in your wallet. The blockchain shows:
- ✅ Transaction exists and is confirmed
- ✅ Number of confirmations
- ✅ Block height

But only you can see:
- 🔒 Who received the transaction
- 🔒 How much was sent
- 🔒 Your remaining balance

You can optionally share your transaction private key or view key to prove payment to specific parties.

---

## Economics & Tokenomics

### What is the emission schedule?

Xwift uses a smooth emission curve (no sudden halvings):

**Year 1:** ~21.6M XFT (~19.8% of pre-tail supply)
**Year 2:** ~18.7M XFT additional (~17.2%)
**Year 3:** ~15.8M XFT additional (~14.5%)
**Year 4:** ~13.0M XFT additional (~11.9%)
**Year 5+:** 9 XFT per block forever (tail emission)

**Block rewards:**
- Start: ~54 XFT per block
- Smooth decrease over time
- Tail: 9 XFT per block (permanent)

### How is the development fund allocated?

**Collection:** 2% of every block reward for the first year
- Automatically allocated by the blockchain
- Sent to a designated development address
- Terminates automatically after 1,051,200 blocks (1 year)

**Expected collection:** ~63,072 XFT total

**Allocation categories:**
1. **Core Development (40%)** - ~25,229 XFT
   - Developer salaries and bounties
   - Code reviews and testing
   - Bug fixes and maintenance

2. **Security (25%)** - ~15,768 XFT
   - Professional security audits
   - Bug bounty program
   - Vulnerability testing

3. **Infrastructure (15%)** - ~9,461 XFT
   - Seed nodes and network infrastructure
   - Block explorers
   - Public APIs and services

4. **Exchange Listings (10%)** - ~6,307 XFT
   - Exchange listing fees
   - Market maker incentives
   - Trading pair liquidity

5. **Marketing (10%)** - ~6,307 XFT
   - Community growth
   - Educational content
   - Partnership development

**Transparency:**
- Quarterly public reports with transaction hashes
- Real-time dashboard showing collections
- Community oversight and feedback

### What happens after the development fund ends?

**After block 1,051,201:**
- Development fund automatically terminates
- Miners receive 100% of block rewards
- No more automatic development funding

**Development continues through:**
- Community donations
- Voluntary contributions
- Grant programs
- Sponsor partnerships
- Community-driven development model

This follows Monero's model - sustainable, community-driven development without perpetual founder rewards.

### Will Xwift be listed on exchanges?

Yes. Exchange listing discussions are ongoing. Announcements will be made as listings are confirmed.

**Target exchanges:**
- Tier 2-3 exchanges (first 3 months)
- Major exchanges (months 4-12)
- DEX integration (ongoing)

**Current status:** Applications submitted to multiple exchanges. Some listing fees will be paid from development fund.

### What is the fair launch approach?

**Fair launch means:**
- ✅ No premine (developers start with 0 coins)
- ✅ No instamine (no special fast mining at launch)
- ✅ No ICO or token sale (no buying coins before launch)
- ✅ No private sale (no venture capital allocations)
- ✅ Public launch (everyone can mine from block 0)

**Everyone starts equal.** The only way to get XFT at launch is to mine it or buy it from someone who mined it.

---

## Development Fund Transparency

### How can I verify the development fund collections?

**Three ways:**

1. **Real-time Dashboard**
   - Visit: [TRANSPARENCY_DASHBOARD_URL]
   - Shows current collections, blocks remaining, estimated totals
   - Updates automatically

2. **Blockchain Verification**
   - View the dev fund address on block explorer
   - See every collection transaction
   - All transactions are public and immutable

3. **Quarterly Reports**
   - Published every 3 months
   - Detailed expenditure breakdown
   - Transaction hashes for every expense
   - Financial summary and compliance

### How do I know funds are being used appropriately?

**Transparency measures:**

1. **Quarterly public reports** with detailed breakdown
2. **Transaction hashes** for every expenditure (verifiable on blockchain)
3. **Category budgets** published in advance
4. **Community feedback** incorporated into spending decisions
5. **Multi-signature wallet** (multiple people must approve spending)
6. **Public dashboard** showing real-time data

**You can verify:**
- ✅ How much was collected
- ✅ Where every coin was spent
- ✅ Transaction hashes proving expenditures
- ✅ Budget compliance

### What if the development fund is misused?

**Safeguards:**

1. **Automatic termination** - Fund ends after 1 year regardless
2. **Public blockchain** - All transactions are permanently recorded
3. **Community oversight** - Reports reviewed by community
4. **Multi-signature control** - Multiple parties must approve spending
5. **Quarterly reporting** - Regular public accountability

**Worst case:** Even if funds were completely misused, it's only 2% of emission for 1 year (~63K XFT). The blockchain continues operating normally, and the fund automatically terminates.

### Can the development fund be extended beyond 1 year?

**No.** The termination is hardcoded into the blockchain. After block 1,051,200, it's technically impossible to continue the allocation without a hard fork that would require community consensus.

---

## Using Xwift

### How do I get Xwift?

**Four ways:**

1. **Mine it**
   - Download mining software (XMRig)
   - Join a mining pool or solo mine
   - Start earning XFT

2. **Buy it**
   - Purchase on exchanges (list available on website)
   - Trade other cryptocurrencies for XFT
   - OTC trading (for large amounts)

3. **Earn it**
   - Community bounties
   - Development contributions
   - Content creation rewards

4. **Accept it**
   - Merchants can accept XFT as payment
   - Payment processors available

### How do I store Xwift safely?

**Wallet options:**

1. **Official CLI Wallet** (Most secure)
   - Full node + wallet
   - Complete control
   - Requires technical knowledge

2. **Desktop GUI Wallet** (Recommended for most users)
   - User-friendly interface
   - Full node or remote node
   - Good balance of security and usability

3. **Mobile Wallet** (Convenient)
   - iOS and Android
   - Remote node connection
   - Good for daily transactions
   - Coming soon

4. **Hardware Wallet** (Maximum security)
   - Ledger/Trezor support
   - In development

**Security best practices:**
- ✅ Write down your 25-word seed phrase
- ✅ Store seed phrase offline (paper, metal backup)
- ✅ Never share your seed phrase
- ✅ Use strong password for wallet file
- ✅ Keep wallet software updated

### How long do transactions take?

**Confirmation times:**
- **1 confirmation:** 30 seconds (average)
- **3 confirmations:** 1.5 minutes (minimum recommended)
- **6 confirmations:** 3 minutes (standard)
- **10 confirmations:** 5 minutes (full security)

**Comparison:**
- Xwift: 3 minutes (6 confirmations)
- Monero: 20 minutes (10 confirmations)
- Bitcoin: 60 minutes (6 confirmations)

### What are transaction fees?

**Current fees:** ~0.002 XFT per transaction (dynamic)

**Why fees are needed:**
- Prevent spam attacks
- Prioritize transactions
- Incentivize miners

**Fee estimation:**
- Wallet automatically calculates optimal fee
- Higher fee = faster priority (if mempool is full)
- Lower fee = slower priority (but still processes)

### Can I send Xwift to an exchange?

Yes, but follow these steps:

1. **Check minimum confirmations** - Each exchange sets their own (usually 10-20 confirmations)
2. **Use correct address** - Double-check the deposit address
3. **Payment ID** - Some exchanges require a payment ID (your wallet will prompt you)
4. **Wait for confirmations** - Don't panic if deposit takes 10-30 minutes

**Important:** Always send a small test transaction first!

### How do I prove I sent payment?

Even though transactions are private, you can prove payment when needed:

**Option 1: Transaction Key**
- Every transaction generates a transaction private key
- Share this key with the recipient
- They can verify the payment was sent to them

**Option 2: View Key**
- Share your view key (read-only access to your wallet)
- Recipient can see all your incoming transactions
- Useful for auditing

**Option 3: Subaddress**
- Create a unique subaddress for each recipient
- You can prove you sent to that specific subaddress

Your wallet has built-in tools for payment proof generation.

---

## Mining Questions

### Is mining Xwift profitable?

**Profitability depends on:**
- Your hardware (CPU/GPU specs)
- Electricity cost
- Current network difficulty
- XFT market price

**Rough estimate (example):**
- Intel Core i7-9700K: ~6 KH/s
- Network hashrate: ~50 MH/s (example)
- Your share: 6 / 50,000 = 0.012%
- Daily blocks: 2,880 (30-second blocks)
- Daily emission: ~8,640 XFT (initial)
- Your daily earnings: ~1.04 XFT

**Use our calculator:** [CALCULATOR_URL]

**Note:** Early mining is more profitable due to lower competition.

### What hardware is best for mining?

**Best CPUs (by performance):**
1. AMD Ryzen 9 7950X: ~20 KH/s
2. AMD Ryzen 9 5950X: ~18 KH/s
3. AMD Ryzen 7 5800X: ~13 KH/s
4. Intel Core i9-12900K: ~16 KH/s
5. AMD Ryzen 5 5600X: ~10 KH/s

**GPUs work but are less efficient:**
- Nvidia RTX 4090: ~3 KH/s (~$2,000)
- AMD Ryzen 9 5950X: ~18 KH/s (~$500)

**Result:** CPUs are more cost-effective for RandomX.

### Should I solo mine or join a pool?

**Solo Mining:**
- ✅ Keep 100% of block rewards
- ✅ No pool fees
- ❌ Irregular payouts (might wait days/weeks for a block)
- ❌ Requires running full node
- **Recommended for:** High hashrate miners (>50 KH/s)

**Pool Mining:**
- ✅ Regular steady payouts (daily or even hourly)
- ✅ Lower variance
- ✅ Don't need to run full node
- ❌ Pool fees (typically 1-2%)
- ❌ Pool must be trusted
- **Recommended for:** Most miners (especially beginners)

### How do I start mining?

**Quick start (5 steps):**

1. **Create Xwift wallet** and get your address

2. **Download XMRig:** https://xmrig.com/download

3. **Choose a pool:** See pool list on xwift.io/pools

4. **Configure XMRig:**
```bash
xmrig -o pool.xwift.io:3333 -u YOUR_XWIFT_ADDRESS -p x
```

5. **Start mining** and watch the hashrate!

**Detailed guide:** See our complete mining tutorial at [MINING_GUIDE_URL]

### What is the network hashrate?

**You can check:**
- Block explorer: [EXPLORER_URL]
- Mining pools: Most pools show network hashrate
- RPC command: `curl http://localhost:18081/get_info | jq .difficulty`

**Current estimate:** [CHECK EXPLORER]

Network hashrate determines difficulty and your share of rewards.

### Can I mine on multiple computers?

**Yes!** You can:
- Run XMRig on multiple computers
- All use the same wallet address
- Rewards accumulate to that address
- Pool treats them as one miner

**No setup needed** - just point all computers to the same pool with the same wallet address.

---

## Security & Privacy

### Is Xwift legal?

**Privacy is legal** in most jurisdictions. Xwift is software for private financial transactions, similar to cash.

**However:**
- Laws vary by country
- Some countries restrict or ban cryptocurrency
- Users are responsible for complying with local laws
- Consult a legal professional if unsure

**Xwift's position:** Privacy is a fundamental human right. We advocate for the legal and ethical use of privacy technology.

### Can governments or corporations trace Xwift transactions?

**No.** With proper usage, Xwift transactions cannot be traced using current technology.

**What they CAN'T see:**
- ❌ Who sent the transaction
- ❌ Who received the transaction
- ❌ How much was sent
- ❌ Your wallet balance

**What they CAN see:**
- ✅ A transaction occurred
- ✅ The block height
- ✅ Transaction fee
- ✅ That *someone* sent *something* to *someone*

**Important:** Privacy requires proper usage (don't publish your seed phrase, use reputable wallets, consider Tor/VPN).

### Is Xwift used for illegal activities?

Like cash, Xwift can be used for both legal and illegal purposes. The vast majority of usage is legal.

**Legal uses:**
- Personal financial privacy
- Business confidentiality
- Protection from surveillance
- Financial freedom
- Donations to sensitive causes
- Protection from targeting/theft

**Illegal uses:**
- Criminals may use any form of money
- Privacy tools don't cause crime
- Cash is used for far more crime than cryptocurrency

**Our position:** Privacy is not a crime. We support the legal and ethical use of financial privacy technology.

### How do I protect my privacy when using Xwift?

**Best practices:**

1. **Network Privacy**
   - Use Tor or VPN when connecting to nodes
   - Run your own node (don't trust remote nodes with IP)
   - Use Dandelion++ (enabled by default)

2. **Operational Security**
   - Don't publish your Xwift address publicly
   - Don't reuse addresses (wallets handle this automatically)
   - Don't link your identity to your wallet
   - Use different wallets for different purposes

3. **Physical Security**
   - Secure your seed phrase offline
   - Use encrypted storage for wallet files
   - Don't take photos of seed phrases
   - Consider metal backup for seed phrase

4. **Transaction Privacy**
   - Default settings are good for most users
   - Don't share your view key unless necessary
   - Be careful proving payments (reveals information)

### What should I do if I lose my wallet?

**If you have your seed phrase:**
- ✅ You can recover your wallet
- Download wallet software
- Select "Restore from seed"
- Enter your 25-word seed phrase
- Your funds will be restored

**If you don't have your seed phrase:**
- ❌ Your funds are permanently lost
- No one can recover them (not even developers)
- This is the tradeoff for true decentralization

**Prevention:**
- Write down seed phrase when creating wallet
- Store multiple copies in secure locations
- Consider metal backup (fireproof/waterproof)
- NEVER store digitally (no photos, no cloud, no email)

---

## Community & Support

### How can I get help?

**Official support channels:**
- 💬 Discord: [DISCORD_URL] - Real-time community support
- 📱 Telegram: [TELEGRAM_URL] - Active community discussion
- 📖 Reddit: r/xwift - Threaded discussions
- 💻 GitHub Issues: [GITHUB_URL] - Technical issues and bugs
- 📧 Email: support@xwift.io - Official support

**Documentation:**
- User guides: [DOCS_URL]
- Mining tutorials: [MINING_URL]
- Developer docs: [DEV_DOCS_URL]
- FAQ: [FAQ_URL]

### How can I contribute to Xwift?

**Non-technical contributions:**
- Join community discussions
- Help new users in Discord/Telegram
- Create educational content
- Translate documentation
- Share Xwift on social media
- Run community events

**Technical contributions:**
- Report bugs on GitHub
- Submit pull requests
- Improve documentation
- Test new features
- Run seed nodes
- Develop tools and integrations

**Bounties available** for valuable contributions!

### Is there a bug bounty program?

**Yes!** We reward security researchers who responsibly disclose vulnerabilities.

**Bounty ranges:**
- Critical vulnerabilities: 50-500 XFT
- High severity: 20-100 XFT
- Medium severity: 5-20 XFT
- Low severity: 1-5 XFT

**How to report:**
1. **DO NOT** disclose publicly
2. Email: security@xwift.io
3. Include details and proof of concept
4. Allow us time to fix before disclosure
5. Receive bounty after fix is deployed

### Where can I see the roadmap?

**Short-term roadmap (Year 1):**
- ✅ Mainnet launch
- 🔄 Exchange listings (ongoing)
- 🔄 Mobile wallets (Q1-Q2)
- 🔄 Payment processors (Q2-Q3)
- 🔄 Hardware wallet support (Q3-Q4)

**Long-term roadmap (Year 2+):**
- Protocol optimizations
- Privacy enhancements
- Ecosystem expansion
- Cross-chain integrations
- Merchant adoption

**Detailed roadmap:** [ROADMAP_URL]

### Who are the team members?

We believe in decentralized development with multiple contributors rather than a centralized team structure. Core contributors use pseudonyms to maintain privacy and prevent targeting.

**Why pseudonymous?**
- Privacy developers deserve privacy
- Prevents personal targeting
- Follows cryptocurrency tradition (Satoshi, etc.)
- Focuses on code quality, not personality

**Code is public** - anyone can audit contributions and competency.

---

## Comparison Questions

### Xwift vs Monero - What's the difference?

**Similarities:**
- Same privacy technology (ring signatures, stealth addresses, RingCT)
- Same mining algorithm (RandomX)
- Same security model
- Same commitment to privacy

**Differences:**
| Feature | Xwift | Monero |
|---------|-------|--------|
| Block Time | 30 seconds | 120 seconds |
| Confirmations | 3 minutes | 20 minutes |
| Difficulty Adjust | 4 minutes | 10-15 minutes |
| Initial Supply | 108.8M pre-tail | Unlimited |
| Development Fund | 2% year 1 | Community donations |

**Simple:** Xwift is faster Monero with transparent development fund.

### Xwift vs Zcash - Which is more private?

**Xwift is more private** because:

1. **Mandatory Privacy**
   - Xwift: ALL transactions are private (no choice)
   - Zcash: Privacy is optional (only ~15% use it)

2. **No Trusted Setup**
   - Xwift: No trusted setup required
   - Zcash: Requires trusted ceremony (security risk)

3. **Simpler Privacy**
   - Xwift: Ring signatures (proven, audited)
   - Zcash: zk-SNARKs (complex, newer)

4. **Better Anonymity Set**
   - Xwift: 100% of transactions are private
   - Zcash: Small anonymity set (only shielded txs)

**Verdict:** Xwift provides stronger privacy in practice.

### Xwift vs Bitcoin - Why choose Xwift?

**Privacy:**
- Bitcoin: Completely transparent (everyone sees everything)
- Xwift: Completely private (no one sees anything)

**Speed:**
- Bitcoin: 60-minute confirmations
- Xwift: 3-minute confirmations

**Fees:**
- Bitcoin: Variable, often high ($1-$50+)
- Xwift: Consistently low (~$0.01)

**Mining:**
- Bitcoin: ASIC-dominated (centralized)
- Xwift: CPU-friendly (decentralized)

**Use Case:**
- Bitcoin: Store of value, public ledger
- Xwift: Private transactions, daily use

**Not competing** - Different use cases!

### Why Xwift instead of privacy-focused Bitcoin wallets?

**Bitcoin privacy tools** (CoinJoin, Lightning, etc.) provide LIMITED privacy:
- ❌ Still traceable with blockchain analysis
- ❌ Privacy is optional (reduces anonymity set)
- ❌ Requires trust in coordinators
- ❌ Doesn't hide amounts
- ❌ More expensive (mixing fees)

**Xwift provides COMPLETE privacy:**
- ✅ Untraceable even with advanced analysis
- ✅ Privacy is mandatory (maximum anonymity set)
- ✅ No third-party trust required
- ✅ Hides everything (sender, receiver, amount)
- ✅ Low fees

**Privacy by default** is always stronger than privacy by option.

---

## Advanced Questions

### What are subaddresses and why should I use them?

**Subaddresses** are like "virtual addresses" derived from your main address.

**Benefits:**
- ✅ Better privacy (each payment gets unique address)
- ✅ Organization (different address per contact/purpose)
- ✅ No need for multiple wallets
- ✅ All funds in one wallet

**Example use:**
- Subaddress 1: Mining payouts
- Subaddress 2: Exchange withdrawals
- Subaddress 3: Friend A
- Subaddress 4: Friend B

Your wallet manages this automatically.

### What is a payment ID and do I need to use one?

**Payment ID** is an optional identifier for transactions.

**When needed:**
- Exchanges often require payment IDs for deposits
- Helps identify which user made a deposit
- Without it, exchange can't credit your account

**Modern approach:**
- Integrated addresses (includes payment ID in address)
- Most wallets and services now use these
- Easier and less error-prone

**Your wallet will prompt you** if a payment ID is needed.

### Can I run my own node?

**Yes!** Running your own node:
- ✅ Maximum privacy (don't trust remote nodes)
- ✅ Helps network decentralization
- ✅ Verify your own transactions
- ✅ Support the network

**Requirements:**
- ~200GB disk space (growing)
- Stable internet connection
- 4GB+ RAM
- Decent CPU

**How to run:**
```bash
./xwiftd --detach
```

See node setup guide for details: [NODE_GUIDE_URL]

### What is view key vs spend key?

**Two types of keys:**

1. **View Key (Private)**
   - Allows viewing incoming transactions
   - Cannot spend funds
   - Safe to share for auditing
   - Used by exchanges to detect deposits

2. **Spend Key (Private)**
   - Allows spending funds
   - NEVER share this
   - Whoever has this key owns the funds

**Your seed phrase** generates both keys.

**Use case:** Share view key with your accountant (they can see transactions but not spend).

### How does Xwift handle blockchain bloat?

**Blockchain growth** is a challenge for all cryptocurrencies.

**Xwift solutions:**
1. **Pruning** - Remove spent transaction data (reduces size by 60%)
2. **Efficient cryptography** - Bulletproof+ reduces transaction size
3. **Dynamic block size** - Penalty system prevents spam
4. **Optimized storage** - LMDB database for efficiency

**Full node:** ~200GB (growing ~50GB/year)
**Pruned node:** ~80GB (growing ~20GB/year)

Future: More efficient storage formats being researched.

### What are Bulletproofs and why do they matter?

**Bulletproofs** are cryptographic range proofs used in RingCT.

**What they do:**
- Prove transaction amounts are valid (no negative amounts)
- Do this without revealing actual amounts
- Use much less space than previous methods

**Bulletproof+ benefits:**
- 66% smaller transactions than original Bulletproofs
- Faster verification
- Lower fees
- Better scaling

**Result:** Smaller blockchain, lower fees, better privacy.

### How does Xwift compare to Monero's future updates (Seraphis, Jamtis)?

**Seraphis** is a proposed Monero upgrade for even better privacy and efficiency.

**Xwift's approach:**
- Current privacy is already excellent (Monero-level)
- Monitor Seraphis development
- If successful, can be adopted by Xwift
- Focus now on speed + current proven privacy

**Benefit of being Monero-based:** We can adopt future Monero innovations when they're proven and tested.

---

## Troubleshooting

### My wallet won't sync

**Common causes:**

1. **No connections to network**
   - Check internet connection
   - Check firewall settings
   - Try different remote node

2. **Slow sync**
   - Initial sync takes time (hours to days)
   - Remote node may be slow - try different one
   - Consider running local node

3. **Stuck sync**
   - Restart wallet
   - Delete sync data and resync
   - Check if you're on a fork (verify block hashes)

### I sent XFT but it's not showing up

**Check:**
1. **Wait for confirmations** - Needs at least 1 confirmation (30 seconds)
2. **Correct address?** - Double-check you sent to correct address
3. **Network status** - Check if blockchain is syncing normally
4. **Transaction status** - Look up your transaction on block explorer

**If sent to exchange:**
- May need 10-20 confirmations (5-10 minutes)
- Check exchange deposit status page
- Contact exchange support if still missing after confirmations

### Mining is not working

**Common issues:**

1. **Wallet address wrong format**
   - Check address is correct Xwift address
   - Remove any spaces or typos

2. **Pool connection failed**
   - Check pool URL and port
   - Try different pool
   - Check firewall

3. **Low hashrate**
   - Enable large pages (Windows/Linux)
   - Close background applications
   - Check CPU isn't thermal throttling
   - Update XMRig to latest version

4. **No shares accepted**
   - Check wallet address is correct
   - Verify pool is operating normally
   - Try different pool

See detailed mining troubleshooting: [MINING_TROUBLESHOOTING_URL]

---

## Glossary

**Address** - Public identifier for receiving XFT (like a bank account number)

**Block** - Container of transactions added to blockchain every 30 seconds

**Blockchain** - Distributed ledger containing all Xwift transactions

**Confirmation** - Verification that transaction is included in blockchain

**Daemon** - Background software that runs the Xwift node

**Hash** - Unique identifier (like a fingerprint) for blocks and transactions

**Hashrate** - Mining speed measured in hashes per second

**Mining** - Process of securing blockchain and earning XFT rewards

**Node** - Computer running Xwift software and validating transactions

**Pool** - Group of miners combining hashrate for regular rewards

**Private Key** - Secret key that proves ownership of funds

**Public Key** - Public cryptographic key derived from private key

**Ring Signature** - Privacy technology hiding sender among decoys

**Seed Phrase** - 25 words that backup your wallet (master key)

**Stealth Address** - One-time address for each transaction (hides receiver)

**Subaddress** - Derived address from main address (for organization)

**Tail Emission** - Permanent 9 XFT block reward (perpetual inflation)

**Transaction** - Transfer of XFT from one address to another

**Wallet** - Software for storing keys and managing XFT

---

## Still Have Questions?

### Join Our Community

- 💬 **Discord:** [DISCORD_URL] - Ask questions, get real-time help
- 📱 **Telegram:** [TELEGRAM_URL] - Active community discussion
- 📖 **Reddit:** r/xwift - Longer-form discussions
- 🐦 **Twitter/X:** @xwiftcrypto - Updates and announcements

### Documentation

- 📚 **User Guide:** [USER_GUIDE_URL]
- ⛏️ **Mining Guide:** [MINING_GUIDE_URL]
- 💻 **Developer Docs:** [DEV_DOCS_URL]
- 🔐 **Security Best Practices:** [SECURITY_URL]

### Contact Support

- 📧 **General:** hello@xwift.io
- 🐛 **Bug Reports:** https://github.com/xwift/xwift/issues
- 🔒 **Security Issues:** security@xwift.io (PGP: [PGP_KEY_URL])

---

**Xwift - Privacy at the Speed of Innovation** ⚡🔒

*Last Updated: 2025-01-03*
*This FAQ is regularly updated. Check back for new information.*
