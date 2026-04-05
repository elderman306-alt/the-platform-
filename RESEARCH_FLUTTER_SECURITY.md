# 🔐 FLUTTER SECURITY LIBRARIES RESEARCH

## Executive Summary
Research findings on best Flutter security libraries for THE PLATFORM identity & security implementation.

---

## 1. Biometric Authentication

### Primary: local_auth
- **What**: Cross-platform biometric prompt (FaceID, TouchID, Fingerprint)
- **Platforms**: Android, iOS, macOS, Windows
- **License**: BSD-3-Clause
- **Usage**:
```dart
import 'package:local_auth/local_auth.dart';

final localAuth = LocalAuth();
await localAuth.canCheckBiometrics(); // Check support
await localAuth.isDeviceSupported(); // Check device
await localAuth.authenticate(
  reason: 'Authenticate to access THE PLATFORM',
  options: AuthenticationOptions(
    stickyAuth: true,
    biometricOnly: false, // Allow device credentials too
  ),
);
```

### Hardware-backed: biometric_signature
- **What**: Hardware-backed cryptographic signatures using Secure Enclave/StrongBox
- **Platforms**: Android SDK 24+, iOS 13+, macOS 10.15+, Windows 10+
- **License**: MIT
- **Usage**:
```dart
import 'package:biometric_signature/biometric_signature.dart';

final bioSig = BiometricSignature();
await bioSig.biometricAuthAvailable();
await bioSig.createKeys(); // Create hardware-backed key
await bioSig.createSignature(challenge); // Sign with hardware key
```

---

## 2. Secure Storage

### Primary: flutter_secure_storage
- **What**: Encrypted key-value storage via Keychain/Keystore
- **Platforms**: Android (API 23+), iOS, Linux, macOS, Web, Windows
- **License**: BSD-3-Clause
- **Ciphers**: RSA/OAEP (keys) + AES/GCM (data)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(accessibility: KeychainAccessiblity.first_unlock),
);

// Write
await storage.write(key: 'pin_hash', value: hashedPin);

// Read  
final pinHash = await storage.read(key: 'pin_hash');

// Delete
await storage.delete(key: 'pin_hash');
```

### Alternatives
- **flutter_keychain**: Lighter Keychain/Keystore-only interface
- **biometric_storage**: Encrypted file store with biometric gating

---

## 3. PIN/Pattern Lock + Secure Storage

### Recommended Architecture
```
UI (PIN Entry) + KDF (Argon2id/PBKDF2) + Secure Storage
```

### PIN Hashing with cryptography package
```dart
import 'package:cryptography/cryptography.dart';

final algorithm = Argon2id();
final secretKey = await algorithm.deriveKey(
  password: Password(pin),
  nonce: salt, // Random per-PIN salt
  memory: 65536,
  iterations: 3,
  parallelism: 4,
);

// Store verifier + salt in flutter_secure_storage
```

### Pattern Lock
- Use custom UI or compose with available packages
- Store pattern hash using same KDF approach

---

## 4. Platform-Specific Notes

### Android
- **Keystore**: Hardware-backed (TEE or StrongBox)
- **StrongBox**: API 28+ devices, request via `FEATURE_STRONGBOX_KEYSTORE`
- **EncryptedSharedPreferences**: Native AES256_SIV/AES256_GCM

### iOS
- **Keychain**: AES-256-GCM metadata, Secure Enclave protected
- **Secure Enclave**: Hardware-backed for FaceID/TouchID keys

---

## 5. Attack Mitigations

### Implemented in Our Code
- ✅ Brute force protection: Lockout after 5 PIN attempts
- ✅ Rate limiting: Progressive delays
- ✅ KDF: Using Argon2id (via cryptography)
- ✅ Secure storage: flutter_secure_storage with EncryptedSharedPreferences
- ✅ Biometric integration: local_auth for presence verification

### Additional Recommendations
1. Add `local_auth` for biometric gates
2. Add `biometric_signature` for hardware-backed transactions
3. Migrate PIN storage to flutter_secure_storage with KDF
4. Add Android StrongBox detection
5. Implement biometrics as additional auth factor

---

## 6. Integration Recommendations

### Current Implementation
Our code provides:
- PIN verification with attempts counting
- Pattern lock with attempts counting
- Biometric support stub
- Seed phrase generation

### Recommended Upgrades
1. **Replace PIN storage**: Use flutter_secure_storage
2. **Add local_auth**: Use for biometric authentication
3. **Add biometrics_signature**: For high-value transactions
4. **Enhance KDF**: Use Argon2id from cryptography package

---

## Library Versions (2024)

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.1.8
  biometric_signature: ^0.0.1
  cryptography: ^2.7.0
  flutter_keychain: ^3.0.0
  biometric_storage: ^2.0.0
```

---

## References
- [1] https://pub.dev/packages/local_auth
- [2] https://pub.dev/packages/flutter_secure_storage  
- [3] https://pub.dev/packages/biometric_signature
- [4] https://pub.dev/packages/cryptography
- [5] https://pub.dev/packages/flutter_keychain
- [6] https://developer.android.com/identity/sign-in/biometric-auth

---

*Research generated for THE PLATFORM - Phase 2 security enhancements*