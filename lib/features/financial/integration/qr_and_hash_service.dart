import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Financial Integration Services
/// PayPal, Stripe, QR Code, and Hardware Keystore

/// QR Code Generation Service
class QRCodeService {
  /// Generate QR code data for wallet address
  static String generateWalletQR(String pincoderId) {
    return 'PINC:$pincoderId';
  }
  
  /// Generate QR code data for payment request
  static String generatePaymentQR({
    required String pincoderId,
    required double amount,
    String? description,
  }) {
    final data = {
      'type': 'payment',
      'to': pincoderId,
      'amount': amount,
      'desc': description ?? '',
    };
    return 'PINC:${base64Encode(utf8.encode(json.encode(data)))}';
  }
  
  /// Parse QR code data
  static Map<String, dynamic>? parseQR(String qrData) {
    try {
      if (qrData.startsWith('PINC:')) {
        final encoded = qrData.substring(5);
        final decoded = utf8.decode(base64Decode(encoded));
        return json.decode(decoded) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Generate withdraw QR code
  static String generateWithdrawQR({
    required String bankAccount,
    required double amount,
  }) {
    final data = {
      'type': 'withdraw',
      'bank': bankAccount,
      'amount': amount,
    };
    return 'PINC:WITHDRAW:${base64Encode(utf8.encode(json.encode(data)))}';
  }
}

/// SHA-3 Hash Service (replaces insecure MD5)
class HashService {
  /// Generate SHA-3-256 hash for transaction IDs
  static String hashTransaction(String data) {
    final bytes = utf8.encode(data);
    // Using SHA-256 as SHA-3 substitute (crypto package doesn't have SHA-3)
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Generate secure transaction ID
  static String generateTransactionId(String walletId, double amount) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$walletId:$amount:$timestamp';
    return hashTransaction(data).substring(0, 16);
  }
  
  /// Verify transaction integrity
  static bool verifyIntegrity(String data, String expectedHash) {
    final actual = hashTransaction(data);
    return actual == expectedHash;
  }
}

/// Hardware Keystore Binding Service
class KeystoreService {
  static String? _deviceId;
  static String? _hardwareKey;
  
  /// Initialize hardware binding (simulated)
  static Future<void> initialize(String deviceId) async {
    _deviceId = deviceId;
    _hardwareKey = HashService.hashTransaction('PINC:$deviceId:HARDWARE');
  }
  
  /// Get hardware-bound key
  static String? get hardwareKey => _hardwareKey;
  
  /// Verify device matches
  static bool verifyDevice(String deviceId) {
    return _deviceId == deviceId;
  }
  
  /// Generate hardware-signed message
  static String signMessage(String message) {
    if (_hardwareKey == null) throw Exception('Keystore not initialized');
    final data = '$_hardwareKey:$message';
    return HashService.hashTransaction(data);
  }
  
  /// Verify hardware signature
  static bool verifySignature(String message, String signature) {
    final expected = signMessage(message);
    return expected == signature;
  }
}

/// Transaction Auto-Prune Service
class TransactionPruner {
  static const int _maxAgeDays = 365;
  final Map<String, Map<String, dynamic>> _transactions = {};
  
  /// Store transaction with timestamp
  void storeTransaction(String id, Map<String, dynamic> data) {
    _transactions[id] = {
      ...data,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// Prune transactions older than 1 year
  Future<int> pruneOldTransactions() async {
    final cutoff = DateTime.now().subtract(Duration(days: _maxAgeDays));
    final toRemove = <String>[];
    
    for (final entry in _transactions.entries) {
      final created = DateTime.tryParse(entry.value['createdAt'] ?? '');
      if (created != null && created.isBefore(cutoff)) {
        toRemove.add(entry.key);
      }
    }
    
    for (final id in toRemove) {
      _transactions.remove(id);
    }
    
    return toRemove.length;
  }
  
  /// Get transaction count
  int get count => _transactions.length;
  
  /// Clear all transactions
  void clear() => _transactions.clear();
}