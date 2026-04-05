# 🤖 AI #2: IDENTITY & SECURITY
## Branch: ai2-identity-security

---

### YOUR TASK
Build the Identity and Security system for THE PLATFORM.

---

### 1️⃣ PINC ID SYSTEM
- Generate unique 8-character ID: `PINC-XXXXXXXX`
- Format: Letters + Numbers only
- Bind to hardware fingerprint + secure enclave
- 1 Account = 1 Device

---

### 2️⃣ 3-LEVEL SECURITY SYSTEM

**Level 1: Device Binding**
```
- Hardware fingerprint (unique per device)
- Secure enclave binding
- Anti-cloning protection
- Anti-emulator detection
- Install nonce
```

**Level 2: Transaction Auth**
```
- PIN: 6-digit for amounts < 100 PINC
- Pattern/Biometric: 100-10,000 PINC
- Private Key Signature: > 10,000 PINC
```

**Level 3: Recovery**
```
- 15-word BIP-39 seed phrase
- Account recovery
- Emergency self-destruct trigger
```

---

### 3️⃣ PROTECTION FEATURES

**Anti-Theft:**
- Device lock on SIM change
- Remote wipe capability
- Shutdown protection
- Uninstall protection (requires Level 2 auth)

**Self-Destruct:**
- On root/jailbreak detection
- On decompilation attempt
- On unauthorized memory access

---

### 📁 FILE STRUCTURE
```
lib/
  core/
    constants.dart      # PIN length, patterns
    security.dart     # Security utilities
  features/
    identity/
      data/
        repositories/
        models/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        screens/
        widgets/
        bloc/
```

---

### 🔐 IMPLEMENTATION

**Create these files:**

1. `lib/core/security/security_service.dart`
   - Hardware ID generation
   - Device fingerprint
   - Secure enclave check

2. `lib/core/security/auth_service.dart`
   - PIN verification (6-digit)
   - Pattern lock (grid 5x5)
   - Biometric check
   - Private key signing

3. `lib/core/security/seed_generator.dart`
   - BIP-39 word list
   - 15-word phrase generation
   - Recovery flow

4. `lib/features/identity/data/models/pinc_id.dart`
   - PINC ID model
   - Device binding

5. `lib/features/identity/presentation/screens/`
   - Setup screen (first launch)
   - Login screen
   - Security settings

---

### ✅ COMPLETE CHECKLIST

- [ ] PINC ID generation (8-char format)
- [ ] Hardware binding
- [ ] PIN verification
- [ ] Pattern lock
- [ ] Biometric support
- [ ] 15-word seed phrase
- [ ] Anti-cloning
- [ ] Anti-emulator
- [ ] Uninstall protection
- [ ] Self-destruct trigger

---

### 🎯 WHEN READY

**Instruction to paste to AI #2:**
```
Go to branch: ai2-identity-security
Create your branch and implement:
- PINC ID system (hardware-bound)
- 3-Level Security (PIN, Pattern, Seed)
- Protection features
```

---

*AI #2: Identity & Security - The foundation of trust*