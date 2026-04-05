import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Wallet Entity - Core financial entity
class Wallet {
  final String id; // PINC ID
  final double balance;
  final DateTime createdAt;
  final String? seedPhrase;
  final bool isPremium;

  Wallet({
    required this.id,
    this.balance = 1000.0,
    DateTime? createdAt,
    this.seedPhrase,
    this.isPremium = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Wallet copyWith({
    String? id,
    double? balance,
    DateTime? createdAt,
    String? seedPhrase,
    bool? isPremium,
  }) {
    return Wallet(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      seedPhrase: seedPhrase ?? this.seedPhrase,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'balance': balance,
    'createdAt': createdAt.toIso8601String(),
    'seedPhrase': seedPhrase,
    'isPremium': isPremium,
  };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'],
    balance: (json['balance'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
    seedPhrase: json['seedPhrase'],
    isPremium: json['isPremium'] ?? false,
  );
}

/// Transaction Entity
class FinancialTransaction {
  final String id;
  final String type; // send, receive, deposit, withdraw, escrow, bet, fundraising
  final double amount;
  final double fee;
  final String? toId;
  final String? fromId;
  final String? description;
  final DateTime timestamp;
  final TransactionStatus status;

  FinancialTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.fee = 0.0,
    this.toId,
    this.fromId,
    this.description,
    DateTime? timestamp,
    this.status = TransactionStatus.pending,
  }) : timestamp = timestamp ?? DateTime.now();

  double get totalAmount => amount + fee;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'fee': fee,
    'toId': toId,
    'fromId': fromId,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
  };

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) =>
    FinancialTransaction(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      toId: json['toId'],
      fromId: json['fromId'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
    );
}

enum TransactionStatus { pending, processing, completed, failed, cancelled }

/// Bet Entity
class Bet {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final double wagerAmount;
  final double poolSize;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final BetStatus status;
  final List<BetOption> options;

  Bet({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description = '',
    required this.wagerAmount,
    this.poolSize = 0.0,
    DateTime? createdAt,
    this.expiresAt,
    this.status = BetStatus.active,
    this.options = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'creatorId': creatorId,
    'title': title,
    'description': description,
    'wagerAmount': wagerAmount,
    'poolSize': poolSize,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'status': status.name,
    'options': options.map((o) => o.toJson()).toList(),
  };

  factory Bet.fromJson(Map<String, dynamic> json) => Bet(
    id: json['id'],
    creatorId: json['creatorId'],
    title: json['title'],
    description: json['description'] ?? '',
    wagerAmount: (json['wagerAmount'] as num).toDouble(),
    poolSize: (json['poolSize'] as num?)?.toDouble() ?? 0.0,
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    status: BetStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => BetStatus.active,
    ),
    options: (json['options'] as List?)?.map((o) => BetOption.fromJson(o)).toList() ?? [],
  );
}

class BetOption {
  final String id;
  final String name;
  final double totalWagered;
  final int participantCount;

  BetOption({
    required this.id,
    required this.name,
    this.totalWagered = 0.0,
    this.participantCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalWagered': totalWagered,
    'participantCount': participantCount,
  };

  factory BetOption.fromJson(Map<String, dynamic> json) => BetOption(
    id: json['id'],
    name: json['name'],
    totalWagered: (json['totalWagered'] as num?)?.toDouble() ?? 0.0,
    participantCount: json['participantCount'] ?? 0,
  );
}

enum BetStatus { active, closed, settled, cancelled }

/// Fundraiser Entity
class Fundraiser {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final double targetAmount;
  final double raisedAmount;
  final DateTime createdAt;
  final DateTime? deadline;
  final FundraiserStatus status;

  Fundraiser({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description = '',
    required this.targetAmount,
    this.raisedAmount = 0.0,
    DateTime? createdAt,
    this.deadline,
    this.status = FundraiserStatus.active,
  }) : createdAt = createdAt ?? DateTime.now();

  double get percentage => (raisedAmount / targetAmount) * 100;

  Map<String, dynamic> toJson() => {
    'id': id,
    'creatorId': creatorId,
    'title': title,
    'description': description,
    'targetAmount': targetAmount,
    'raisedAmount': raisedAmount,
    'createdAt': createdAt.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'status': status.name,
  };

  factory Fundraiser.fromJson(Map<String, dynamic> json) => Fundraiser(
    id: json['id'],
    creatorId: json['creatorId'],
    title: json['title'],
    description: json['description'] ?? '',
    targetAmount: (json['targetAmount'] as num).toDouble(),
    raisedAmount: (json['raisedAmount'] as num?)?.toDouble() ?? 0.0,
    createdAt: DateTime.parse(json['createdAt']),
    deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    status: FundraiserStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => FundraiserStatus.active,
    ),
  );
}

enum FundraiserStatus { active, completed, cancelled, expired }

/// P2P Agent Entity
class P2PAgent {
  final String id;
  final String name;
  final String paymentMethod; // crypto, paypal, bank
  final double margin; // 4-7%
  final double minAmount;
  final double maxAmount;
  final bool isActive;
  final double rating;
  final int tradesCompleted;

  P2PAgent({
    required this.id,
    required this.name,
    required this.paymentMethod,
    this.margin = 0.05,
    this.minAmount = 10.0,
    this.maxAmount = 10000.0,
    this.isActive = true,
    this.rating = 5.0,
    this.tradesCompleted = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'paymentMethod': paymentMethod,
    'margin': margin,
    'minAmount': minAmount,
    'maxAmount': maxAmount,
    'isActive': isActive,
    'rating': rating,
    'tradesCompleted': tradesCompleted,
  };

  factory P2PAgent.fromJson(Map<String, dynamic> json) => P2PAgent(
    id: json['id'],
    name: json['name'],
    paymentMethod: json['paymentMethod'],
    margin: (json['margin'] as num?)?.toDouble() ?? 0.05,
    minAmount: (json['minAmount'] as num?)?.toDouble() ?? 10.0,
    maxAmount: (json['maxAmount'] as num?)?.toDouble() ?? 10000.0,
    isActive: json['isActive'] ?? true,
    rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    tradesCompleted: json['tradesCompleted'] ?? 0,
  );
}