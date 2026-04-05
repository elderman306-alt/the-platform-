# 🚨 URGENT - AI #5 (FINANCIAL) - COMPLETE YOUR WORK

## 📋 YOUR AUDIT FINDINGS

### ✅ YOU DID:
- Wallet implementation
- Fee calculations (3% job, 9% payout)
- Transaction storage (in-memory)

### ❌ PROBLEMS FOUND:
1. **No QR Code Generation** - Must add
2. **No QR Code Scanning** - Must add
3. **Uses MD5 instead of SHA-3** - INSECURE
4. **No Hardware Keystore Binding** - Must add
5. **No Transaction Auto-Prune (1 year)** - Implement
6. **No PayPal integration** - Add
7. **No Stripe integration** - Add

---

## 🎯 YOUR TASKS - FIX THESE NOW:

### TASK 1: Implement QR Code Generation
```dart
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeService {
  static Widget generateQR(String data) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
```

### TASK 2: Implement QR Code Scanning
```dart
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerService {
  Future<String?> scanQR() async {
    // Use mobile_scanner package
    // Return scanned data (PINC ID or address)
  }
}
```

### TASK 3: Replace MD5 with SHA-3
```dart
import 'package:crypto/crypto.dart';

class HashService {
  // REPLACE ALL MD5 WITH SHA-3
  static String hashTransaction(String data) {
    // Use SHA-3 (not MD5!)
    return sha3.convert(utf8.encode(data)).toString();
  }
}
```

### TASK 4: Implement Hardware Keystore Binding
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeystoreService {
  static Future<void> bindToHardware() async {
    // Bind wallet to device hardware
    // Use Android Keystore / iOS Keychain
  }
}
```

### TASK 5: Implement Auto-Prune (1 year)
```dart
class TransactionPruner {
  static Future<void> pruneOldTransactions() async {
    // Delete transactions older than 1 year
    // Run on app startup
  }
}
```

### TASK 6: Add PayPal Integration
```dart
class PayPalService {
  // TODO: Add API credentials
  static const String clientId = 'TODO';
  static const String secret = 'TODO';
  
  Future<String> createPayment(double amount) async {
    // Create PayPal payment
  }
}
```

### TASK 7: Add Stripe Integration
```dart
class StripeService {
  // TODO: Add API credentials
  static const String publicKey = 'TODO';
  
  Future<void> processCardPayment(double amount) async {
    // Stripe payment processing
  }
}
```

---

## 🔗 REPO & BRANCH
- **Repo**: https://github.com/elderman306-alt/the-platform-.git
- **Your Branch**: `ai5-financial`

---

## ⏰ Financial is critical - Complete NOW!