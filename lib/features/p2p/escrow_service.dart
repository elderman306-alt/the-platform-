import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Escrow transaction status
enum EscrowStatus {
  pending,
  funded,
  released,
  disputed,
  refunded,
  cancelled,
}

/// Escrow transaction
class EscrowTransaction {
  final String transactionId;
  final String buyerId;
  final String sellerId;
  final double amount;
  final String description;
  final EscrowStatus status;
  final DateTime createdAt;
  final DateTime? fundedAt;
  final DateTime? releasedAt;
  final String? releaseCode;
  final String? disputeReason;
  final List<String> disputeMessages;

  EscrowTransaction({
    required this.transactionId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.description,
    this.status = EscrowStatus.pending,
    DateTime? createdAt,
    this.fundedAt,
    this.releasedAt,
    this.releaseCode,
    this.disputeReason,
    this.disputeMessages = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'transactionId': transactionId,
    'buyerId': buyerId,
    'sellerId': sellerId,
    'amount': amount,
    'description': description,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'fundedAt': fundedAt?.toIso8601String(),
    'releasedAt': releasedAt?.toIso8601String(),
    'releaseCode': releaseCode,
    'disputeReason': disputeReason,
    'disputeMessages': disputeMessages,
  };

  factory EscrowTransaction.fromJson(Map<String, dynamic> json) => 
    EscrowTransaction(
      transactionId: json['transactionId'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      status: EscrowStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EscrowStatus.pending,
      ),
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String) 
        : DateTime.now(),
      fundedAt: json['fundedAt'] != null 
        ? DateTime.parse(json['fundedAt'] as String) 
        : null,
      releasedAt: json['releasedAt'] != null 
        ? DateTime.parse(json['releasedAt'] as String) 
        : null,
      releaseCode: json['releaseCode'] as String?,
      disputeReason: json['disputeReason'] as String?,
      disputeMessages: (json['disputeMessages'] as List?)?.cast<String>() ?? [],
    );

  EscrowTransaction copyWith({
    EscrowStatus? status,
    DateTime? fundedAt,
    DateTime? releasedAt,
    String? releaseCode,
    String? disputeReason,
    List<String>? disputeMessages,
  }) => EscrowTransaction(
    transactionId: transactionId,
    buyerId: buyerId,
    sellerId: sellerId,
    amount: amount,
    description: description,
    status: status ?? this.status,
    createdAt: createdAt,
    fundedAt: fundedAt ?? this.fundedAt,
    releasedAt: releasedAt ?? this.releasedAt,
    releaseCode: releaseCode ?? this.releaseCode,
    disputeReason: disputeReason ?? this.disputeReason,
    disputeMessages: disputeMessages ?? this.disputeMessages,
  );
}

/// Service for managing escrow transactions
class EscrowService {
  final Map<String, EscrowTransaction> _transactions = {};
  final _transactionController = StreamController<List<EscrowTransaction>>.broadcast();
  
  // Fee configuration
  static const double escrowFeePercent = 2.5;
  static const int releaseCodeLength = 8;
  static const int disputeWindowHours = 24;

  Stream<List<EscrowTransaction>> get transactionStream => _transactionController.stream;
  List<EscrowTransaction> get transactions => _transactions.values.toList();
  
  List<EscrowTransaction> get activeEscrows => 
    _transactions.values.where((t) => 
      t.status == EscrowStatus.pending || 
      t.status == EscrowStatus.funded
    ).toList();

  /// Generate transaction ID
  String generateTransactionId(String buyerId, String sellerId, double amount) {
    final input = '$buyerId-$sellerId-$amount-${DateTime.now().millisecondsSinceEpoch}';
    return sha256.convert(utf8.encode(input)).toString().substring(0, 12);
  }

