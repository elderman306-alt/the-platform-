import 'package:flutter/material.dart';
import '../../models/wallet_model.dart';
import '../../services/financial/wallet_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletScreen extends StatefulWidget {
  final String? initialPincoderId;
  
  const WalletScreen({super.key, this.initialPincoderId});
  
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pincoderIdController = TextEditingController();
  final TextEditingController _walletAddressController = TextEditingController();
  
  String? _currentPincoderId;
  double _balance = 0.0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  int _selectedTab = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeWallet();
  }
  
  Future<void> _initializeWallet() async {
    setState(() => _isLoading = true);
    try {
      _currentPincoderId = widget.initialPincoderId ?? 'PINC-${_generateRandomId()}';
      final wallet = await _walletService.initializeWallet(_currentPincoderId!);
      setState(() {
        _balance = wallet.balance;
        _transactions = wallet.transactions;
      });
    } catch (e) {
      _showSnackBar('Error initializing wallet: $e', isError: true);
    }
    setState(() => _isLoading = false);
  }
  
  String _generateRandomId() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return random.toString().substring(0, 10).toUpperCase();
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131A24),
        title: const Text('PINC Wallet', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _initializeWallet,
          ),
        ],
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '₿ ${WalletService.formatBalance(_balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(Icons.arrow_upward, 'Send', () => _showSendDialog()),
              _buildQuickAction(Icons.arrow_downward, 'Receive', () => _showReceiveDialog()),
              _buildQuickAction(Icons.add, 'Deposit', () => _showDepositDialog()),
              _buildQuickAction(Icons.arrow_outward, 'Withdraw', () => _showWithdrawDialog()),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white20,
              borderRadius: BorderRadius.circular(12),
            ),
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
          _buildTab('Transactions', 0),
          _buildTab('Escrow', 1),
          _buildTab('Settings', 2),
        ],
      ),
    );
  }
  
  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF00D4AA) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00D4AA) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildTransactionsList();
      case 1:
        return _buildEscrowSection();
      case 2:
        return _buildSettingsSection();
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text('No transactions yet', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionTile(transaction);
      },
    );
  }
  
  Widget _buildTransactionTile(Transaction tx) {
    final isReceive = tx.type == 'receive' || tx.type == 'deposit';
    final icon = isReceive ? Icons.arrow_downward : Icons.arrow_upward;
    final color = isReceive ? Colors.green : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.type.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  tx.description ?? tx.type,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isReceive ? '+' : '-'}₿ ${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              Text(
                _formatTimestamp(tx.timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
  
  Widget _buildEscrowSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text('No active escrows', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateEscrowDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Escrow'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsTile('My PINC ID', _currentPincoderId ?? 'Not set', Icons.tag),
        _buildSettingsTile('Deposit', 'Add funds', Icons.add_circle),
        _buildSettingsTile('Withdraw', 'Transfer out', Icons.remove_circle),
        _buildSettingsTile('Transaction Fees', 'View rates', Icons.percent),
        _buildSettingsTile('Security', 'PIN & encryption', Icons.lock),
        _buildSettingsTile('Backup Wallet', 'Export seed phrase', Icons.backup),
      ],
    );
  }
  
  Widget _buildSettingsTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131A24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00D4AA)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500])),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
  
  void _showSendDialog() {
    _pincoderIdController.clear();
    _amountController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send PINC', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _pincoderIdController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Recipient PINC ID',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D4AA))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D4AA))),
                prefixText: '₿ ',
                prefixStyle: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text('Available: ₿ ${WalletService.formatBalance(_balance)}', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(_amountController.text);
                  final toId = _pincoderIdController.text.trim();
                  
                  if (amount == null || amount <= 0) {
                    _showSnackBar('Please enter a valid amount', isError: true);
                    return;
                  }
                  if (toId.isEmpty) {
                    _showSnackBar('Please enter recipient PINC ID', isError: true);
                    return;
                  }
                  
                  Navigator.pop(context);
                  await _performSend(toId, amount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Send (FREE)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Future<void> _performSend(String toId, double amount) async {
    setState(() => _isLoading = true);
    try {
      final tx = await _walletService.sendPinc(
        toPincoderId: toId,
        amount: amount,
        description: 'Sent to $toId',
      );
      setState(() {
        _balance = _walletService.balance;
        _transactions = _walletService.getTransactionHistory();
      });
      _showSnackBar('Sent ₿${amount.toStringAsFixed(2)} to $toId');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
    setState(() => _isLoading = false);
  }
  
  void _showReceiveDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Receive PINC', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: _walletService.generateReceiveQR(),
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            const SizedBox(height: 16),
            SelectableText(
              _currentPincoderId ?? '',
              style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Share this ID to receive PINC', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
  
  void _showDepositDialog() {
    _amountController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deposit Funds', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('FREE - No fees for deposits', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 20),
            _buildDepositOption('Crypto', Icons.currency_bitcoin, () => _processDeposit('Crypto')),
            _buildDepositOption('PayPal', Icons.payment, () => _processDeposit('PayPal')),
            _buildDepositOption('P2P Agent', Icons.people, () => _processDeposit('P2P Agent')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDepositOption(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00D4AA)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
  
  Future<void> _processDeposit(String source) async {
    final amount = double.tryParse(_amountController.text) ?? 100.0;
    Navigator.pop(context);
    
    setState(() => _isLoading = true);
    try {
      await _walletService.deposit(amount: amount, source: source);
      setState(() {
        _balance = _walletService.balance;
        _transactions = _walletService.getTransactionHistory();
      });
      _showSnackBar('Deposited ₿${amount.toStringAsFixed(2)} via $source');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
    setState(() => _isLoading = false);
  }
  
  void _showWithdrawDialog() {
    _amountController.clear();
    _walletAddressController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Withdraw', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('3% fee applies', style: TextStyle(color: Colors.orange)),
              const SizedBox(height: 20),
              TextField(
                controller: _walletAddressController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'External Wallet Address',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D4AA))),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D4AA))),
                  prefixText: '₿ ',
                  prefixStyle: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  final fee = WalletService.calculateWithdrawalFee(amount);
                  return Text(
                    'Fee: ₿${fee.toStringAsFixed(2)} | Total: ₿${(amount + fee).toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(_amountController.text);
                    final address = _walletAddressController.text.trim();
                    
                    if (amount == null || amount <= 0) {
                      _showSnackBar('Please enter a valid amount', isError: true);
                      return;
                    }
                    if (address.isEmpty) {
                      _showSnackBar('Please enter wallet address', isError: true);
                      return;
                    }
                    
                    Navigator.pop(context);
                    await _performWithdraw(address, amount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _performWithdraw(String address, double amount) async {
    setState(() => _isLoading = true);
    try {
      await _walletService.withdraw(amount: amount, externalWallet: address);
      setState(() {
        _balance = _walletService.balance;
        _transactions = _walletService.getTransactionHistory();
      });
      _showSnackBar('Withdrawal initiated: ₿${amount.toStringAsFixed(2)}');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
    setState(() => _isLoading = false);
  }
  
  void _showCreateEscrowDialog() {
    _amountController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Escrow', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('9% fee for job payments', style: TextStyle(color: Colors.orange)),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D4AA))),
                prefixText: '₿ ',
                prefixStyle: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final amount = double.tryParse(_amountController.text) ?? 0;
                final fee = WalletService.calculateEscrowFee(amount);
                return Text(
                  'Fee (9%): ₿${fee.toStringAsFixed(2)} | Total: ₿${(amount + fee).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text);
                  if (amount == null || amount <= 0) {
                    _showSnackBar('Please enter a valid amount', isError: true);
                    return;
                  }
                  Navigator.pop(context);
                  _showSnackBar('Escrow feature requires blockchain integration');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Escrow', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _pincoderIdController.dispose();
    _walletAddressController.dispose();
    super.dispose();
  }
}