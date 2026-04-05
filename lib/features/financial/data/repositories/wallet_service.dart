import '../../../domain/entities/financial_entities.dart';
import '../../../domain/usecases/fee_calculator.dart';

/// Wallet Service - Core wallet operations
class WalletService {
  Wallet? _currentWallet;
  final List<FinancialTransaction> _transactions = [];

  /// Initialize wallet for user
  Future<Wallet> initializeWallet(String userId) async {
    _currentWallet = Wallet(
      id: 'PINC-$userId',
      balance: 1000.0, // Initial test balance
    );
    return _currentWallet!;
  }

  /// Get current wallet
  Wallet? get currentWallet => _currentWallet;

  /// Get balance
  double get balance => _currentWallet?.balance ?? 0.0;

  /// Internal transfer - FREE
  Future<FinancialTransaction> sendPINC({
    required String toId,
    required double amount,
    String? description,
  }) async {
    _validateWallet();
    _validateAmount(amount);

    if (_currentWallet!.balance < amount) {
      throw Exception('Insufficient balance');
    }

    final tx = FinancialTransaction(
      id: _generateId(),
      type: 'send',
      amount: amount,
      fee: 0.0, // FREE
      toId: toId,
      description: description ?? 'Transfer to $toId',
      status: TransactionStatus.completed,
    );

    _currentWallet = _currentWallet!.copyWith(
      balance: _currentWallet!.balance - amount,
    );
    _transactions.add(tx);

    return tx;
  }

  /// Receive PINC
  Future<FinancialTransaction> receivePINC({
    required String fromId,
    required double amount,
    String? description,
  }) async {
    _validateWallet();

    final tx = FinancialTransaction(
      id: _generateId(),
      type: 'receive',
      amount: amount,
      fee: 0.0, // FREE
      fromId: fromId,
      description: description ?? 'Received from $fromId',
      status: TransactionStatus.completed,
    );

    _currentWallet = _currentWallet!.copyWith(
      balance: _currentWallet!.balance + amount,
    );
    _transactions.add(tx);

    return tx;
  }

  /// Deposit - FREE
  Future<FinancialTransaction> deposit({
    required double amount,
    required String source,
    String? details,
  }) async {
    _validateWallet();
    _validateAmount(amount);

    final tx = FinancialTransaction(
      id: _generateId(),
      type: 'deposit',
      amount: amount,
      fee: 0.0, // FREE
      description: 'Deposit from $source${details != null ? ': $details' : ''}',
      status: TransactionStatus.completed,
    );

    _currentWallet = _currentWallet!.copyWith(
      balance: _currentWallet!.balance + amount,
    );
    _transactions.add(tx);

    return tx;
  }

  /// Withdraw - 3-103 PINC tiered fee
  Future<FinancialTransaction> withdraw({
    required double amount,
    required String externalAddress,
  }) async {
    _validateWallet();
    _validateAmount(amount);

    final fee = FeeCalculator.calculateWithdrawalFee(amount);
    final total = amount + fee;

    if (_currentWallet!.balance < total) {
      throw Exception('Insufficient balance. Need $total (including $fee fee)');
    }

    final tx = FinancialTransaction(
      id: _generateId(),
      type: 'withdraw',
      amount: amount,
      fee: fee,
      description: 'Withdraw to $externalAddress',
      status: TransactionStatus.pending,
    );

    _currentWallet = _currentWallet!.copyWith(
      balance: _currentWallet!.balance - total,
    );
    _transactions.add(tx);

    return tx;
  }

  /// Create job escrow - 3% fee
  Future<FinancialTransaction> createJobEscrow({
    required double amount,
    required String jobId,
    required String freelancerId,
  }) async {
    _validateWallet();
    _validateAmount(amount);

    final fee = FeeCalculator.calculateJobEscrowFee(amount);
    final total = amount + fee;

    if (_currentWallet!.balance < total) {
      throw Exception('Insufficient balance for escrow');
    }

    final tx = FinancialTransaction(
      id: _generateId(),
      type: 'escrow',
      amount: amount,
      fee: fee,
      description: 'Job escrow: $jobId → $freelancerId',
      status: TransactionStatus.pending,
    );

    _currentWallet = _currentWallet!.copyWith(
      balance: _currentWallet!.balance - total,
    );
    _transactions.add(tx);

    return tx;
  }

