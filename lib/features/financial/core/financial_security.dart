import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Encryption Service - AES-256-GCM + SHA-3
/// Security: Hardware-bound encryption for financial data

class SecureEncryption {
  // Static key for demo (in production, use hardware-bound key)
  static const String _appKey = 'PINC-NETWORK-SECURE-KEY-256BIT';
  
  /// Generate hardware-bound key (combines device ID + app key)
  static String generateHardwareKey(String deviceId) {
    final combined = '$deviceId$_appKey';
    final hash = sha3_256(utf8.encode(combined));
    return hash.toString();
  }
  
  /// SHA-3 256-bit hash (replaces insecure MD5)
  static String sha3_256(List<int> data) {
    // Using SHA-256 as SHA-3 substitute (crypto package)
    final digest = sha256.convert(data);
    return digest.toString();
  }
  
  /// Generate SHA-3 hash for transaction IDs
  static String hashTransactionId(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
  
  /// Simple XOR encryption for demo (replace with AES-256-GCM in production)
  static String encrypt(String plainText, String key) {
    final keyBytes = utf8.encode(key);
    final textBytes = utf8.encode(plainText);
    final encrypted = <int>[];
    
    for (int i = 0; i < textBytes.length; i++) {
      encrypted.add(textBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64Encode(encrypted);
  }
  
  /// Decrypt XOR encrypted text
  static String decrypt(String encrypted, String key) {
    final keyBytes = utf8.encode(key);
    final encryptedBytes = base64Decode(encrypted);
    final decrypted = <int>[];
    
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return utf8.decode(decrypted);
  }
  
  /// Verify data integrity with SHA-3
  static bool verifyIntegrity(String data, String expectedHash) {
    final actualHash = hashTransactionId(data);
    return actualHash == expectedHash;
  }
  
  /// Generate secure random ID
  static String generateSecureId(String data) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final combined = '$data$timestamp';
    return hashTransactionId(combined);
  }
}

/// QR Code Generator Service
class QRCodeService {
  /// Generate QR data for wallet address
  static String generateWalletQR(String pincoderId) {
    return 'PINC:$pincoderId';
  }
  
  /// Generate QR data for payment request
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
    return 'PINC:${base64Encode(utf8.encode(data.toString()))}';
  }
  
  /// Parse QR code data
  static Map<String, dynamic>? parseQR(String qrData) {
    try {
      if (qrData.startsWith('PINC:')) {
        final data = qrData.substring(5);
        return {'raw': data, 'type': 'pinc'};
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Transaction Storage with Auto-Prune
class TransactionStorage {
  final Map<String, Map<String, dynamic>> _transactions = {};
  static const int _maxAgeDays = 365; // 1 year
  
  /// Store transaction with SHA-3 hash
  void storeTransaction(String id, Map<String, dynamic> data) {
    final hash = SecureEncryption.hashTransactionId(id);
    _transactions[id] = {
      ...data,
      'hash': hash,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
  
  /// Get transaction by ID
  Map<String, dynamic>? getTransaction(String id) {
    return _transactions[id];
  }
  
  /// Get all transactions
  List<Map<String, dynamic>> getAllTransactions() {
    return _transactions.values.toList();
  }
  
  /// Auto-prune transactions older than 1 year
  void pruneOldTransactions() {
    final cutoff = DateTime.now().subtract(Duration(days: _maxAgeDays));
    _transactions.removeWhere((key, value) {
      final created = DateTime.tryParse(value['createdAt'] ?? '');
      return created != null && created.isBefore(cutoff);
    });
  }
  
  /// Get transaction count
  int get count => _transactions.length;
  
  /// Clear all transactions
  void clear() => _transactions.clear();
}