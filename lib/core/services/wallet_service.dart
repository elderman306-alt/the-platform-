// Wallet Service - PINC Coin Management
// THE PLATFORM - PINC Network

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import 'encryption_service.dart';

class WalletService {
  static const _storage = FlutterSecureStorage();
  
  // Wallet State
  static String _pincId = '';
  static double _balance = 0.0;
  static int _securityLevel = 0;
  static bool _hasPin = false;
  static bool _hasBiometric = false;
  static List<Map<String, dynamic>> _transactions = [];
  static String _seedPhrase = '';
  
  // Getters
  static String get pincId => _pincId;
  static double get balance => _balance;
  static int get securityLevel => _securityLevel;
  static bool get hasPin => _hasPin;
  static bool get hasBiometric => _hasBiometric;
  static List<Map<String, dynamic>> get transactions => _transactions;
  
  /// Initialize Wallet
  static Future<void> load() async {
    _pincId = await _storage.read(key: 'pinc_id') ?? '';
    _balance = double.tryParse(await _storage.read(key: 'balance') ?? '0') ?? 0;
    _securityLevel = int.tryParse(await _storage.read(key: 'security_level') ?? '0') ?? 0;
    _hasPin = await _storage.read(key: 'has_pin') == 'true';
    _hasBiometric = await _storage.read(key: 'has_biometric') == 'true';
    _seedPhrase = await _storage.read(key: 'seed_phrase') ?? '';
    
    // Load transactions
    final txData = await _storage.read(key: 'transactions');
    if (txData != null) {
      // Parse transactions
    }
  }
  
  /// Create New Wallet
  static Future<void> createWallet() async {
    // Generate PINC ID
    _pincId = 'PINC-${_generateId()}';
    
    // Generate 15-word seed phrase
    _seedPhrase = _generateSeedPhrase();
    
    // Save
    await _storage.write(key: 'pinc_id', value: _pincId);
    await _storage.write(key: 'seed_phrase', value: _seedPhrase);
    await _storage.write(key: 'balance', value: '0');
    await _storage.write(key: 'security_level', value: '0');
  }
  
  /// Send PINC
  static Future<bool> send(String toAddress, double amount) async {
    if (amount <= 0) return false;
    if (_balance < amount) return false;
    
    // Calculate fee
    final fee = _calculateFee(amount, 'transfer');
    final total = amount + fee;
    
    if (_balance < total) return false;
    
    // Deduct balance
    _balance -= total;
    
    // Create transaction
    final tx = {
      'id': EncryptionService.hashTransaction(DateTime.now().toIso8601String()),
      'type': 'sent',
      'to': toAddress,
      'amount': amount,
      'fee': fee,
      'time': DateTime.now().toIso8601String(),
      'status': 'pending',
    };
    
    _transactions.insert(0, tx);
    await _saveTransactions();
    await _storage.write(key: 'balance', value: _balance.toString());
    
    return true;
  }
  
  /// Receive PINC
  static Future<void> receive(String fromAddress, double amount) async {
    _balance += amount;
    
    final tx = {
      'id': EncryptionService.hashTransaction(DateTime.now().toIso8601String()),
      'type': 'received',
      'from': fromAddress,
      'amount': amount,
      'fee': 0,
      'time': DateTime.now().toIso8601String(),
      'status': 'confirmed',
    };
    
    _transactions.insert(0, tx);
    await _saveTransactions();
    await _storage.write(key: 'balance', value: _balance.toString());
  }
  
  /// Calculate Fee
  static double _calculateFee(double amount, String type) {
    switch (type) {
      case 'transfer':
        return AppConfig.internalTransferFee;
      case 'withdrawal':
        return AppConfig.withdrawalFee;
      case 'job_escrow':
        return amount * AppConfig.jobEscrowFee;
      case 'job_payout':
        return amount * AppConfig.jobPayoutFee;
      case 'betting':
        return amount * AppConfig.bettingFee;
      default:
        return 0;
    }
  }
  
  /// Get Fee Summary
  static Map<String, double> getFeeSummary() {
    return {
      'internal_transfer': AppConfig.internalTransferFee,
      'deposit': AppConfig.depositFee,
      'withdrawal': AppConfig.withdrawalFee,
      'job_escrow': AppConfig.jobEscrowFee * 100,
      'job_payout': AppConfig.jobPayoutFee * 100,
      'betting': AppConfig.bettingFee * 100,
      'betting_creator': AppConfig.bettingCreatorFee * 100,
    };
  }
  
  /// Set Security Level
  static Future<void> setSecurityLevel(int level) async {
    _securityLevel = level;
    await _storage.write(key: 'security_level', value: level.toString());
  }
  
  /// Enable PIN
  static Future<void> enablePin(String pin) async {
    final hashed = EncryptionService.sha3256(pin);
    await _storage.write(key: 'pin_hash', value: hashed);
    _hasPin = true;
    await _storage.write(key: 'has_pin', value: 'true');
    await setSecurityLevel(1);
  }
  
  /// Verify PIN
  static Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: 'pin_hash');
    return stored == EncryptionService.sha3256(pin);
  }
  
  /// Enable Biometric
  static Future<void> enableBiometric() async {
    _hasBiometric = true;
    await _storage.write(key: 'has_biometric', value: 'true');
    await setSecurityLevel(3);
  }
  
  /// Generate PINC ID
  static String _generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hash = EncryptionService.sha3256(now.toString());
    return hash.substring(0, 8).toUpperCase();
  }
  
  /// Generate 15-word Seed Phrase
  static String _generateSeedPhrase() {
    final words = [
      'abandon', 'ability', 'able', 'about', 'above', 'absent', 'absorb', 'abstract',
      'absurd', 'abuse', 'access', 'accident', 'account', 'accuse', 'achieve', 'acid',
      'acoustic', 'acquire', 'across', 'act', 'action', 'actor', 'actress', 'actual',
      'adapt', 'add', 'addict', 'address', 'adjust', 'admit', 'adult', 'advance',
      'advice', 'aerobic', 'affair', 'afford', 'afraid', 'again', 'age', 'agent',
      'agree', 'ahead', 'aim', 'air', 'airport', 'aisle', 'alarm', 'album',
    ];
    
    final phrase = List.generate(15, (i) => words[DateTime.now().microsecond % words.length]);
    return phrase.join(' ');
  }
  
  /// Save Transactions
  static Future<void> _saveTransactions() async {
    // Prune old transactions (older than 1 year)
    final cutoff = DateTime.now().subtract(Duration(days: AppConfig.transactionExpiryDays));
    _transactions.removeWhere((tx) {
      final time = DateTime.tryParse(tx['time'] ?? '');
      return time != null && time.isBefore(cutoff);
    });
  }
  
  /// Get Transaction History
  static List<Map<String, dynamic>> getTransactionHistory() {
    return _transactions;
  }
}