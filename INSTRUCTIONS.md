# 🔷 THE PLATFORM - AI AGENT INSTRUCTIONS
# Complete Implementation Guide & Commands

---

## 📋 QUICK START

**You are an AI agent working on THE PLATFORM (a Flutter APK).**
**Follow the commands below when instructed by user.**
**Create your branch, implement your feature, and push work.****

---

## 🎯 YOUR ROLE

You are assigned to build a specific feature/module.
When instructed, you will:
1. Create a new branch with your assigned branch name
2. Research and find best existing solutions
3. Implement the feature
4. Ensure code can merge with other agents

---

## 📦 BRANCH ASSIGNMENTS

| Branch | Agent | Work Area | Start Order |
|--------|-------|--------|----------|-----------|
| ai1-manager | AI #1 | Coordinator | 1 |
| ai2-identity-security | AI #2 | Identity & Auth | 2 |
| ai3-p2p-mesh-vpn | AI #3 | Internet Sharing | 3 |
| ai4-communication | AI #4 | Chat & Calls | 4 |
| ai5-financial | AI #5 | Wallet & Bets | 5 |
| ai6-gaming | AI #6 | Games | 6 |
| ai7-jobs | AI #7 | Jobs Marketplace | 7 |
| ai8-security-admin | AI #8 | Admin & Fraud | 8 |
| ai9-cross-platform | AI #9 | UI & Platforms | 9 |
| asst-research-audit | Assistant | Research & Audit | PARALLEL |

---

## ⚡ ORDER TO START

### Phase 1: START FIRST (After Manager)
1. **AI #2** (Identity & Security) - Foundation
2. **AI #9** (UI & Platforms) - Foundation

### Phase 2: START SECOND (After Identity)
3. **AI #5** (Financial) - Depends on Identity
4. **AI #3** (P2P Mesh VPN) - Core feature
5. **AI #4** (Communication) - Core feature

### Phase 3: START THIRD (After Financial & Communication)
6. **AI #6** (Gaming) - Can use wallet
7. **AI #7** (Jobs) - Can use wallet

### Phase 4: START FOURTH (After Most)
8. **AI #8** (Security & Admin) - Needs all systems

### ALWAYS: Assistant - Works in parallel on all

---

## 🔧 IMPLEMENTATION RULES

### Code Quality
- Use Dart best practices
- Null safety: ALWAYS use proper types, no `?` unless needed
- Use `final` for unchanging values
- Use `const` for compile-time constants
- Add comments for complex logic

### File Structure
```
lib/
  core/           # Shared utilities
    constants.dart
    theme.dart
    utils.dart
  features/       # Each feature module
    feature_name/
      data/
      domain/
      presentation/
  shared/        # Shared widgets
```

### Merge Ready
- Do NOT create new files unnecessarily
- Keep functions small and focused
- Use clear naming: `feature_action_target`
- All code must merge without conflicts

---

## 📝 SPECIFIC AGENT INSTRUCTIONS

### AI #2: IDENTITY & SECURITY
```
Branch: ai2-identity-security
Work:
1. PINC ID system (PINC-XXXXXXXX format)
2. Device binding (hardware fingerprint + secure enclave)
3. 3-Level Security:
   - Level 1: PIN (6-digit)
   - Level 2: Pattern/Biometric
   - Level 3: 15-word seed phrase + Private Key
4. Anti-cloning, anti-emulator
5. Uninstall protection
6. Self-destruct on tampering
```

### AI #3: P2P MESH VPN
```
Branch: ai3-p2p-mesh-vpn
Work:
1. Mesh networking setup (libp2p/Kademlia)
2. Internet seller system
3. Buyer connection
4. SLA tracking (87% uptime/speed)
5. Dynamic pricing
6. Escrow + Auto-refund
```

### AI #4: COMMUNICATION
```
Branch: ai4-communication
Work:
1. Chat UI + E2E encryption
2. Voice calls (WebRTC)
3. Video calls (WebRTC)
4. Screen sharing
5. Find user by PINC ID
6. Group calls (up to 50)
```

### AI #5: FINANCIAL
```
Branch: ai5-financial
Work:
1. PINC Wallet (send/receive/deposit/withdraw)
2. Internal transfers: FREE
3. P2P Agent system (4-7% margin)
4. Betting (7% + 5% creator, min 20 PINC)
5. Fundraising (9%)
6. Fee structure (tiered withdrawals)
```

### AI #6: GAMING
```
Branch: ai6-gaming
Work:
1. Connect 4
2. Tic Tac Toe
3. Memory Match
4. Snake
5. Pong
6. Wordle
7. League system (50 players)
8. Wager system (min 20 PINC)
9. External games (PUBG/PES/FIFA/MK)
```

### AI #7: JOBS
```
Branch: ai7-jobs
Work:
1. Post job (3% fee)
2. Bid system
3. Escrow
4. Work submission/review
5. Dispute (3 referees)
6. Payout (9% fee)
```

### AI #8: SECURITY & ADMIN
```
Branch: ai8-security-admin
Work:
1. Fraud detection (P2P consensus)
2. Account freeze
3. Admin APK
4. Admin key: david orata anglex ambuch elderman makaveli
5. Data fragmentation
6. Quantum-resistant encryption
```

### AI #9: CROSS-PLATFORM & UI
```
Branch: ai9-cross-platform-ui
Work:
1. Flutter app (6 tabs)
2. Dark theme (colors below)
3. All platform builds
4. Localization (50+ languages)
5. Storage (Hive)

Color Scheme:
- Primary: #00D4AA
- Secondary: #7B61FF
- Background: #0A0E14
- Surface: #131A24
- Error: #FF4757
```

---

## 🎯 WHEN READY

**The user will paste your specific branch command when ready.**

**Example instruction you will receive:**
```
Go to branch: ai2-identity-security
Create your branch and implement:
[Your specific work]
```

**Wait for your instruction before starting any work.**

---

*THE PLATFORM - Building the future of decentralized communication*