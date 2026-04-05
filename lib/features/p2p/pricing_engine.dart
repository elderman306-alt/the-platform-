/// Pricing Engine - Dynamic pricing for P2P bandwidth
class PricingEngine {
  // Base rates
  static const double baseRatePerMB = 0.01; // PINC per MB
  static const double baseRatePerMinute = 0.05; // PINC per minute
  
  // Regional multipliers
  static const Map<String, double> regionalRates = {
    'US': 1.0,
    'EU': 0.9,
    'ASIA': 0.8,
    'SA': 0.7,
    'AF': 0.6,
    'OC': 0.85,
  };

  // Time-based multipliers
  static const Map<String, double> timeMultipliers = {
    'peak': 1.5,    // 6PM-10PM
    'normal': 1.0,
    'offpeak': 0.7, // 12AM-6AM
  };

  /// Calculate dynamic price based on bandwidth, duration, region
  static double calculatePrice({
    required double bandwidthMB,
    required int durationMinutes,
    required String region,
    double demandFactor = 1.0,
  }) {
    // Get regional multiplier
    final regionalMultiplier = regionalRates[region] ?? 1.0;
    
    // Get time-based multiplier
    final timeMultiplier = _getTimeMultiplier();
    
    // Calculate base price
    final bandwidthCost = bandwidthMB * baseRatePerMB;
    final timeCost = durationMinutes * baseRatePerMinute;
    
    // Apply multipliers
    double total = (bandwidthCost + timeCost) * 
                  regionalMultiplier * 
                  timeMultiplier * 
                  demandFactor;
    
    return total;
  }

  /// Get current time period multiplier
  static double _getTimeMultiplier() {
    final hour = DateTime.now().hour;
    
    if (hour >= 18 && hour < 22) {
      return timeMultipliers['peak']!;
    } else if (hour >= 0 && hour < 6) {
      return timeMultipliers['offpeak']!;
    }
    return timeMultipliers['normal']!;
  }

  /// Get recommended price tier
  static PriceTier getRecommendedTier(double budget) {
    if (budget < 10) return PriceTier.basic;
    if (budget < 50) return PriceTier.standard;
    if (budget < 200) return PriceTier.premium;
    return PriceTier.enterprise;
  }

  /// Calculate discount for bulk purchases
  static double calculateBulkDiscount(int volumeMB) {
    if (volumeMB > 10000) return 0.25; // 25% off
    if (volumeMB > 5000) return 0.15;   // 15% off
    if (volumeMB > 1000) return 0.10;   // 10% off
    return 0.0;
  }
}

/// Price tiers
enum PriceTier {
  basic,
  standard,
  premium,
  enterprise,
}

extension PriceTierExtension on PriceTier {
  String get name {
    switch (this) {
      case PriceTier.basic:
        return 'Basic';
      case PriceTier.standard:
        return 'Standard';
      case PriceTier.premium:
        return 'Premium';
      case PriceTier.enterprise:
        return 'Enterprise';
    }
  }

  double get bandwidthLimit {
    switch (this) {
      case PriceTier.basic:
        return 1000;    // 1GB
      case PriceTier.standard:
        return 5000;    // 5GB
      case PriceTier.premium:
        return 50000;   // 50GB
      case PriceTier.enterprise:
        return double.infinity;
    }
  }

  double get priorityLevel {
    switch (this) {
      case PriceTier.basic:
        return 1.0;
      case PriceTier.standard:
        return 2.0;
      case PriceTier.premium:
        return 3.0;
      case PriceTier.enterprise:
        return 5.0;
    }
  }
}