  /// Generate release code
  String generateReleaseCode() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(releaseCodeLength, '0');
  }

  /// Create escrow transaction
  Future<EscrowTransaction> createEscrow({
    required String buyerId,
    required String sellerId,
    required double amount,
    required String description,
  }) async {
    final transactionId = generateTransactionId(buyerId, sellerId, amount);
    final releaseCode = generateReleaseCode();

    final transaction = EscrowTransaction(
      transactionId: transactionId,
      buyerId: buyerId,
      sellerId: sellerId,
      amount: amount,
      description: description,
      status: EscrowStatus.pending,
      releaseCode: releaseCode,
    );

    _transactions[transactionId] = transaction;
    _transactionController.add(transactions);

    debugPrint('Created escrow: $transactionId for $amount PINC');
    return transaction;
  }

  /// Fund escrow (buyer deposits funds)
  Future<EscrowTransaction?> fundEscrow(String transactionId) async {
    final transaction = _transactions[transactionId];
    if (transaction == null) return null;
    if (transaction.status != EscrowStatus.pending) {
      debugPrint('Escrow $transactionId already funded or closed');
      return null;
    }

    final funded = transaction.copyWith(
      status: EscrowStatus.funded,
      fundedAt: DateTime.now(),
    );

    _transactions[transactionId] = funded;
    _transactionController.add(transactions);

    debugPrint('Escrow funded: $transactionId');
    return funded;
  }

  /// Release escrow to seller
  Future<EscrowTransaction?> releaseEscrow(String transactionId, String releaseCode) async {
    final transaction = _transactions[transactionId];
    if (transaction == null) return null;
    if (transaction.status != EscrowStatus.funded) {
      debugPrint('Escrow $transactionId not in funded state');
      return null;
    }
    if (transaction.releaseCode != releaseCode) {
      debugPrint('Invalid release code for $transactionId');
      return null;
    }

    // Calculate fees
    final fee = (transaction.amount * escrowFeePercent / 100);
    final releasedAmount = transaction.amount - fee;

    final released = transaction.copyWith(
      status: EscrowStatus.released,
      releasedAt: DateTime.now(),
    );

    _transactions[transactionId] = released;
    _transactionController.add(transactions);

    debugPrint('Escrow released: $transactionId, Amount: $releasedAmount PINC, Fee: $fee PINC');
    return released;
  }

  /// Open dispute
  Future<EscrowTransaction?> openDispute(
    String transactionId, 
    String reason,
  ) async {
    final transaction = _transactions[transactionId];
    if (transaction == null) return null;
    if (transaction.status != EscrowStatus.funded) {
      debugPrint('Cannot dispute unfunded escrow');
      return null;
    }

    final disputed = transaction.copyWith(
      status: EscrowStatus.disputed,
      disputeReason: reason,
      disputeMessages: [reason],
    );

    _transactions[transactionId] = disputed;
    _transactionController.add(transactions);

    debugPrint('Dispute opened: $transactionId');
    return disputed;
  }

  /// Add dispute message
  Future<EscrowTransaction?> addDisputeMessage(
    String transactionId, 
    String message,
  ) async {
    final transaction = _transactions[transactionId];
    if (transaction == null) return null;
    if (transaction.status != EscrowStatus.disputed) return null;

    final updated = transaction.copyWith(
      disputeMessages: [...transaction.disputeMessages, message],
    );

    _transactions[transactionId] = updated;
    _transactionController.add(transactions);

    return updated;
  }

  /// Resolve dispute - refund to buyer
  Future<EscrowTransaction?> resolveDisputeRefund(String transactionId) async {
    final transaction = _transactions[transactionId];
    if (transaction == null) return null;
    if (transaction.status != EscrowStatus.disputed) return null;

    final refunded = transaction.copyWith(
      status: EscrowStatus.refunded,
    );

    _transactions[transactionId] = refunded;
    _transactionController.add(transactions);

    debugPrint('Dispute resolved - refund: $transactionId');
    return refunded;
  }

  /// Resolve dispute - release to seller
  Future<EscrowTransaction?> resolveDisputeRelease(String transactionId) async {
    final transaction = _transactions[transactionId];
    if (transaction == null) return null;
    if (transaction.status != EscrowStatus.disputed) return null;

    final released = transaction.copyWith(
      status: EscrowStatus.released,
      releasedAt: DateTime.now(),
    );

    _transactions[transactionId] = released;
    _transactionController.add(transactions);

    debugPrint('Dispute resolved - release: $transactionId');
    return released;
  }

  /// Cancel escrow
  Future<EscrowTransaction?> cancelEscrow(String transactionId) async {
    final transaction = _transactions[transactionId];
    if (transaction == null) return null;
    if (transaction.status != EscrowStatus.pending) {
      debugPrint('Cannot cancel non-pending escrow');
      return null;
    }

    final cancelled = transaction.copyWith(
      status: EscrowStatus.cancelled,
    );

    _transactions[transactionId] = cancelled;
    _transactionController.add(transactions);

    debugPrint('Escrow cancelled: $transactionId');
    return cancelled;
  }

  /// Get transaction by ID
  EscrowTransaction? getTransaction(String transactionId) => 
    _transactions[transactionId];

  /// Get escrow statistics
  Map<String, dynamic> getEscrowStats() => {
    'totalTransactions': _transactions.length,
    'activeEscrows': activeEscrows.length,
    'byStatus': {
      EscrowStatus.pending.name: _transactions.values.where((t) => t.status == EscrowStatus.pending).length,
      EscrowStatus.funded.name: _transactions.values.where((t) => t.status == EscrowStatus.funded).length,
      EscrowStatus.released.name: _transactions.values.where((t) => t.status == EscrowStatus.released).length,
      EscrowStatus.disputed.name: _transactions.values.where((t) => t.status == EscrowStatus.disputed).length,
      EscrowStatus.refunded.name: _transactions.values.where((t) => t.status == EscrowStatus.refunded).length,
      EscrowStatus.cancelled.name: _transactions.values.where((t) => t.status == EscrowStatus.cancelled).length,
    },
    'totalVolume': _transactions.values
      .where((t) => t.status == EscrowStatus.released || t.status == EscrowStatus.funded)
      .fold(0.0, (sum, t) => sum + t.amount),
    'totalFees': _transactions.values
      .where((t) => t.status == EscrowStatus.released)
      .fold(0.0, (sum, t) => sum + (t.amount * escrowFeePercent / 100)),
  };

  void dispose() {
    _transactionController.close();
  }
}