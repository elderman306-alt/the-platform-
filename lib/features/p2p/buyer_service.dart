import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Buyer tier levels
enum BuyerTier {
  guest,
  basic,
  premium,
}

/// Buyer status
enum BuyerStatus {
  active,
  suspended,
  banned,
}

/// Buyer profile data
class Buyer {
  final String buyerId;
  final String name;
  final String email;
  final BuyerTier tier;
  final BuyerStatus status;
  final double balance;
  final int totalPurchases;
  final double totalSpent;
  final DateTime joinedAt;
  final Map<String, dynamic> preferences;

  Buyer({
    required this.buyerId,
    required this.name,
    required this.email,
    this.tier = BuyerTier.guest,
    this.status = BuyerStatus.active,
    this.balance = 0.0,
    this.totalPurchases = 0,
    this.totalSpent = 0.0,
    DateTime? joinedAt,
    this.preferences = const {},
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'buyerId': buyerId,
    'name': name,
    'email': email,
    'tier': tier.name,
    'status': status.name,
    'balance': balance,
    'totalPurchases': totalPurchases,
    'totalSpent': totalSpent,
    'joinedAt': joinedAt.toIso8601String(),
    'preferences': preferences,
  };

  factory Buyer.fromJson(Map<String, dynamic> json) => Buyer(
    buyerId: json['buyerId'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    tier: BuyerTier.values.firstWhere(
      (e) => e.name == json['tier'],
      orElse: () => BuyerTier.guest,
    ),
    status: BuyerStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => BuyerStatus.active,
    ),
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    totalPurchases: json['totalPurchases'] as int? ?? 0,
    totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
    joinedAt: json['joinedAt'] != null 
      ? DateTime.parse(json['joinedAt'] as String) 
      : DateTime.now(),
    preferences: json['preferences'] as Map<String, dynamic>? ?? {},
  );

  Buyer copyWith({
    String? name,
    String? email,
    BuyerTier? tier,
    BuyerStatus? status,
    double? balance,
    int? totalPurchases,
    double? totalSpent,
    Map<String, dynamic>? preferences,
  }) => Buyer(
    buyerId: buyerId,
    name: name ?? this.name,
    email: email ?? this.email,
    tier: tier ?? this.tier,
    status: status ?? this.status,
    balance: balance ?? this.balance,
    totalPurchases: totalPurchases ?? this.totalPurchases,
    totalSpent: totalSpent ?? this.totalSpent,
    joinedAt: joinedAt,
    preferences: preferences ?? this.preferences,
  );
}

/// Purchase order status
enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
  refunded,
}

/// Purchase order
class PurchaseOrder {
  final String orderId;
  final String buyerId;
  final String sellerId;
  final String itemName;
  final double amount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  PurchaseOrder({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.itemName,
    required this.amount,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'buyerId': buyerId,
    'sellerId': sellerId,
    'itemName': itemName,
    'amount': amount,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
    orderId: json['orderId'] as String,
    buyerId: json['buyerId'] as String,
    sellerId: json['sellerId'] as String,
    itemName: json['itemName'] as String,
    amount: (json['amount'] as num).toDouble(),
    status: OrderStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => OrderStatus.pending,
    ),
    createdAt: json['createdAt'] != null 
      ? DateTime.parse(json['createdAt'] as String) 
      : DateTime.now(),
    completedAt: json['completedAt'] != null 
      ? DateTime.parse(json['completedAt'] as String) 
      : null,
  );
}

/// Service for managing buyers in the P2P mesh
class BuyerService {
  final Map<String, Buyer> _buyers = {};
  final Map<String, PurchaseOrder> _orders = {};
  final _buyerController = StreamController<List<Buyer>>.broadcast();
  final _orderController = StreamController<List<PurchaseOrder>>.broadcast();

  static const double guestDiscount = 0.0;
  static const double basicDiscount = 0.05;
  static const double premiumDiscount = 0.12;

  Stream<List<Buyer>> get buyerStream => _buyerController.stream;
  Stream<List<PurchaseOrder>> get orderStream => _orderController.stream;
  
