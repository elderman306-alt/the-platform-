import 'package:flutter/material.dart';
import '../domain/entities/financial_entities.dart';
import '../domain/usecases/fee_calculator.dart';
import '../data/repositories/wallet_service.dart';
import '../data/repositories/bet_service.dart';
import '../data/repositories/transfer_service.dart';

/// Financial Screen - Main financial hub UI
class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  final WalletService _walletService = WalletService();
  final BetService _betService = BetService();
  final TransferService _transferService = TransferService();
  
  double _balance = 1000.0;
  int _selectedTab = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() async {
    await _walletService.initializeWallet('testuser');
    _transferService.addTestAgent();
    setState(() {
      _balance = _walletService.balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131A24),
        title: const Text('💰 Financial Hub', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)))
        : Column(
          children: [
            _buildBalanceCard(),
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
        ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF7B61FF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('PINC Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            TransferService.formatPinc(_balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _quickAction(Icons.send, 'Send', () => _showSendDialog()),
              _quickAction(Icons.call_received, 'Receive', () => _showReceiveDialog()),
              _quickAction(Icons.add, 'Deposit', () => _showDepositDialog()),
              _quickAction(Icons.arrow_outward, 'Withdraw', () => _showWithdrawDialog()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white20, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tab('Bets', 0),
          _tab('Fundraisers', 1),
          _tab('P2P Agents', 2),
          _tab('Fees', 3),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFF00D4AA) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? const Color(0xFF00D4AA) : Colors.grey,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: return _buildBetsTab();
      case 1: return _buildFundraisersTab();
      case 2: return _buildP2PAgentsTab();
      case 3: return _buildFeesTab();
      default: return const SizedBox();
    }
  }

  Widget _buildBetsTab() {
    final activeBets = _betService.getActiveBets();
    if (activeBets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            const Text('No active bets', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreateBetDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Bet'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), foregroundColor: Colors.black),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeBets.length,
      itemBuilder: (context, index) => _buildBetCard(activeBets[index]),
    );
  }

  Widget _buildBetCard(Bet bet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF131A24), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bet.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Pool: ${TransferService.formatPinc(bet.poolSize)} | Min: ${FeeCalculator.bettingMinWager} PINC',
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 8),
          ...bet.options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• ${opt.name}: ${TransferService.formatPinc(opt.totalWagered)}',
              style: const TextStyle(color: Color(0xFF00D4AA))),
          )),
        ],
      ),
    );
  }

  Widget _buildFundraisersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.volunteer_activism, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text('No active fundraisers', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateFundraiserDialog,
            icon: const Icon(Icons.add),
            label: const Text('Start Fundraiser'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), foregroundColor: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildP2PAgentsTab() {
    final agents = _transferService.findAgents();
    if (agents.isEmpty) {
      return const Center(child: Text('No P2P agents available', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agents.length,
      itemBuilder: (context, index) => _buildAgentCard(agents[index]),
    );
  }

  Widget _buildAgentCard(P2PAgent agent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF131A24), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF00D4AA).withOpacity(0.2),
            child: const Icon(Icons.person, color: Color(0xFF00D4AA)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agent.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${agent.paymentMethod} | ${(agent.margin * 100).toStringAsFixed(0)}% margin',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text('${TransferService.formatPinc(agent.minAmount)} - ${TransferService.formatPinc(agent.maxAmount)}',
            style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFeesTab() {
    final fees = TransferService.getFeeSummary();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fees.length,
      itemBuilder: (context, index) {
        final fee = fees[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF131A24), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fee['type']!, style: const TextStyle(color: Colors.white)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fee['fee']!, style: const TextStyle(color: Color(0xFF00D4AA), fontWeight: FontWeight.bold)),
                  Text(fee['details']!, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  void _showSendDialog() {
    final toController = TextEditingController();
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A24),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send PINC', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: toController, style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Recipient PINC ID')),
            const SizedBox(height: 12),
            TextField(controller: amountController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number,
              decoration: _inputDecoration('Amount')),
            const SizedBox(height: 8),
            const Text('Fee: FREE', style: TextStyle(color: Colors.green)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    _showSnackBar('Invalid amount', isError: true);
                    return;
                  }
                  Navigator.pop(ctx);
                  _showSnackBar('Send feature requires integration');
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), foregroundColor: Colors.black),
                child: const Text('Send (FREE)'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showReceiveDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131A24),
      builder: (ctx) => const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your PINC ID', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 16),
            Text('PINC-XXXXXXXX', style: TextStyle(color: Color(0xFF00D4AA), fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Share this ID to receive PINC', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131A24),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Deposit Funds', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _depositOption('Crypto', Icons.currency_bitcoin, 'Bitcoin, Ethereum, etc.'),
            _depositOption('PayPal', Icons.payment, 'Instant transfer'),
            _depositOption('P2P Agent', Icons.people, '4-7% margin'),
            const SizedBox(height: 16),
            const Text('All deposits are FREE', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _depositOption(String title, IconData icon, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFF0A0E14), borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00D4AA)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _showSnackBar('Deposit via $title - Integration required'),
      ),
    );
  }

  void _showWithdrawDialog() {
    final addressController = TextEditingController();
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A24),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Withdraw', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('3-103 PINC tiered fee', style: TextStyle(color: Colors.orange)),
            const SizedBox(height: 16),
            TextField(controller: addressController, style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('External Wallet Address')),
            const SizedBox(height: 12),
            TextField(controller: amountController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number,
              decoration: _inputDecoration('Amount')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnackBar('Withdraw - Integration required');
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), foregroundColor: Colors.black),
                child: const Text('Withdraw'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCreateBetDialog() {
    final titleController = TextEditingController();
    final wagerController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A24),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create Bet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Min wager: 20 PINC | 7% fee', style: TextStyle(color: Colors.orange)),
            const SizedBox(height: 16),
            TextField(controller: titleController, style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Bet Title')),
            const SizedBox(height: 12),
            TextField(controller: wagerController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number,
              decoration: _inputDecoration('Wager Amount')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnackBar('Bet created! (Integration required)');
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), foregroundColor: Colors.black),
                child: const Text('Create Bet'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCreateFundraiserDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A24),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Start Fundraiser', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('9% fee on raised amount', style: TextStyle(color: Colors.orange)),
            const SizedBox(height: 16),
            TextField(controller: titleController, style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Fundraiser Title')),
            const SizedBox(height: 12),
            TextField(controller: targetController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number,
              decoration: _inputDecoration('Target Amount')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnackBar('Fundraiser created! (Integration required)');
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), foregroundColor: Colors.black),
                child: const Text('Start Fundraiser'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey[400]),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D4AA))),
  );
}