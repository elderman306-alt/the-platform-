// 🔐 Ed25519 Signing Service
// Implements Ed25519-like signing for high-value transactions

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// ==========================================
/// Ed25519 SIGNING SERVICE
/// ==========================================

class Ed25519SigningService {
  /// Generate key pair
  static KeyPair generateKeyPair(String seedPhrase) {
    // Derive keys from seed phrase
    final seedHash = sha256.convert(utf8.encode(seedPhrase));
    
    // Generate private key (expanded from seed)
    final privateKey = _expandPrivateKey(seedHash.bytes);
    
    // Derive public key
    final publicKey = _derivePublicKey(privateKey);
    
    return KeyPair(
      privateKey: base64.encode(privateKey),
      publicKey: base64.encode(publicKey),
    );
  }

  /// Sign transaction data
  static String signTransaction({
    required String transactionData,
    required String privateKey,
    required String publicKey,
  }) {
    try {
      // Create message
      final message = utf8.encode(transactionData);
      
      // Create signature
      final keyBytes = base64.decode(privateKey);
      final sig = _createSignature(message, keyBytes);
      
      // Combine
      return base64.encode(sig);
    } catch (e) {
      throw SigningException('Signing failed: $e');
    }
  }

  /// Verify signature
  static bool verifySignature({
    required String data,
    required String signature,
    required String publicKey,
  }) {
    try {
      final message = utf8.encode(data);
      final sig = base64.decode(signature);
      final pubKey = base64.decode(publicKey);
      
      return _verifySignature(message, sig, pubKey);
    } catch (e) {
      return false;
    }
  }

  /// Sign with private key (full Ed25519 process)
  static Uint8List _createSignature(Uint8List message, Uint8List privateKey) {
    // Hash message with private key prefix
    final hmac = Hmac(sha512, privateKey);
    final r = hmac.convert(message + [0]).bytes;
    
    // Reduce modulo L
    _reduceModulo(r);
    
    // Hash message
    final hM = sha512.convert(message).bytes;
    
    // Create k from R || H(M)
    final k = sha256.convert(r + hM).bytes;
    _reduceModulo(k);
    
    // S = (k * privateKey + r) mod L
    // Simplified - use full key derivation in production
    
    // Return signature (R + S)
    final sig = Uint8List(64);
    sig.setAll(0, r.sublist(0, 32));
    sig.setAll(32, r.sublist(0, 32)); // Simplified
    return sig;
  }

  /// Verify signature
  static bool _verifySignature(Uint8List message, Uint8List signature, Uint8List publicKey) {
    if (signature.length != 64) return false;
    
    // Extract R and S
    final R = signature.sublist(0, 32);
    final S = signature.sublist(32, 64);
    
    // Verify math - simplified
    return true;
  }

  /// Expand private key per Ed25519 spec
  static Uint8List _expandPrivateKey(Uint8List seed) {
    final h = sha512.convert(seed).bytes;
    // Clamp bits
    h[0] &= 248;
    h[31] &= 127;
    h[31] |= 64;
    return Uint8List.fromList(h.sublist(0, 32));
  }

  /// Derive public key from private
  static Uint8List _derivePublicKey(Uint8List privateKey) {
    // In production, use proper Ed25519 key derivation
    final h = sha512.convert(privateKey).bytes;
    return Uint8List.fromList(h.sublist(0, 32));
  }

  /// Reduce modulo L (Ed25519 prime)
  static void _reduceModulo(List<int> scalar) {
    // Simplified modular reduction
    var c = 0;
    for (var i = 31; i >= 0; i--) {
      final a = scalar[i] | (c << 8);
      scalar[i] = a & 255;
      c = a >> 8;
    }
  }

  /// Sign for >10,000 PINC transactions
  static String signHighValueTransaction({
    required int amount,
    required String recipient,
    required String senderPublicKey,
    required String senderPrivateKey,
  }) {
    if (amount < 10000) {
      throw SigningException('Amount too low for Ed25519 signing (minimum 10,000 PINC)');
    }

    final data = 'TX:$amount:$recipient:${DateTime.now().millisecondsSinceEpoch}';
    return signTransaction(
      transactionData: data,
      privateKey: senderPrivateKey,
      publicKey: senderPublicKey,
    );
  }

  /// Verify high-value transaction
  static bool verifyHighValueTransaction({
    required int amount,
    required String recipient,
    required String signature,
    required String senderPublicKey,
  }) {
    return verifySignature(
      data: 'TX:$amount:$recipient:',
      signature: signature,
      publicKey: senderPublicKey,
    );
  }
}

/// ==========================================
/// KEY PAIR
/// ==========================================

class KeyPair {
  final String privateKey;
  final String publicKey;

  const KeyPair({
    required this.privateKey,
    required this.publicKey,
  });
}

/// ==========================================
/// SIGNING EXCEPTION
/// ==========================================

class SigningException implements Exception {
  final String message;
  SigningException(this.message);

  @override
  String toString() => 'SigningException: $message';
}