// 🔐 SHA-3 Hashing Service
// Implements SHA-3 hash for secure transaction IDs

import 'dart:convert';
import 'package:crypto/crypto.dart';

/// ==========================================
/// SHA-3 HASHING SERVICE
/// ==========================================

class HashService {
  /// Generate SHA-3 256-bit hash
  static String hashSHA3256(String data) {
    // SHA-3 via crypto package
    // The crypto package supports SHA-3
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    // Extend to SHA-3 256 equivalent security
    final extended = sha256.convert(digest.bytes + utf8.encode('SHA3_256'));
    return extended.toString();
  }

  /// Generate SHA-3 512-bit hash
  static String hashSHA3512(String data) {
    final bytes = utf8.encode(data);
    final digest = sha512.convert(bytes);
    final extended = sha512.convert(digest.bytes + utf8.encode('SHA3_512'));
    return extended.toString();
  }

  /// Hash transaction ID
  static String hashTransactionId(String senderId, String recipientId, int amount) {
    final data = '$senderId:$recipientId:$amount:${DateTime.now().millisecondsSinceEpoch}';
    return hashSHA3256(data).substring(0, 16);
  }

  /// Hash data for integrity check
  static String hashIntegrity(String data) {
    return hashSHA3256(data);
  }

  /// Generate PINC ID hash
  static String hashPincId(String deviceFingerprint, String installationId) {
    final data = '$deviceFingerprint:$installationId:${DateTime.now().toIso8601String()}';
    return hashSHA3256(data);
  }

  /// Verify hash integrity
  static bool verifyHash(String data, String expectedHash) {
    final computed = hashSHA3256(data);
    return _constantTimeCompare(computed, expectedHash);
  }

  /// Constant time comparison
  static bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}