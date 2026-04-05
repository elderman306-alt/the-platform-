class WalletModel {
  final String pincodeId;
  double balance;
  List<Transaction> transactions;
  final DateTime createdAt;
  
  WalletModel({
    required this.pincoderId,
    this.balance = 0.0,
    List<Transaction>? transactions,
    DateTime? createdAt,
  })  : transactions = transactions ?? [],
        createdAt = createdAt ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'pincoderId': pincoderId,
    'balance': balance,
    'transactions': transactions.map((t) => t.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    pincodeId: json['pincoderId'],
    balance: (json['balance'] as num).toDouble(),
    transactions: (json['transactions'] as List?)
        ?.map((t) => Transaction.fromJson(t))
        .toList() ?? [],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class Transaction {
  final String id;
  final String type; // send, receive, deposit, withdraw, escrow
  final double amount;
  final String? toPincoderId;
  final String? fromPincoderId;
  final String? description;
  final DateTime timestamp;
  final TransactionStatus status;
  
  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.toPincoderId,
    this.fromPincoderId,
    this.description,
    DateTime? timestamp,
    this.status = TransactionStatus.pending,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'toPincoderId': toPincoderId,
    'fromPincoderId': fromPincoderId,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
  };
  
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    type: json['type'],
    amount: (json['amount'] as num).toDouble(),
    toPincoderId: json['toPincoderId'],
    fromPincoderId: json['fromPincoderId'],
    description: json['description'],
    timestamp: DateTime.parse(json['timestamp']),
    status: TransactionStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => TransactionStatus.pending,
    ),
  );
}

enum TransactionStatus { pending, completed, failed }

enum TransactionType { send, receive, deposit, withdraw, escrow }