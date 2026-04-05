import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FinancialScreen extends StatelessWidget {
  const FinancialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$12,450.00',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: AppTheme.successColor,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '+12.5%',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Row(
              children: [
                Expanded(child: _buildActionButton('Send', Icons.send)),
                const SizedBox(width: 12),
                Expanded(child: _buildActionButton('Receive', Icons.download)),
                const SizedBox(width: 12),
                Expanded(child: _buildActionButton('Swap', Icons.swap_horiz)),
              ],
            ),
            const SizedBox(height: 24),
            // Assets
            const Text(
              'Assets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAssetCard('PINC Token', 'PINC', '\$8,250.00', '+15.2%', true),
            _buildAssetCard('Bitcoin', 'BTC', '\$2,100.00', '+5.8%', true),
            _buildAssetCard('Ethereum', 'ETH', '\$1,800.00', '-2.3%', false),
            _buildAssetCard('Stablecoin', 'USDC', '\$300.00', '0.0%', true),
            const SizedBox(height: 24),
            // Recent Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTransactionTile(
              'Sent to Alice',
              '-$50.00',
              Icons.arrow_upward,
              AppTheme.errorColor,
              '2:30 PM',
            ),
            _buildTransactionTile(
              'Received from Bob',
              '+\$125.00',
              Icons.arrow_downward,
              AppTheme.successColor,
              '1:15 PM',
            ),
            _buildTransactionTile(
              'Swap PINC -> BTC',
              '-\$200.00',
              Icons.swap_horiz,
              AppTheme.warningColor,
              '11:00 AM',
            ),
            _buildTransactionTile(
              'Received from Charlie',
              '+\$75.00',
              Icons.arrow_downward,
              AppTheme.successColor,
              'Yesterday',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetCard(
    String name,
    String symbol,
    String value,
    String change,
    bool positive,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              symbol.substring(0, 1),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(name),
        subtitle: Text(
          symbol,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              change,
              style: TextStyle(
                color: positive ? AppTheme.successColor : AppTheme.errorColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    String title,
    String amount,
    IconData icon,
    Color color,
    String time,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title),
        subtitle: Text(
          time,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}