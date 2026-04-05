# 🔷 PHASE 2 - COMMANDS & INSTRUCTIONS
# Research, Completion & Cross-Audit

---

## 📋 PHASE 2 OVERVIEW

### Agents Starting Phase 2:
| Agent | Branch | Work | Repo |
|-------|--------|------|------|
| **AI #5** | Financial | Wallet, Payments, Bets | Repo 1 or 2 |
| **AI #3** | P2P Mesh VPN | Internet Sharing | Repo 1 or 2 |
| **AI #4** | Communication | Chat, Calls | Repo 1 or 2 |

### Research & Audit Role:
| Agent | Branch | Work |
|-------|--------|------|
| **Assistant** | Research/Audit | Verify all work, find issues |

---

## 📝 PHASE 2 COMMANDS

### 💰 AI #5: FINANCIAL
```
Go to branch: ai5-financial
Create your branch and implement:
- PINC Wallet (send/receive/deposit/withdraw)
- Internal transfers: FREE, unlimited
- Fee structure:
  * Withdrawal: 3-103 PINC tiered
  * Job 3%, Job Payout 9%
  * Platform 325 PINC/month
- P2P Agent system (4-7% margin)
- Betting (7% + 5% creator, min 20 PINC)
- Fundraising (9%)

REQUIRED FILES:
- lib/features/financial/wallet_service.dart
- lib/features/financial/transfer_service.dart
- lib/features/financial/bet_service.dart
- lib/features/financial/fee_calculator.dart
```

### 🌐 AI #3: P2P MESH VPN
```
Go to branch: ai3-p2p-mesh-vpn
Create your branch and implement:
- Mesh networking (libp2p/Kademlia DHT)
- Seller system:
  * 435 PINC/month to sell
  * Free: 3 users, Premium: +325 PINC → 10 users
  * SLA: 87% uptime + 87% speed
- Buyer connection system
- Dynamic pricing
- Escrow + Auto-refund

REQUIRED FILES:
- lib/features/p2p/mesh_service.dart
- lib/features/p2p/seller_service.dart
- lib/features/p2p/buyer_service.dart
- lib/features/p2p/sla_tracker.dart
- lib/features/p2p/escrow_service.dart
```

### 💬 AI #4: COMMUNICATION
```
Go to branch: ai4-communication
Create your branch and implement:
- Chat (E2E encrypted, WhatsApp-style UI)
- Voice calls (WebRTC, no internet needed)
- Video calls (WebRTC, no internet needed)
- Screen sharing
- Find user by PINC ID
- Group calls (up to 50)
- Caller pays system (caller pays for both)

REQUIRED FILES:
- lib/features/chat/chat_service.dart
- lib/features/chat/encryption.dart
- lib/features/calls/webrtc_service.dart
- lib/features/calls/call_manager.dart
- lib/features/calls/screen_share.dart
```

---

## 🔍 RESEARCH & AUDIT INSTRUCTIONS

### For Assistant (Research/Audit):

**Task 1: Research Best Solutions**
```
Research and document:
1. Best P2P mesh libraries for Dart/Flutter
2. Best WebRTC packages for Flutter
3. Best encryption methods (AES-256-GCM)
4. Best storage solutions (Hive, SQLite)
5. Best gaming libraries for Flutter

For each:
- List top 3 libraries
- Note pros/cons
- Recommend best choice
- Provide code example
```

**Task 2: Audit Phase 2 Work**
```
After each AI completes work:
1. Check for null safety issues
2. Check for security vulnerabilities
3. Check code quality
4. Check merge readiness
5. Verify all required files exist

Report format:
- AI #X: [PASS/FAIL]
- Issues found: [list]
- Recommendations: [list]
```

---

## ✅ COMPLETION CHECKLIST

### Before marking complete, each AI must:
- [ ] Create all required files
- [ ] Implement all features listed
- [ ] Add proper comments
- [ ] Ensure null safety
- [ ] Test locally (if possible)
- [ ] Push to correct branch

### Cross-Audit Requirements:
- [ ] No hardcoded secrets
- [ ] Proper error handling
- [ ] Clean code structure
- [ ] Documentation updated

---

## 📁 FILE NAMING CONVENTION

```
lib/
  features/
    [feature_name]/
      data/
        models/
        repositories/
      domain/
        entities/
        usecases/
      presentation/
        screens/
        widgets/
        bloc/
  core/
    constants.dart
    theme.dart
    utils.dart
```

---

## 🚀 START PHASE 2

**When ready, paste commands to:**
- AI #5 (Financial)
- AI #3 (P2P Mesh VPN)
- AI #4 (Communication)

**Assistant starts research in parallel!**

---

*THE PLATFORM - Phase 2: Building the core features*