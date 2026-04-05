// 🔷 THE PLATFORM - Auth Service
// PIN, Pattern, Biometric, and Private Key authentication

import 'dart:math';
import 'package:the_platform-/core/constants.dart';

/// ==========================================
/// AUTH SERVICE
/// ==========================================

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  int _pinAttempts = 0;
  int _patternAttempts = 0;
  DateTime? _pinLockedUntil;
  DateTime? _patternLockedUntil;

  /// ==========================================
  /// PIN AUTHENTICATION
  /// ==========================================

  /// Verify PIN
  AuthResult verifyPin(String inputPin, String storedPin) {
    // Check if locked
    if (_pinLockedUntil != null && DateTime.now().isBefore(_pinLockedUntil!)) {
      final remaining = _pinLockedUntil!.difference(DateTime.now());
      return AuthResult(
        success: false,
        error: AuthError.locked,
        message: 'Locked for ${remaining.inMinutes} minutes',
      );
    }

    // Verify PIN
    if (inputPin == storedPin) {
      _pinAttempts = 0;
      return AuthResult(success: true, message: 'PIN verified');
    }

    // Invalid PIN
    _pinAttempts++;
    if (_pinAttempts >= PinConstants.pinAttemptsMax) {
      _pinLockedUntil =
          DateTime.now().add(PinConstants.pinLockoutDuration);
      _pinAttempts = 0;
      return AuthResult(
        success: false,
        error: AuthError.locked,
        message: 'Too many attempts. Locked for ${PinConstants.pinLockoutDuration.inMinutes} minutes',
      );
    }

    final remaining = PinConstants.pinAttemptsMax - _pinAttempts;
    return AuthResult(
      success: false,
      error: AuthError.invalidPin,
      message: 'Invalid PIN. $remaining attempts remaining',
    );
  }

  /// Create hashed PIN storage
  String hashPin(String pin) {
    // Simple hash for demonstration
    // In production, use proper crypto (bcrypt, argon2)
    var hash = 0;
    for (int i = 0; i < pin.length; i++) {
      hash = ((hash << 5) - hash) + pin.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  /// Validate PIN format
  bool isValidPinFormat(String pin) {
    if (pin.length < PinConstants.minPinLength ||
        pin.length > PinConstants.maxPinLength) {
      return false;
    }
    return RegExp(r'^\d+$').hasMatch(pin);
  }

  /// Generate random PIN (for testing)
  String generatePin() {
    final random = Random.secure();
    final buffer = StringBuffer();
    for (int i = 0; i < PinConstants.pinLength; i++) {
      buffer.write(random.nextInt(10));
    }
    return buffer.toString();
  }

  /// ==========================================
  /// PATTERN LOCK
  /// ==========================================

  /// Verify pattern
  AuthResult verifyPattern(List<int> inputPattern, List<int> storedPattern) {
    // Check if locked
    if (_patternLockedUntil != null &&
        DateTime.now().isBefore(_patternLockedUntil!)) {
      final remaining = _patternLockedUntil!.difference(DateTime.now());
      return AuthResult(
        success: false,
        error: AuthError.locked,
        message: 'Locked for ${remaining.inMinutes} minutes',
      );
    }

    // Verify pattern (must match exactly)
    if (inputPattern.length != storedPattern.length) {
      return _handlePatternAttempt();
    }

    for (int i = 0; i < inputPattern.length; i++) {
      if (inputPattern[i] != storedPattern[i]) {
        return _handlePatternAttempt();
      }
    }

    _patternAttempts = 0;
    return AuthResult(success: true, message: 'Pattern verified');
  }

  AuthResult _handlePatternAttempt() {
    _patternAttempts++;
    if (_patternAttempts >= PatternConstants.patternAttemptsMax) {
      _patternLockedUntil = DateTime.now().add(Duration(minutes: 5));
      _patternAttempts = 0;
      return AuthResult(
        success: false,
        error: AuthError.locked,
        message: 'Too many attempts. Locked for 5 minutes',
      );
    }

    final remaining = PatternConstants.patternAttemptsMax - _patternAttempts;
    return AuthResult(
      success: false,
      error: AuthError.invalidPattern,
      message: 'Invalid pattern. $remaining attempts remaining',
    );
  }

  /// Validate pattern
  bool isValidPattern(List<int> pattern) {
    if (pattern.length < PatternConstants.minPatternLength ||
        pattern.length > PatternConstants.maxPatternLength) {
      return false;
    }

    // Check all points are valid (0-24 for 5x5 grid)
    for (final point in pattern) {
      if (point < 0 || point >= PatternConstants.gridSize * PatternConstants.gridSize) {
        return false;
      }
    }

    return true;
  }

  /// Generate random pattern (for testing)
  List<int> generatePattern() {
    final random = Random.secure();
    final length =
        PatternConstants.minPatternLength + random.nextInt(
          PatternConstants.maxPatternLength - PatternConstants.minPatternLength + 1
        );

    final pattern = <int>{};
    while (pattern.length < length) {
      pattern.add(random.nextInt(PatternConstants.gridSize * PatternConstants.gridSize));
    }

    return pattern.toList();
  }

  /// ==========================================
  /// BIOMETRIC AUTHENTICATION
  /// ==========================================

  /// Check if biometric is available
  Future<bool> isBiometricAvailable() async {
    // In production, use local_auth package
    return false;
  }

  /// Authenticate with biometric
  Future<AuthResult> authenticateWithBiometric() async {
    final available = await isBiometricAvailable();
    if (!available) {
      return AuthResult(
        success: false,
        error: AuthError.biometricNotAvailable,
        message: 'Biometric not available on this device',
      );
    }

    // In production, prompt biometric
    return AuthResult(success: true, message: 'Biometric verified');
  }

  /// ==========================================
  /// PRIVATE KEY SIGNING
  /// ==========================================

  /// Sign transaction with private key
  Future<String> signTransaction({
    required String privateKey,
    required int amount,
    required String recipient,
  }) async {
    // Simple signature for demonstration
    // In production, use proper ECDSA
    final message = '$amount:$recipient:${DateTime.now().millisecondsSinceEpoch}';
    return _simpleSign(message, privateKey);
  }

  /// Verify signature
  bool verifySignature({
    required String signature,
    required int amount,
    required String recipient,
    required String publicKey,
  }) {
    // In production, verify ECDSA signature
    return signature.isNotEmpty && signature.length > 10;
  }

  /// Generate key pair
  KeyPair generateKeyPair() {
    final random = Random.secure();
    final chars = 'ABCDEF0123456789';

    final privateKey = StringBuffer();
    final publicKey = StringBuffer();

    for (int i = 0; i < 64; i++) {
      privateKey.write(chars[random.nextInt(chars.length)]);
      if (i < 32) {
        publicKey.write(chars[random.nextInt(chars.length)]);
      }
    }

    return KeyPair(
      privateKey: privateKey.toString(),
      publicKey: publicKey.toString(),
    );
  }

  String _simpleSign(String message, String privateKey) {
    var hash = 0;
    final combined = '$message:$privateKey';
    for (int i = 0; i < combined.length; i++) {
      hash = ((hash << 5) - hash) + combined.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return '${hash.toRadixString(16)}:${DateTime.now().millisecondsSinceEpoch}';
  }

  /// ==========================================
  /// TRANSACTION AUTH LEVEL
  /// ==========================================

  /// Get required auth level for transaction
  AuthLevel getRequiredAuthLevel(int amount) {
    if (amount < TransactionThresholds.pinMaxAmount) {
      return AuthLevel.pin;
    } else if (amount < TransactionThresholds.patternMaxAmount) {
      return AuthLevel.pattern;
    } else {
      return AuthLevel.privateKey;
    }
  }

  /// Check if auth is sufficient for amount
  bool isAuthSufficient(AuthLevel level, int amount) {
    final required = getRequiredAuthLevel(amount);
    return level.index >= required.index;
  }
}

/// ==========================================
/// AUTH RESULT
/// ==========================================

class AuthResult {
  final bool success;
  final AuthError? error;
  final String message;

  const AuthResult({
    required this.success,
    this.error,
    required this.message,
  });
}

enum AuthError {
  invalidPin,
  invalidPattern,
  locked,
  biometricNotAvailable,
  privateKeyRequired,
}

/// ==========================================
/// AUTH LEVEL
/// ==========================================

enum AuthLevel {
  none,
  pin,
  pattern,
  biometric,
  privateKey,
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