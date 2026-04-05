import '../../../domain/entities/financial_entities.dart';
import '../../../domain/usecases/fee_calculator.dart';

/// Bet Service - Betting and wagers system
class BetService {
  final List<Bet> _activeBets = [];
  final List<Bet> _settledBets = [];

  /// Create a new bet - 7% fee, min 20 PINC
  Future<Bet> createBet({
    required String creatorId,
    required String title,
    String? description,
    required double wagerAmount,
    required List<String> options,
    DateTime? expiresAt,
  }) async {
    // Validate
    if (!FeeCalculator.isValidBetAmount(wagerAmount)) {
      throw Exception('Minimum wager is ${FeeCalculator.bettingMinWager} PINC');
    }
    if (options.length < 2) {
      throw Exception('Bet must have at least 2 options');
    }

    final fee = FeeCalculator.calculateBettingFee(wagerAmount);

    final bet = Bet(
      id: _generateBetId(),
      creatorId: creatorId,
      title: title,
      description: description ?? '',
      wagerAmount: wagerAmount,
      poolSize: wagerAmount + fee,
      expiresAt: expiresAt,
      status: BetStatus.active,
      options: options.asMap().entries.map((e) => BetOption(
        id: _generateOptionId(),
        name: e.value,
        totalWagered: e.key == 0 ? wagerAmount : 0, // Creator bets on first option
        participantCount: 1,
      )).toList(),
    );

    _activeBets.add(bet);
    return bet;
  }

  /// Join an existing bet
  Future<void> joinBet({
    required String betId,
    required String userId,
    required String optionId,
    required double amount,
  }) async {
    if (!FeeCalculator.isValidBetAmount(amount)) {
      throw Exception('Minimum wager is ${FeeCalculator.bettingMinWager} PINC');
    }

    final betIndex = _activeBets.indexWhere((b) => b.id == betId);
    if (betIndex == -1) {
      throw Exception('Bet not found');
    }

    final bet = _activeBets[betIndex];
    if (bet.status != BetStatus.active) {
      throw Exception('Bet is no longer active');
    }

    // Update option
    final updatedOptions = bet.options.map((opt) {
      if (opt.id == optionId) {
        return BetOption(
          id: opt.id,
          name: opt.name,
          totalWagered: opt.totalWagered + amount,
          participantCount: opt.participantCount + 1,
        );
      }
      return opt;
    }).toList();

    // Update pool
    final fee = FeeCalculator.calculateBettingFee(amount);
    final updatedBet = Bet(
      id: bet.id,
      creatorId: bet.creatorId,
      title: bet.title,
      description: bet.description,
      wagerAmount: bet.wagerAmount,
      poolSize: bet.poolSize + amount + fee,
      createdAt: bet.createdAt,
      expiresAt: bet.expiresAt,
      status: bet.status,
      options: updatedOptions,
    );

    _activeBets[betIndex] = updatedBet;
  }

  /// Settle bet - creator chooses winner
  Future<void> settleBet({
    required String betId,
    required String winningOptionId,
  }) async {
    final betIndex = _activeBets.indexWhere((b) => b.id == betId);
    if (betIndex == -1) {
      throw Exception('Bet not found');
    }

    final bet = _activeBets[betIndex];

    // Calculate payouts
    final winnerOption = bet.options.firstWhere((o) => o.id == winningOptionId);
    final totalPool = bet.poolSize;
    final creatorFee = FeeCalculator.calculateBettingCreatorFee(totalPool);
    final payoutPool = totalPool - creatorFee;

    // In production: distribute winnings to winners

    // Move to settled
    final settledBet = Bet(
      id: bet.id,
      creatorId: bet.creatorId,
      title: bet.title,
      description: bet.description,
      wagerAmount: bet.wagerAmount,
      poolSize: totalPool,
      createdAt: bet.createdAt,
      expiresAt: bet.expiresAt,
      status: BetStatus.settled,
      options: bet.options,
    );

    _activeBets.removeAt(betIndex);
    _settledBets.add(settledBet);
  }

  /// Cancel bet (creator only)
  Future<void> cancelBet(String betId, String requesterId) async {
    final betIndex = _activeBets.indexWhere((b) => b.id == betId);
    if (betIndex == -1) {
      throw Exception('Bet not found');
    }

    final bet = _activeBets[betIndex];
    if (bet.creatorId != requesterId) {
      throw Exception('Only creator can cancel');
    }

    // In production: refund all participants
    _activeBets[betIndex] = Bet(
      id: bet.id,
      creatorId: bet.creatorId,
      title: bet.title,
      description: bet.description,
      wagerAmount: bet.wagerAmount,
      poolSize: bet.poolSize,
      createdAt: bet.createdAt,
      expiresAt: bet.expiresAt,
      status: BetStatus.cancelled,
      options: bet.options,
    );
  }

  /// Get active bets
  List<Bet> getActiveBets() {
    return _activeBets.where((b) => b.status == BetStatus.active).toList();
  }

  /// Get my bets
  List<Bet> getMyBets(String userId) {
    return [..._activeBets, ..._settledBets]
        .where((b) => b.creatorId == userId)
        .toList();
  }

  /// Get bet by ID
  Bet? getBet(String betId) {
    try {
      return _activeBets.firstWhere((b) => b.id == betId);
    } catch (_) {
      try {
        return _settledBets.firstWhere((b) => b.id == betId);
      } catch (_) {
        return null;
      }
    }
  }

  /// Calculate potential payout
  double calculatePotentialPayout(String betId, String optionId, double amount) {
    final bet = getBet(betId);
    if (bet == null) return 0;

    final option = bet.options.firstWhere(
      (o) => o.id == optionId,
      orElse: () => throw Exception('Option not found'),
    );

    if (option.totalWagered == 0) return 0;
    return (amount / option.totalWagered) * bet.poolSize;
  }

  String _generateBetId() {
    return 'BET-${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateOptionId() {
    return 'OPT-${DateTime.now().microsecondsSinceEpoch}';
  }
}