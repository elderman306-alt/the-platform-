import '../../../domain/entities/financial_entities.dart';
import '../../../domain/usecases/fee_calculator.dart';

/// Transfer Service - P2P transfers, deposits, withdrawals
class TransferService {
  final List<P2PAgent> _agents = [];
  
  /// Find available P2P agents
  List<P2PAgent> findAgents({
    String? paymentMethod,
    double? minAmount,
    double? maxAmount,
  }) {
    return _agents.where((agent) {
      if (paymentMethod != null && agent.paymentMethod != paymentMethod) {
        return false;
      }
      if (minAmount != null && agent.minAmount > minAmount) {
        return false;
      }
      if (maxAmount != null && agent.maxAmount < maxAmount) {
        return false;
      }
      return agent.isActive;
    }).toList();
  }

  /// Get agent by ID
  P2PAgent? getAgent(String agentId) {
    try {
      return _agents.firstWhere((a) => a.id == agentId);
    } catch (_) {
      return null;
    }
  }

  /// Add P2P agent (for testing)
  void addTestAgent() {
    _agents.addAll([
      P2PAgent(
        id: 'AGENT-001',
        name: 'CryptoTrader',
        paymentMethod: 'crypto',
        margin: 0.05,
        minAmount: 50,
        maxAmount: 5000,
      ),
      P2PAgent(
        id: 'AGENT-002',
        name: 'PayPalPro',
        paymentMethod: 'paypal',
        margin: 0.06,
        minAmount: 20,
        maxAmount: 2000,
      ),
      P2PAgent(
        id: 'AGENT-003',
        name: 'BankMaster',
        paymentMethod: 'bank',
        margin: 0.04,
        minAmount: 100,
        maxAmount: 10000,
      ),
    ]);
  }

  /// Calculate exchange amount
  double calculateExchange({
    required double amount,
    required P2PAgent agent,
  }) {
    // Agent takes margin (4-7%)
    // User gets: amount - (amount * margin)
    return amount - (amount * agent.margin);
  }

  /// Validate PINC ID format
  static bool isValidPincId(String id) {
    return RegExp(r'^PINC-\d{8,12}$').hasMatch(id.toUpperCase());
  }

  /// Validate external wallet address
  static bool isValidWalletAddress(String address) {
    // Basic validation - in production would check blockchain specifics
    return address.length >= 20 && address.length <= 64;
  }

  /// Get transfer fee breakdown
  static Map<String, double> getTransferBreakdown({
    required double amount,
    required String type,
  }) {
    double fee = 0;
    String description = '';

    switch (type.toLowerCase()) {
      case 'internal':
        fee = 0;
        description = 'Internal transfers are FREE';
        break;
      case 'deposit':
        fee = 0;
        description = 'Deposits are FREE';
        break;
      case 'withdraw':
        fee = FeeCalculator.calculateWithdrawalFee(amount);
        description = 'Withdrawal fee (tiered)';
        break;
      case 'escrow':
        fee = FeeCalculator.calculateJobEscrowFee(amount);
        description = 'Job escrow fee (3%)';
        break;
      case 'payout':
        fee = FeeCalculator.calculateJobPayoutFee(amount);
        description = 'Job payout fee (9%)';
        break;
      case 'bet':
        fee = FeeCalculator.calculateBettingFee(amount);
        description = 'Betting fee (7%)';
        break;
      case 'fundraiser':
        fee = FeeCalculator.calculateFundraisingFee(amount);
        description = 'Fundraising fee (9%)';
        break;
    }

    return {
      'amount': amount,
      'fee': fee,
      'total': amount + fee,
      'description': description,
    };
  }

  /// Format amount for display
  static String formatPinc(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M PINC';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K PINC';
    }
    return '${amount.toStringAsFixed(2)} PINC';
  }

  /// Get fee summary
  static List<Map<String, String>> getFeeSummary() {
    return [
      {'type': 'Internal Transfer', 'fee': 'FREE', 'details': '0%'},
      {'type': 'Deposit', 'fee': 'FREE', 'details': '0%'},
      {'type': 'Withdraw', 'fee': '3-103 PINC', 'details': 'Tiered'},
      {'type': 'Job Escrow', 'fee': '3%', 'details': 'Employer pays'},
      {'type': 'Job Payout', 'fee': '9%', 'details': 'Freelancer pays'},
      {'type': 'Betting', 'fee': '7%', 'details': 'Min 20 PINC'},
      {'type': 'Betting Creator', 'fee': '5%', 'details': 'Of pool'},
      {'type': 'Fundraiser', 'fee': '9%', 'details': 'Of raised'},
      {'type': 'P2P Agent', 'fee': '4-7%', 'details': 'Margin'},
      {'type': 'Premium', 'fee': '325 PINC', 'details': '/month'},
    ];
  }
}