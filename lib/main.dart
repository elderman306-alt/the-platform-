// THE PLATFORM - PINC Network
// Comprehensive Flutter Application
// Version: 1.0.0

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';

import 'core/config/app_config.dart';
import 'core/services/encryption_service.dart';
import 'core/services/security_service.dart';
import 'core/services/resource_governor.dart';
import 'core/services/wallet_service.dart';
import 'core/services/p2p_service.dart';
import 'core/services/payment_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

// Main Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize security first
  await _initializeSecurity();
  
  // Run app
  runApp(const ThePlatformApp());
}

Future<void> _initializeSecurity() async {
  // Check integrity before running
  final secure = await SecurityService.verifyIntegrity();
  if (!secure) {
    // Security breach detected
    await SecurityService.triggerSelfDestruct('integrity_failure');
  }
  
  // Initialize encrypted storage
  await Hive.initFlutter();
  await const FlutterSecureStorage().deleteAll();
  
  // Enforce resource limits
  ResourceGovernor.enforceLimits();
}

class ThePlatformApp extends StatefulWidget {
  const ThePlatformApp({super.key});

  @override
  State<ThePlatformApp> createState() => _ThePlatformAppState();
}

class _ThePlatformAppState extends State<ThePlatformApp> {
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    // Load wallet
    await WalletService.load();
    
    // Connect to P2P
    await P2PService.connect();
    
    setState(() => _isInitialized = true);
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _isInitialized ? const MainNavigation() : const SplashScreen(),
    );
  }
}

// Main Navigation with 7 tabs
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const IdentityScreen(),
    const P2PScreen(),
    const ChatScreen(),
    const WalletScreen(),
    const GamesScreen(),
    const JobsScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            label: 'Identity',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            label: 'P2P',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.wallet_outlined),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.games_outlined),
            label: 'Games',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outlined),
            label: 'Jobs',
          ),
        ],
      ),
    );
  }
}

