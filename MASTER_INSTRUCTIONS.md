# 🔷 THE PLATFORM - CENTRAL INSTRUCTIONS
# All AI Agents - Read From Here

---

## 📋 MASTER INSTRUCTION DOCUMENT

**Location:** This file is on branch `ai1-manager` in repo `elderman306-alt/the-platform-`
**All other AIs must read and follow instructions from here**

---

## 🎯 CURRENT STATUS

### Repositories:
| Repo | URL | Status |
|------|-----|--------|
| #1 | https://github.com/elderman306-alt/the-platform- | Main - Use this |
| #2 | https://github.com/a01751077-sudo/the-next | Secondary |

### Where to get instructions:
**AI #1 Manager Branch:** https://github.com/elderman306-alt/the-platform-/tree/ai1-manager

**Files to read:**
1. `README.md` - Platform overview
2. `SPEC.md` - Complete specifications
3. `INSTRUCTIONS.md` - Phase 1 instructions
4. `COMMANDS.md` - Quick copy commands
5. `PHASE2_COMMANDS.md` - Phase 2 commands

---

## 📊 AUDIT FINDINGS

### What's DONE:
| AI | Work | Status |Repo | Files |
|----|------|--------|-----|------|
| **AI #9** | Cross-Platform Flutter | ✅✅ DONE | #2 | 12 files - Full Flutter app |
| **AI #8** | Security Admin | ✅ DONE | #2 | SECURITY.md, .gitignore |

### What's NEEDED:
| AI | Work | Priority |
|----|------|----------|
| **AI #2** | Identity & Security | START NOW |
| **AI #5** | Financial | Phase 2 |
| **AI #3** | P2P Mesh VPN | Phase 2 |
| **AI #4** | Communication | Phase 2 |
| **AI #6** | Gaming | Phase 3 |
| **AI #7** | Jobs | Phase 3 |

---

## 🔴 PROBLEMS IDENTIFIED

### Problem 1: Empty Branches
Most branches in both repos only have instruction files, NO actual implementation code yet.

### Problem 2: No Flutter SDK
Cannot build APK in container - needs local machine with Android SDK.

### Problem 3: Missing Integration
AI #9 created Flutter app but other AIs haven't added their feature code yet.

### Problem 4: Research Needed
Need to research best libraries for:
- P2P mesh (libp2p-dart)
- WebRTC
- Encryption (AES-256-GCM)
- Storage (Hive)

---

## 📝 PHASE 2 COMMANDS

### Each AI must:

1. **Read** this central instruction document
2. **Go to** their assigned branch
3. **Create** their implementation files
4. **Push** when complete

### AI #5: FINANCIAL
```
BRANCH: ai5-financial
REPO: https://github.com/elderman306-alt/the-platform-/tree/ai5-financial

IMPLEMENT:
- lib/features/financial/wallet_service.dart
- lib/features/financial/transfer_service.dart  
- lib/features/financial/bet_service.dart
- lib/features/financial/fee_calculator.dart

FEATURES:
- Send/Receive/Deposit/Withdraw PINC
- Internal Transfer: FREE
- Withdrawal Fee: 3-103 PINC (tiered)
- Job Fee: 3% | Payout: 9%
- Betting: 7% + 5% creator
```

### AI #3: P2P MESH VPN
```
BRANCH: ai3-p2p-mesh-vpn
REPO: https://github.com/elderman306-alt/the-platform-/tree/ai3-p2p-mesh-vpn

IMPLEMENT:
- lib/features/p2p/mesh_service.dart
- lib/features/p2p/seller_service.dart
- lib/features/p2p/buyer_service.dart
- lib/features/p2p/sla_tracker.dart
- lib/features/p2p/escrow_service.dart

FEATURES:
- Mesh networking
- Seller: 435 PINC/month
- SLA: 87% uptime
- Escrow + refund
```

### AI #4: COMMUNICATION
```
BRANCH: ai4-communication
REPO: https://github.com/elderman306-alt/the-platform-/tree/ai4-communication

IMPLEMENT:
- lib/features/chat/chat_service.dart
- lib/features/chat/encryption.dart
- lib/features/calls/webrtc_service.dart
- lib/features/calls/call_manager.dart
- lib/features/calls/screen_share.dart

FEATURES:
- E2E encrypted chat
- Voice/Video calls (WebRTC)
- Screen sharing
- Caller pays system
```

---

## 🔍 RESEARCH TASKS

### Assistant (Research/Audit):
```
BRANCH: asst-research-audit
REPO: https://github.com/elderman306-alt/the-platform-/tree/asst-research-audit

TASKS:
1. Research best libraries for each feature
2. Audit completed code
3. Find issues
4. Report findings
```

**Research topics:**
- P2P mesh: libp2p-dart, manual implementation
- WebRTC: flutter_webrtc package
- Encryption: encrypt package, crypto
- Storage: Hive, sqflite

---

## ✅ COMPLETION REQUIREMENTS

### Each AI must create:
- [ ] Feature service files
- [ ] Data models
- [ ] UI screens (if applicable)
- [ ] Tests (if possible)
- [ ] Update README

### Code quality:
- [ ] Null safety - no `dynamic` without reason
- [ ] Proper error handling
- [ ] Clean architecture
- [ ] Comments for complex logic

---

## 📚 FILE STRUCTURE

```
lib/
  core/
    constants.dart
    theme.dart
    utils.dart
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
```

---

## 🚀 HOW TO START

### Step 1: Read Instructions
Go to: https://github.com/elderman306-alt/the-platform-/tree/ai1-manager
Read: README.md, SPEC.md, INSTRUCTIONS.md, COMMANDS.md

### Step 2: Go to Your Branch
```
git checkout [your-branch-name]
```

### Step 3: Create Implementation
Create the files specified in your instructions

### Step 4: Push Work
```
git add .
git commit -m "feat: Implement [feature name]"
git push -u origin [your-branch-name]
```

---

## 📞 NEED HELP?

### Check existing work:
- AI #9 Flutter app: https://github.com/a01751077-sudo/the-next/tree/ai9-cross-platform
- AI #8 Security: https://github.com/a01751077-sudo/the-next/tree/ai8-security-admin

### Ask questions:
- Read SPEC.md for exact specifications
- Check COMMANDS.md for quick reference
- Review INSTRUCTIONS.md for detailed requirements

---

*THE PLATFORM - All instructions centralized here*