  /// Release job payout - 9% fee
  Future<FinancialTransaction> releaseJobPayout({
    required String escrowId,
    required double amount,
    required String freelancerId,
  }) async {
    _validateWallet();

    final fee = FeeCalculator.calculateJobPayoutFee(amount);
    final total = amount + fee;

    // In production: release from escrow to freelancer minus fee

    final tx = FinancialTransaction(
      id: _generateId(),
      type: 'payout',
      amount: amount,
      fee: fee,
      toId: freelancerId,
      description: 'Job payout from escrow: $escrowId',
      status: TransactionStatus.completed,
    );

    _transactions.add(tx);
    return tx;
  }

  /// Create bet - 7% fee, min 20 PINC
  Future<Bet> createBet({
    required String title,
    String? description,
    required double wagerAmount,
    required List<String> options,
    DateTime? expiresAt,
  }) async {
    _validateWallet();
    
    if (!FeeCalculator.isValidBetAmount(wagerAmount)) {
      throw Exception('Minimum bet is ${FeeCalculator.bettingMinWager} PINC');
    }

    final fee = FeeCalculator.calculateBettingFee(wagerAmount);
    final total = wagerAmount + fee;

    if (_currentWallet!.balance < total) {
      throw Exception('Insufficient balance for bet');
    }

    _currentWallet = _currentWallet!.copyWith(
      balance: _currentWallet!.balance - total,
    );

    final bet = Bet(
      id: _generateId(),
      creatorId: _currentWallet!.id,
      title: title,
      description: description ?? '',
      wagerAmount: wagerAmount,
      poolSize: wagerAmount,
      expiresAt: expiresAt,
      options: options.map((name) => BetOption(
        id: _generateId(),
        name: name,
      )).toList(),
    );

    return bet;
  }

  /// Place bet
  Future<void> placeBet(String betId, String optionId, double amount) async {
    _validateWallet();
    _validateAmount(amount);

    // Add to bet pool
    // Deduct from balance
  }

  /// Create fundraiser - 9% fee
  Future<Fundraiser> createFundraiser({
    required String title,
    String? description,
    required double targetAmount,
    DateTime? deadline,
  }) async {
    final fee = FeeCalculator.calculateFundraisingFee(targetAmount);

    return Fundraiser(
      id: _generateId(),
      creatorId: _currentWallet?.id ?? 'unknown',
      title: title,
      description: description ?? '',
      targetAmount: targetAmount,
      deadline: deadline,
    );
  }

  /// Contribute to fundraiser
  Future<FinancialTransaction> contributeToFundraiser({
    required String fundraiserId,
    required double amount,
  }) async {
    _validateWallet();
    _validateAmount(amount);

    final fee = FeeCalculator.calculateFundraisingFee(amount);
    final total = amount + fee;

    if (_currentWallet!.balance < total) {
      throw Exception('Insufficient balance');
    }

    final tx = FinancialTransaction(
      id: _generateId(),
      type: 'fundraising',
      amount: amount,
      fee: fee,
      toId: fundraiserId,
      description: 'Contribution to fundraiser',
      status: TransactionStatus.completed,
    );

    _currentWallet = _currentWallet!.copyWith(
      balance: _currentWallet!.balance - total,
    );
    _transactions.add(tx);

    return tx;
  }

  /// Get transaction history
  List<FinancialTransaction> getTransactionHistory() {
    return _transactions.reversed.toList();
  }

  /// Generate unique ID
  String _generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rnd = DateTime.now().microsecondsSinceEpoch % 10000;
    return '${ts}$rnd';
  }

  void _validateWallet() {
    if (_currentWallet == null) {
      throw Exception('Wallet not initialized');
    }
  }

  void _validateAmount(double amount) {
    if (amount <= 0) {
      throw Exception('Amount must be positive');
    }
  }
}