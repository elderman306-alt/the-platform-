import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Seller tier levels
enum SellerTier {
  basic,
  standard,
  premium,
}

/// Seller status
enum SellerStatus {
  pending,
  active,
  suspended,
  removed,
}

/// Seller profile data
class Seller {
  final String sellerId;
  final String name;
  final String description;
  final SellerTier tier;
  final SellerStatus status;
  final double rating;
  final int totalSales;
  final double monthlyFee;
  final DateTime joinedAt;
  final Map<String, dynamic> metadata;

  Seller({
    required this.sellerId,
    required this.name,
    this.description = '',
    this.tier = SellerTier.basic,
    this.status = SellerStatus.pending,
    this.rating = 0.0,
    this.totalSales = 0,
    this.monthlyFee = 435.0,
    DateTime? joinedAt,
    this.metadata = const {},
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'sellerId': sellerId,
    'name': name,
    'description': description,
    'tier': tier.name,
    'status': status.name,
    'rating': rating,
    'totalSales': totalSales,
    'monthlyFee': monthlyFee,
    'joinedAt': joinedAt.toIso8601String(),
    'metadata': metadata,
  };

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
    sellerId: json['sellerId'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    tier: SellerTier.values.firstWhere(
      (e) => e.name == json['tier'],
      orElse: () => SellerTier.basic,
    ),
    status: SellerStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => SellerStatus.pending,
    ),
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    totalSales: json['totalSales'] as int? ?? 0,
    monthlyFee: (json['monthlyFee'] as num?)?.toDouble() ?? 435.0,
    joinedAt: json['joinedAt'] != null 
      ? DateTime.parse(json['joinedAt'] as String) 
      : DateTime.now(),
    metadata: json['metadata'] as Map<String, dynamic>? ?? {},
  );

  Seller copyWith({
    String? name,
    String? description,
    SellerTier? tier,
    SellerStatus? status,
    double? rating,
    int? totalSales,
    double? monthlyFee,
    Map<String, dynamic>? metadata,
  }) => Seller(
    sellerId: sellerId,
    name: name ?? this.name,
    description: description ?? this.description,
    tier: tier ?? this.tier,
    status: status ?? this.status,
    rating: rating ?? this.rating,
    totalSales: totalSales ?? this.totalSales,
    monthlyFee: monthlyFee ?? this.monthlyFee,
    joinedAt: joinedAt,
    metadata: metadata ?? this.metadata,
  );
}

/// Service for managing sellers in the P2P mesh
class SellerService {
  final Map<String, Seller> _sellers = {};
  final _sellerController = StreamController<List<Seller>>.broadcast();
  
  static const double defaultMonthlyFee = 435.0;
  static const double premiumDiscount = 0.15;
  static const double standardDiscount = 0.08;

  Stream<List<Seller>> get sellerStream => _sellerController.stream;
  List<Seller> get sellers => _sellers.values.toList();
  List<Seller> get activeSellers => 
    _sellers.values.where((s) => s.status == SellerStatus.active).toList();

  /// Generate seller ID
  String generateSellerId(String name) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final input = '$name-$timestamp';
    return sha256.convert(utf8.encode(input)).toString().substring(0, 12);
  }

  /// Register a new seller
  Future<Seller> registerSeller({
    required String name,
    String description = '',
    SellerTier tier = SellerTier.basic,
  }) async {
    final sellerId = generateSellerId(name);
    final monthlyFee = _calculateFee(tier);
    
    final seller = Seller(
      sellerId: sellerId,
      name: name,
      description: description,
      tier: tier,
      status: SellerStatus.active,
      monthlyFee: monthlyFee,
    );
    
    _sellers[sellerId] = seller;
    _sellerController.add(activeSellers);
    
    debugPrint('Registered seller: $name (ID: $sellerId, Fee: $monthlyFee PINC/month)');
    return seller;
  }

  double _calculateFee(SellerTier tier) {
    switch (tier) {
      case SellerTier.premium:
        return defaultMonthlyFee * (1 - premiumDiscount);
      case SellerTier.standard:
        return defaultMonthlyFee * (1 - standardDiscount);
      case SellerTier.basic:
        return defaultMonthlyFee;
    }
  }

  /// Update seller tier
  Future<Seller?> updateTier(String sellerId, SellerTier newTier) async {
    final seller = _sellers[sellerId];
    if (seller == null) return null;

    final updated = seller.copyWith(
      tier: newTier,
      monthlyFee: _calculateFee(newTier),
    );
    _sellers[sellerId] = updated;
    _sellerController.add(activeSellers);
    
    return updated;
  }

  /// Get seller by ID
  Seller? getSeller(String sellerId) => _sellers[sellerId];

  /// Suspend seller
  Future<bool> suspendSeller(String sellerId) async {
    final seller = _sellers[sellerId];
    if (seller == null) return false;

    _sellers[sellerId] = seller.copyWith(status: SellerStatus.suspended);
    _sellerController.add(activeSellers);
    return true;
  }

  /// Remove seller
  Future<bool> removeSeller(String sellerId) async {
    final seller = _sellers[sellerId];
    if (seller == null) return false;

    _sellers[sellerId] = seller.copyWith(status: SellerStatus.removed);
    _sellerController.add(activeSellers);
    return true;
  }

  /// Get sellers by tier
  List<Seller> getSellersByTier(SellerTier tier) =>
    activeSellers.where((s) => s.tier == tier).toList();

  /// Get seller statistics
  Map<String, dynamic> getSellerStats() => {
    'totalSellers': _sellers.length,
    'activeSellers': activeSellers.length,
    'byTier': {
      SellerTier.basic.name: activeSellers.where((s) => s.tier == SellerTier.basic).length,
      SellerTier.standard.name: activeSellers.where((s) => s.tier == SellerTier.standard).length,
      SellerTier.premium.name: activeSellers.where((s) => s.tier == SellerTier.premium).length,
    },
    'averageRating': _calculateAverageRating(),
    'totalMonthlyRevenue': _calculateMonthlyRevenue(),
  };

  double _calculateAverageRating() {
    if (activeSellers.isEmpty) return 0.0;
    final total = activeSellers.fold(0.0, (sum, s) => sum + s.rating);
    return total / activeSellers.length;
  }

  double _calculateMonthlyRevenue() {
    return activeSellers.fold(0.0, (sum, s) => sum + s.monthlyFee);
  }

  void dispose() {
    _sellerController.close();
  }
}