# 🤖 AI #5: FINANCIAL SYSTEM
## Branch: ai5-financial

---

### YOUR TASK
Build the PINC Wallet, Payments, Betting, and Financial system.

---

### 1️⃣ PINC WALLET

**Core:**
- Store PINC coins (1 PINC = $0.01 USD)
- Send to any PINC ID
- Receive via QR code
- Deposit/Withdraw

**Internal Transfer:**
- FREE, instant
- Up to 1 Trillion PINC
- Zero logs retained

---

### 2️⃣ DEPOSIT & WITHDRAWAL

**Deposit Methods:**
| Method | How It Works |
|--------|--------------|
| BSC Crypto | USDT/USDC to unique HD wallet |
| PayPal Business | Webhook signed |
| P2P Agents | Local agent match |

**Withdrawal:**
- Same three methods, reversed
- Tiered fees (see below)

---

### 3️⃣ FEE STRUCTURE

**Exact Fees:**
| Transaction | Fee |
|-------------|-----|
| Internal Transfer | FREE |
| Deposit | FREE |
| Withdrawal | 3-103 PINC |
| Job Creation | 3% |
| Job Payout | 9% |
| Platform Subscription | 325 PINC/month |
| P2P Bet | 7% + 5% creator |
| Fundraising | 9% |
| Global Challenge | 1,560 PINC |

**Withdrawal Tiers:**
```
100-1,000 PINC → 3 PINC
1,001-3,000 → 10 PINC
3,001-10,000 → 19 PINC
10,001-39,000 → 35 PINC
39,001-60,000 → 45 PINC
60,001-90,000 → 60 PINC
90,001-500,000 → 74 PINC
500,001+ → 103 PINC
Minimum: 100 PINC
```

---

### 4️⃣ P2P AGENT SYSTEM

**Agent Profit Margin: 4-7%**
- Platform rate: 1 PINC = $0.01
- Agent sell: $0.0104-0.0107
- Agent buy: $0.0093-0.0096

**Flow:**
1. User wants deposit
2. Agent quotes rate
3. User pays fiat
4. Agent confirms
5. PINC released to user

---

### 5️⃣ BETTING SYSTEM

**P2P Bet:**
- 7% to winner
- Up to 5% creator fee (optional)
- Min wager: 20 PINC

**Developer-Funded Bet:**
- 13% of total stakes to platform

---

### 📁 FILE STRUCTURE
```
lib/
  features/
    financial/
      wallet/
      payments/
      bets/
      agents/
```

---

### 🔧 IMPLEMENTATION

**Wallet:**
1. `wallet_service.dart`
2. `balance_manager.dart`
3. `wallet_screen.dart`

**Payments:**
1. `deposit_service.dart`
2. `withdrawal_service.dart`
3. `transfer_service.dart`

**Bets:**
1. `bet_service.dart`
2. `bet_screen.dart`
3. `settlement_service.dart`

---

### ✅ COMPLETE CHECKLIST

- [ ] Wallet balance
- [ ] Send/receive PINC
- [ ] Internal transfer FREE
- [ ] Deposit (3 methods)
- [ ] Withdrawal (tiered fees)
- [ ] P2P Agent system
- [ ] Betting (7% + 5%)
- [ ] Fundraising (9%)

---

### 🎯 WHEN READY

**Instruction to paste to AI #5:**
```
Go to branch: ai5-financial
Create your branch and implement:
- PINC Wallet
- Send/receive/deposit/withdraw
- Fee structure (tiered)
- P2P Agent system
- Betting system
```

---

*AI #5: Financial - Money without borders*