  List<Buyer> get buyers => _buyers.values.toList();
  List<Buyer> get activeBuyers => 
    _buyers.values.where((b) => b.status == BuyerStatus.active).toList();
  List<PurchaseOrder> get orders => _orders.values.toList();

  /// Generate buyer ID
  String generateBuyerId(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final input = '$email-$timestamp';
    return sha256.convert(utf8.encode(input)).toString().substring(0, 12);
  }

  /// Register a new buyer
  Future<Buyer> registerBuyer({
    required String name,
    required String email,
    BuyerTier tier = BuyerTier.guest,
  }) async {
    final buyerId = generateBuyerId(email);
    
    final buyer = Buyer(
      buyerId: buyerId,
      name: name,
      email: email,
      tier: tier,
      status: BuyerStatus.active,
    );
    
    _buyers[buyerId] = buyer;
    _buyerController.add(activeBuyers);
    
    debugPrint('Registered buyer: $name (ID: $buyerId)');
    return buyer;
  }

  /// Get buyer by ID
  Buyer? getBuyer(String buyerId) => _buyers[buyerId];

  /// Update buyer balance
  Future<Buyer?> updateBalance(String buyerId, double amount) async {
    final buyer = _buyers[buyerId];
    if (buyer == null) return null;

    final updated = buyer.copyWith(balance: buyer.balance + amount);
    _buyers[buyerId] = updated;
    _buyerController.add(activeBuyers);
    
    return updated;
  }

  /// Create purchase order
  Future<PurchaseOrder?> createOrder({
    required String buyerId,
    required String sellerId,
    required String itemName,
    required double amount,
  }) async {
    final buyer = _buyers[buyerId];
    if (buyer == null) {
      debugPrint('Buyer not found: $buyerId');
      return null;
    }

    if (buyer.balance < amount) {
      debugPrint('Insufficient balance for buyer: $buyerId');
      return null;
    }

    final orderId = sha256.convert(
      utf8.encode('$buyerId-$sellerId-${DateTime.now().millisecondsSinceEpoch}')
    ).toString().substring(0, 12);

    final order = PurchaseOrder(
      orderId: orderId,
      buyerId: buyerId,
      sellerId: sellerId,
      itemName: itemName,
      amount: amount,
      status: OrderStatus.confirmed,
    );

    // Deduct from buyer balance
    _buyers[buyerId] = buyer.copyWith(
      balance: buyer.balance - amount,
      totalPurchases: buyer.totalPurchases + 1,
      totalSpent: buyer.totalSpent + amount,
    );

    _orders[orderId] = order;
    _orderController.add(orders);
    _buyerController.add(activeBuyers);
    
    debugPrint('Created order: $orderId for $amount PINC');
    return order;
  }

  /// Get buyer discount
  double getBuyerDiscount(BuyerTier tier) {
    switch (tier) {
      case BuyerTier.premium:
        return premiumDiscount;
      case BuyerTier.basic:
        return basicDiscount;
      case BuyerTier.guest:
        return guestDiscount;
    }
  }

  /// Calculate discounted price
  double calculatePrice(double originalPrice, BuyerTier tier) {
    final discount = getBuyerDiscount(tier);
    return originalPrice * (1 - discount);
  }

  /// Get buyer statistics
  Map<String, dynamic> getBuyerStats() => {
    'totalBuyers': _buyers.length,
    'activeBuyers': activeBuyers.length,
    'totalOrders': _orders.length,
    'byTier': {
      BuyerTier.guest.name: activeBuyers.where((b) => b.tier == BuyerTier.guest).length,
      BuyerTier.basic.name: activeBuyers.where((b) => b.tier == BuyerTier.basic).length,
      BuyerTier.premium.name: activeBuyers.where((b) => b.tier == BuyerTier.premium).length,
    },
    'totalVolume': _orders.fold(0.0, (sum, o) => sum + o.amount),
  };

  void dispose() {
    _buyerController.close();
    _orderController.close();
  }
}