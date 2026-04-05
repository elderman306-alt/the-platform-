# 🔍 ASSISTANT: RESEARCH & AUDIT
## Branch: asst-research-audit

---

### YOUR ROLE
Work **IN PARALLEL** with all AI agents. Research, audit code, find solutions, and verify quality.

---

### 1️⃣ DEEP RESEARCH

**Research Areas:**

1. **P2P Networking**
   - libp2p-dart
   - Kademlia DHT
   - mesh protocols
   - Best practices

2. **WebRTC**
   - Dart implementation
   - Voice/video calls
   - Screen sharing

3. **Encryption**
   - AES-256-GCM in Dart
   - SHA-3
   - Ed25519
   - Post-quantum (Kyber, Dilithium)

4. **Storage**
   - Hive encryption
   - IPFS integration
   - Best practices

5. **Games**
   - Game logic patterns
   - AI opponents
   - Win detection

6. **Build Systems**
   - Flutter web
   - Android build
   - Cross-compile

---

### 2️⃣ CODE AUDITING

**Check for:**

1. **Null Safety**
   - No `dynamic` without reason
   - Proper nullable handling
   - Type safety

2. **Security**
   - No hardcoded secrets
   - Proper encryption
   - Input validation

3. **Performance**
   - Memory leaks
   - Async handling
   - Efficient algorithms

4. **Code Quality**
   - Clean architecture
   - Proper separation
   - Merge-ready

---

### 3️⃣ BUILD SYSTEM

**Add:**

1. **Build Scripts**
   - Android build
   - Web build
   - Platform builds

2. **Dependencies**
   - Required packages
   - Version management

3. **Verification**
   - Test runs
   - Error fixes

---

### 4️⃣ MERGING

**Process:**

1. Scan each agent branch
2. Identify conflicts
3. Fix merge issues
4. Verify integration
5. Test together

---

### 📁 FILE STRUCTURE
```
research/
  p2p_mesh.md         # Research notes
  webrtc.md
  encryption.md
  storage.md
  games.md
  build_system.md
  findings/          # What you found
audits/
  ai2/
  ai3/
  ai4/
  ai5/
  ai6/
  ai7/
  ai8/
  ai9/
```

---

### 🎯 TASKS

**Per Agent, research:**

1. Find existing solutions
2. Best libraries
3. Code patterns
4. Error handling

**Then audit their code:**

1. Check null safety
2. Check security
3. Check performance
4. Check merge readiness

---

### 🔬 RESEARCH TEMPLATE

**For each area:**

```markdown
## [Area Name]

### Best Existing Solutions
- [Library 1]: [Pros/Cons]
- [Library 2]: [Pros/Cons]

### Recommended
- [Choice]: [Why]

### Implementation Notes
- [Key points]

### Code Examples
[Sample code]
```

---

### ✅ COMPLETE CHECKLIST

- [ ] P2P Networking research
- [ ] WebRTC research
- [ ] Encryption research
- [ ] Storage research
- [ ] Games research
- [ ] Build system research
- [ ] All agent code audits
- [ ] Merge verification
- [ ] Build test

---

### 🎯 WHEN READY

**Instruction to paste to Assistant:**
```
Go to branch: asst-research-audit
Research and audit all agents:
- Deep research each area
- Audit each agent's code
- Fix issues found
- Prepare build system
```

---

*Assistant - The quality control behind THE PLATFORM*