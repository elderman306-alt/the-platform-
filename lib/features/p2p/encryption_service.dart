import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Encryption algorithm types
enum EncryptionAlgorithm {
  aes256gcm,
  chacha20poly1305,
}

/// Encrypted message payload
class EncryptedPayload {
  final Uint8List ciphertext;
  final Uint8List nonce;
  final Uint8List authTag;

  EncryptedPayload({
    required this.ciphertext,
    required this.nonce,
    required this.authTag,
  });

  Map<String, dynamic> toJson() => {
    'ciphertext': base64Encode(ciphertext),
    'nonce': base64Encode(nonce),
    'authTag': base64Encode(authTag),
  };

  factory EncryptedPayload.fromJson(Map<String, dynamic> json) => EncryptedPayload(
    ciphertext: base64Decode(json['ciphertext'] as String),
    nonce: base64Decode(json['nonce'] as String),
    authTag: base64Decode(json['authTag'] as String),
  );
}

/// Key pair for asymmetric encryption
class KeyPair {
  final String publicKey;
  final String privateKey;

  KeyPair({required this.publicKey, required this.privateKey});
}

/// E2E Encryption Service
/// Provides end-to-end encryption for P2P communication
class EncryptionService {
  final EncryptionAlgorithm _algorithm;
  
  // Simulated key storage (in production, use secure storage)
  final Map<String, String> _peerKeys = {};
  KeyPair? _ownKeyPair;

  EncryptionService({EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256gcm})
      : _algorithm = algorithm;

  /// Generate a new key pair for this peer
  Future<KeyPair> generateKeyPair() async {
    // In production, use proper key generation
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final seed = sha256.convert(utf8.encode('key-$timestamp')).toString();
    
    _ownKeyPair = KeyPair(
      publicKey: seed.substring(0, 32),
      privateKey: seed.substring(32),
    );
    
    debugPrint('Generated new key pair');
    return _ownKeyPair!;
  }

  /// Get own public key
  String? get publicKey => _ownKeyPair?.publicKey;

  /// Store peer's public key
  Future<void> storePeerKey(String peerId, String publicKey) async {
    _peerKeys[peerId] = publicKey;
    debugPrint('Stored public key for peer: $peerId');
  }

  /// Get peer's public key
  String? getPeerKey(String peerId) => _peerKeys[peerId];

  /// Derive shared secret from key exchange
  String _deriveSharedSecret(String privateKey, String peerPublicKey) {
    // Simplified key derivation (in production use DH or similar)
    final combined = '$privateKey$peerPublicKey';
    return sha256.convert(utf8.encode(combined)).toString();
  }

  /// Encrypt message for a specific peer
  Future<EncryptedPayload> encrypt(
    String peerId, 
    String message,
  ) async {
    final peerKey = _peerKeys[peerId];
    if (peerKey == null) {
      throw Exception('No public key for peer: $peerId');
    }

    if (_ownKeyPair == null) {
      throw Exception('No key pair generated');
    }

    // Derive shared secret
    final sharedSecret = _deriveSharedSecret(_ownKeyPair!.privateKey, peerKey);
    
    // Generate nonce
    final nonce = _generateNonce();
    
    // In production, use proper AES encryption
    // This is a simplified version
    final ciphertext = _xorEncrypt(message, sharedSecret, nonce);
    final authTag = _generateAuthTag(ciphertext, sharedSecret);

    return EncryptedPayload(
      ciphertext: ciphertext,
      nonce: nonce,
      authTag: authTag,
    );
  }

  /// Decrypt message from a specific peer
  Future<String> decrypt(
    String peerId, 
    EncryptedPayload payload,
  ) async {
    final peerKey = _peerKeys[peerId];
    if (peerKey == null) {
      throw Exception('No public key for peer: $peerId');
    }

    if (_ownKeyPair == null) {
      throw Exception('No key pair generated');
    }

    // Derive shared secret
    final sharedSecret = _deriveSharedSecret(_ownKeyPair!.privateKey, peerKey);
    
    // Verify auth tag
    final expectedTag = _generateAuthTag(payload.ciphertext, sharedSecret);
    if (!_constantTimeCompare(payload.authTag, expectedTag)) {
      throw Exception('Authentication tag mismatch - message tampered');
    }

    // Decrypt
    return _xorDecrypt(payload.ciphertext, sharedSecret, payload.nonce);
  }

  Uint8List _generateNonce() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = timestamp % 256;
    return Uint8List.fromList(List.generate(12, (i) => (random + i) % 256));
  }

  Uint8List _generateAuthTag(Uint8List data, String key) {
    final combined = '$key${base64Encode(data)}';
    final hash = sha256.convert(utf8.encode(combined));
    return Uint8List.fromList(hash.bytes.sublist(0, 16));
  }

  Uint8List _xorEncrypt(String plaintext, String key, Uint8List nonce) {
    final keyBytes = sha256.convert(utf8.encode(key)).bytes;
    final plaintextBytes = utf8.encode(plaintext);
    
    final encrypted = Uint8List(plaintextBytes.length);
    for (int i = 0; i < plaintextBytes.length; i++) {
      encrypted[i] = plaintextBytes[i] ^ keyBytes[i % keyBytes.length] ^ nonce[i % nonce.length];
    }
    
    return encrypted;
  }

  String _xorDecrypt(Uint8List ciphertext, String key, Uint8List nonce) {
    final keyBytes = sha256.convert(utf8.encode(key)).bytes;
    
    final decrypted = Uint8List(ciphertext.length);
    for (int i = 0; i < ciphertext.length; i++) {
      decrypted[i] = ciphertext[i] ^ keyBytes[i % keyBytes.length] ^ nonce[i % nonce.length];
    }
    
    return utf8.decode(decrypted);
  }

  bool _constantTimeCompare(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Hash data using SHA-256
  String hashData(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  /// Sign data (simplified - use proper signing in production)
  String signData(String data, String privateKey) {
    final combined = '$data$privateKey';
    return sha256.convert(utf8.encode(combined)).toString();
  }

  /// Verify signature
  bool verifySignature(String data, String signature, String publicKey) {
    final expected = signData(data, publicKey);
    return signature == expected;
  }

  /// Get encryption statistics
  Map<String, dynamic> getStats() => {
    'algorithm': _algorithm.name,
    'peersWithKeys': _peerKeys.length,
    'hasKeyPair': _ownKeyPair != null,
  };

  void dispose() {
    _peerKeys.clear();
  }
}