// ============== SCREENS ==============

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THE PLATFORM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PINC Balance Card
            _buildBalanceCard(),
            const SizedBox(height: 20),
            
            // Quick Actions
            _buildQuickActions(context),
            const SizedBox(height: 20),
            
            // Network Status
            _buildNetworkStatus(),
            const SizedBox(height: 20),
            
            // Recent Activity
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PINC Balance',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  WalletService.balance.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'PINC',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip('Level ${WalletService.securityLevel}', Icons.shield),
                const SizedBox(width: 8),
                _buildStatChip(P2PService.isConnected ? 'Online' : 'Offline', 
                    P2PService.isConnected ? Icons.cloud_done : Icons.cloud_off),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton('Send', Icons.send, () => _sendPinc(context)),
            _buildActionButton('Receive', Icons.qr_code, () => _receivePinc(context)),
            _buildActionButton('Trade', Icons.swap_horiz, () => _trade(context)),
            _buildActionButton('Stake', Icons.stake, () => _stake(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Network Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildStatusRow('P2P Network', P2PService.isConnected ? 'Connected' : 'Disconnected',
                P2PService.isConnected ? Colors.green : Colors.red),
            _buildStatusRow('Active Peers', '${P2PService.peerCount}', AppTheme.primaryColor),
            _buildStatusRow('Bandwidth', '${P2PService.bandwidth.toStringAsFixed(2)} Mbps', 
                AppTheme.primaryColor),
            _buildStatusRow('Latency', '${P2PService.latency}ms', AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // List transactions
        ...WalletService.transactions.take(5).map((tx) => _buildTransactionItem(tx)),
      ],
    );
  }

  Widget _buildTransactionItem(dynamic tx) {
    return ListTile(
      leading: Icon(
        tx['type'] == 'received' ? Icons.arrow_downward : Icons.arrow_upward,
        color: tx['type'] == 'received' ? Colors.green : Colors.red,
      ),
      title: Text(tx['address'] ?? 'Unknown'),
      subtitle: Text(tx['time'] ?? ''),
      trailing: Text(
        '${tx['type'] == 'received' ? '+' : '-'}${tx['amount']} PINC',
        style: TextStyle(
          color: tx['type'] == 'received' ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    // Settings dialog
  }

  void _sendPinc(BuildContext context) {
    // Send PINC dialog
  }

  void _receivePinc(BuildContext context) {
    // Show QR code
  }

  void _trade(BuildContext context) {
    // Trading interface
  }

  void _stake(BuildContext context) {
    // Staking interface
  }
}

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key});

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  String _pincId = '';
  int _securityLevel = 0;
  bool _hasPin = false;
  bool _hasBiometric = false;
  
  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }
  
  Future<void> _loadIdentity() async {
    setState(() {
      _pincId = WalletService.pincId;
      _securityLevel = WalletService.securityLevel;
      _hasPin = WalletService.hasPin;
      _hasBiometric = WalletService.hasBiometric;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PINC ID Card
            _buildPincIdCard(),
            const SizedBox(height: 20),
            
            // Security Level
            _buildSecurityLevel(),
            const SizedBox(height: 20),
            
            // Security Options
            _buildSecurityOptions(),
            const SizedBox(height: 20),
            
            // Private Key Backup
            _buildBackupSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPincIdCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.badge, size: 48, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            const Text('PINC ID', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              _pincId.isEmpty ? 'Not Set' : _pincId,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Hardware Bound', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityLevel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Security Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Level $_securityLevel/5', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _securityLevel / 5,
              backgroundColor: AppTheme.surfaceColor,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              _getSecurityDescription(),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _getSecurityDescription() {
    switch (_securityLevel) {
      case 0: return 'No security set';
      case 1: return 'PIN required';
      case 2: return 'Password required';
      case 3: return 'Biometric enabled';
      case 4: return 'Hardware key bound';
      case 5: return 'Maximum security';
      default: return '';
    }
  }

  Widget _buildSecurityOptions() {
    return Card(
      child: Column(
        children: [
          _buildOptionTile('PIN', Icons.pin, _hasPin, () => _setupPin()),
          _buildOptionTile('Password', Icons.password, _hasPin, () => _setupPassword()),
          _buildOptionTile('Biometric', Icons.fingerprint, _hasBiometric, () => _setupBiometric()),
          _buildOptionTile('Hardware Key', Icons.key, _securityLevel >= 4, () => _setupHardwareKey()),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, bool enabled, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: enabled ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              enabled ? 'Enabled' : 'Disabled',
              style: TextStyle(color: enabled ? Colors.green : Colors.red, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildBackupSection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.backup),
        title: const Text('Backup Private Key'),
        subtitle: const Text('Save your 15-word seed phrase'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _backupKey,
      ),
    );
  }

  void _setupPin() {
    // Setup PIN
  }

  void _setupPassword() {
    // Setup password
  }

  void _setupBiometric() {
    // Setup biometric
  }

  void _setupHardwareKey() {
    // Setup hardware key
  }

  void _backupKey() {
    // Backup key
  }
}

class P2PScreen extends StatelessWidget {
  const P2PScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => P2PService.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          _buildStatusCard(),
          
          // Tabs
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Internet'),
                      Tab(text: 'Share'),
                      Tab(text: 'Earn'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildInternetTab(),
                        _buildShareTab(),
                        _buildEarnTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Peers', '${P2PService.peerCount}', Icons.people),
                _buildStatItem('Bandwidth', '${P2PService.bandwidth.toStringAsFixed(1)} Mbps', Icons.speed),
                _buildStatItem('Earned', '${P2PService.earnings.toStringAsFixed(2)} PINC', Icons.monetization_on),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildInternetTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Buy Internet Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...P2PService.dataPlans.map((plan) => _buildDataPlanCard(plan)),
      ],
    );
  }

  Widget _buildDataPlanCard(dynamic plan) {
    return Card(
      child: ListTile(
        title: Text('${plan['data']} GB'),
        subtitle: Text('${plan['duration']} days - ${plan['price']} PINC'),
        trailing: const Text('Buy'),
        onTap: () => P2PService.buyData(plan),
      ),
    );
  }

  Widget _buildShareTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Share Your Internet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.wifi, size: 48, color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                const Text('Start Sharing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Earn PINC by sharing your internet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: P2PService.startSharing,
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEarnTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Earn PINC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildEarnOption('Run Node', 'Earn by running a P2P node', Icons.hub, () {}),
        _buildEarnOption('Refer Friends', 'Earn by referring friends', Icons.person_add, () {}),
        _buildEarnOption('Data Merchant', 'Sell internet data', Icons.shopping_bag, () {}),
      ],
    );
  }

  Widget _buildEarnOption(String title, String desc, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(desc),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text('No conversations'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Total Balance', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          WalletService.balance.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Text('PINC', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton('Send', Icons.send, () {}),
                _buildActionButton('Receive', Icons.qr_code, () {}),
                _buildActionButton('Buy', Icons.credit_card, () {}),
                _buildActionButton('Swap', Icons.swap_horiz, () {}),
              ],
            ),
            const SizedBox(height: 20),
            
            // Transactions
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ...WalletService.transactions.map((tx) => ListTile(
              leading: Icon(
                tx['type'] == 'received' ? Icons.arrow_downward : Icons.arrow_upward,
                color: tx['type'] == 'received' ? Colors.green : Colors.red,
              ),
              title: Text(tx['address']),
              subtitle: Text(tx['time']),
              trailing: Text(
                '${tx['type'] == 'received' ? '+' : '-'}${tx['amount']} PINC',
                style: TextStyle(
                  color: tx['type'] == 'received' ? Colors.green : Colors.red,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildGameCard('Connect 4', Icons.grid_4x4, () {}),
          _buildGameCard('Tic Tac Toe', Icons.grid_3x3, () {}),
          _buildGameCard('Memory', Icons.memory, () {}),
          _buildGameCard('Snake', Icons.fastfood, () {}),
          _buildGameCard('Pong', Icons.sports_tennis, () {}),
          _buildGameCard('Wordle', Icons.abc, () {}),
        ],
      ),
    );
  }

  Widget _buildGameCard(String name, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(name),
          ],
        ),
      ),
    );
  }
}

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search
          TextField(
            decoration: InputDecoration(
              hintText: 'Search jobs...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Categories
          Wrap(
            spacing: 8,
            children: [
              Chip(label: const Text('All')),
              Chip(label: const Text('Development')),
              Chip(label: const Text('Design')),
              Chip(label: const Text('Writing')),
              Chip(label: const Text('Marketing')),
            ],
          ),
          const SizedBox(height: 16),
          
          // Jobs List
          ..._buildJobsList(),
        ],
      ),
    );
  }

  List<Widget> _buildJobsList() {
    // Placeholder jobs
    return [
      Card(
        child: ListTile(
          title: const Text('Flutter Developer'),
          subtitle: const Text('Build P2P app'),
          trailing: const Text('500 PINC'),
        ),
      ),
    ];
  }
}

// Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hub, size: 96, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            const Text('THE PLATFORM', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('PINC Network'),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}