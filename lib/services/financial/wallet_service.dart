import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/wallet_model.dart';

class WalletService {
  static const double _minBalance = 0.0;
  static const double _maxBalance = 1000000000.0; // 1 billion PINC
  static const double _withdrawalFee = 0.03; // 3%
  static const double _escrowFee = 0.09; // 9%
  
  WalletModel? _currentWallet;
  
  /// Initialize wallet for a user
  Future<WalletModel> initializeWallet(String pincoderId) async {
    // In production, this would load from blockchain/distributed storage
    _currentWallet = WalletModel(
      pincoderId: pincoderId,
      balance: 1000.0, // Initial test balance
    );
    return _currentWallet!;
  }
  
  /// Get current wallet
  WalletModel? get currentWallet => _currentWallet;
  
  /// Get wallet balance
  double get balance => _currentWallet?.balance ?? 0.0;
  
  /// Send PINC to another user (internal transfer - FREE)
  Future<Transaction> sendPinc({
    required String toPincoderId,
    required double amount,
    String? description,
  }) async {
    if (_currentWallet == null) {
      throw Exception('Wallet not initialized');
    }
    if (amount <= 0) {
      throw Exception('Amount must be positive');
    }
    if (_currentWallet!.balance < amount) {
      throw Exception('Insufficient balance');
    }
    
    final transaction = Transaction(
      id: _generateTransactionId(),
      type: 'send',
      amount: amount,
      toPincoderId: toPincoderId,
      description: description,
      status: TransactionStatus.completed,
    );
    
    // Update balance
    _currentWallet!.balance -= amount;
    _currentWallet!.transactions.add(transaction);
    
    // In production: broadcast to blockchain
    
    return transaction;
  }
  
  /// Receive PINC from another user
  Future<Transaction> receivePinc({
    required String fromPincoderId,
    required double amount,
    String? description,
  }) async {
    if (_currentWallet == null) {
      throw Exception('Wallet not initialized');
    }
    if (amount <= 0) {
      throw Exception('Amount must be positive');
    }
    
    final transaction = Transaction(
      id: _generateTransactionId(),
      type: 'receive',
      amount: amount,
      fromPincoderId: fromPincoderId,
      description: description,
      status: TransactionStatus.completed,
    );
    
    // Update balance
    _currentWallet!.balance += amount;
    _currentWallet!.transactions.add(transaction);
    
    return transaction;
  }
  
  /// Deposit funds (FREE - from crypto, PayPal, P2P agent)
  Future<Transaction> deposit({
    required double amount,
    required String source,
    String? details,
  }) async {
    if (_currentWallet == null) {
      throw Exception('Wallet not initialized');
    }
    if (amount <= 0) {
      throw Exception('Amount must be positive');
    }
    
    final transaction = Transaction(
      id: _generateTransactionId(),
      type: 'deposit',
      amount: amount,
      description: 'Deposit from $source: $details',
      status: TransactionStatus.completed,
    );
    
    _currentWallet!.balance += amount;
    _currentWallet!.transactions.add(transaction);
    
    return transaction;
  }
  
  /// Withdraw funds (3% fee)
  Future<Transaction> withdraw({
    required double amount,
    required String externalWallet,
  }) async {
    if (_currentWallet == null) {
      throw Exception('Wallet not initialized');
    }
    if (amount <= 0) {
      throw Exception('Amount must be positive');
    }
    
    final fee = amount * _withdrawalFee;
    final totalDeduction = amount + fee;
    
    if (_currentWallet!.balance < totalDeduction) {
      throw Exception('Insufficient balance. Need ${totalDeduction.toStringAsFixed(2)} (including ${fee.toStringAsFixed(2)} fee)');
    }
    
    final transaction = Transaction(
      id: _generateTransactionId(),
      type: 'withdraw',
      amount: amount,
      description: 'Withdrawal to: $externalWallet (Fee: ${fee.toStringAsFixed(2)})',
      status: TransactionStatus.pending, // Pending until confirmed
    );
    
    _currentWallet!.balance -= totalDeduction;
    _currentWallet!.transactions.add(transaction);
    
    return transaction;
  }
  
  /// Create escrow for job payment (9% fee)
  Future<Transaction> createEscrow({
    required double amount,
    required String jobId,
    required String employerId,
    required String freelancerId,
  }) async {
    if (_currentWallet == null) {
      throw Exception('Wallet not initialized');
    }
    if (amount <= 0) {
      throw Exception('Amount must be positive');
    }
    
    final fee = amount * _escrowFee;
    final total = amount + fee;
    
    if (_currentWallet!.balance < total) {
      throw Exception('Insufficient balance for escrow');
    }
    
    final transaction = Transaction(
      id: _generateTransactionId(),
      type: 'escrow',
      amount: amount,
      description: 'Escrow for job: $jobId (Fee: ${fee.toStringAsFixed(2)})',
      status: TransactionStatus.pending,
    );
    
    _currentWallet!.balance -= total;
    _currentWallet!.transactions.add(transaction);
    
    return transaction;
  }
  
  /// Release escrow to freelancer
  Future<Transaction> releaseEscrow(String transactionId) async {
    // In production: verify and release escrow
    // This would involve multi-signature or admin approval
    throw UnimplementedError('Escrow release requires blockchain consensus');
  }
  
  /// Get transaction history
  List<Transaction> getTransactionHistory() {
    return _currentWallet?.transactions.reversed.toList() ?? [];
  }
  
  /// Get transaction by ID
  Transaction? getTransaction(String id) {
    try {
      return _currentWallet?.transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Generate unique transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    final data = '$timestamp-$random-${_currentWallet?.pincoderId ?? "unknown"}';
    return md5.convert(utf8.encode(data)).toString().substring(0, 16);
  }
  
  /// Calculate withdrawal fee
  double calculateWithdrawalFee(double amount) => amount * _withdrawalFee;
  
  /// Calculate escrow fee
  double calculateEscrowFee(double amount) => amount * _escrowFee;
  
  /// Validate pincoder ID format
  static bool isValidPincoderId(String id) {
    // PINC ID format: PINC-XXXXXXXX (12 characters after prefix)
    final regex = RegExp(r'^PINC-[A-Z0-9]{8,12}$');
    return regex.hasMatch(id.toUpperCase());
  }
  
  /// Format balance for display
  static String formatBalance(double balance) {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K';
    }
    return balance.toStringAsFixed(2);
  }
  
  /// Generate QR code data for receiving
  String generateReceiveQR() {
    if (_currentWallet == null) return '';
    return 'PINC:${_currentWallet!.pincoderId}';
  }
  
  /// Parse QR code data
  static String? parseReceiveQR(String qrData) {
    if (qrData.startsWith('PINC:')) {
      return qrData.substring(5);
    }
    return null;
  }
}