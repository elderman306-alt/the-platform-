/// PINC Network - Fee Calculator
/// Phase 2: Financial Module

class FeeCalculator {
  // Fee Constants
  static const double withdrawalMinFee = 3.0;
  static const double withdrawalMaxFee = 103.0;
  static const double jobEscrowFee = 0.03; // 3%
  static const double jobPayoutFee = 0.09; // 9%
  static const double platformMonthlyFee = 325.0; // PINC/month
  static const double bettingFee = 0.07; // 7%
  static const double bettingCreatorFee = 0.05; // 5%
  static const double bettingMinWager = 20.0;
  static const double fundraisingFee = 0.09; // 9%
  static const double p2pAgentMinMargin = 0.04; // 4%
  static const double p2pAgentMaxMargin = 0.07; // 7%

  /// Calculate withdrawal fee (tiered)
  static double calculateWithdrawalFee(double amount) {
    if (amount <= 100) return 3.0;
    if (amount <= 500) return 10.0;
    if (amount <= 1000) return 25.0;
    if (amount <= 5000) return 50.0;
    if (amount <= 10000) return 75.0;
    return 103.0;
  }

  /// Calculate job escrow fee (3%)
  static double calculateJobEscrowFee(double amount) {
    return amount * jobEscrowFee;
  }

  /// Calculate job payout fee (9%)
  static double calculateJobPayoutFee(double amount) {
    return amount * jobPayoutFee;
  }

  /// Calculate betting fee (7%)
  static double calculateBettingFee(double wager) {
    return wager * bettingFee;
  }

  /// Calculate betting creator fee (5% of pool)
  static double calculateBettingCreatorFee(double poolSize) {
    return poolSize * bettingCreatorFee;
  }

  /// Calculate fundraising fee (9%)
  static double calculateFundraisingFee(double amount) {
    return amount * fundraisingFee;
  }

  /// Calculate P2P Agent margin
  static double calculateP2PAgentMargin(double amount) {
    // Agent earns 4-7% margin
    return amount * p2pAgentMinMargin; // Default 4%
  }

  /// Get total for withdrawal (amount + fee)
  static double getTotalWithdrawal(double amount) {
    return amount + calculateWithdrawalFee(amount);
  }

  /// Get total for job escrow (amount + fee)
  static double getTotalEscrow(double amount) {
    return amount + calculateJobEscrowFee(amount);
  }

  /// Get total for job payout (amount + fee)
  static double getTotalPayout(double amount) {
    return amount + calculateJobPayoutFee(amount);
  }

  /// Check if bet amount is valid
  static bool isValidBetAmount(double amount) {
    return amount >= bettingMinWager;
  }

  /// Format fee for display
  static String formatFee(double amount) {
    return '${amount.toStringAsFixed(2)} PINC';
  }

  /// Get fee description
  static String getFeeDescription(String type) {
    switch (type.toLowerCase()) {
      case 'withdrawal':
        return '3-103 PINC (tiered)';
      case 'escrow':
        return '3% of amount';
      case 'payout':
        return '9% of amount';
      case 'betting':
        return '7% of wager';
      case 'betting_creator':
        return '5% of pool';
      case 'fundraising':
        return '9% of raised';
      case 'p2p_agent':
        return '4-7% margin';
      case 'platform':
        return '325 PINC/month';
      default:
        return 'Unknown fee';
    }
  }
}

/// Fee tier structure for display
class FeeTier {
  final double minAmount;
  final double maxAmount;
  final double fee;

  const FeeTier({
    required this.minAmount,
    required this.maxAmount,
    required this.fee,
  });

  static const List<FeeTier> withdrawalTiers = [
    FeeTier(minAmount: 0, maxAmount: 100, fee: 3.0),
    FeeTier(minAmount: 100, maxAmount: 500, fee: 10.0),
    FeeTier(minAmount: 500, maxAmount: 1000, fee: 25.0),
    FeeTier(minAmount: 1000, maxAmount: 5000, fee: 50.0),
    FeeTier(minAmount: 5000, maxAmount: 10000, fee: 75.0),
    FeeTier(minAmount: 10000, maxAmount: double.infinity, fee: 103.0),
  ];
}