import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class P2PScreen extends StatelessWidget {
  const P2PScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P Mesh VPN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status
            Card(
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
                      child: const Icon(
                        Icons.device_hub,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Connected',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '12 peers in network',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Network Stats
            const Text(
              'Network Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Upload', '45.2 MB', Icons.upload)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Download', '128 MB', Icons.download)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Latency', '12ms', Icons.speed)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Bandwidth', '1.2 Gbps', Icons.network_check)),
              ],
            ),
            const SizedBox(height: 24),
            // Active Peers
            const Text(
              'Active Peers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPeerCard('Peer Alpha', '192.168.1.101', true),
            _buildPeerCard('Peer Beta', '192.168.1.102', true),
            _buildPeerCard('Peer Gamma', '192.168.1.103', false),
            _buildPeerCard('Peer Delta', '192.168.1.104', true),
            const SizedBox(height: 24),
            // VPN Controls
            const Text(
              'VPN Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable VPN'),
                    subtitle: const Text('Encrypted mesh network'),
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Allow Peer Connections'),
                    subtitle: const Text('Connect to nearby devices'),
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Use Tor Integration'),
                    subtitle: const Text('Anonymous routing'),
                    value: false,
                    onChanged: (value) {},
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeerCard(String name, String ip, bool online) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: online
                ? AppTheme.successColor.withOpacity(0.2)
                : AppTheme.textSecondary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.people,
            color: online ? AppTheme.successColor : AppTheme.textSecondary,
          ),
        ),
        title: Text(name),
        subtitle: Text(
          ip,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        trailing: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: online ? AppTheme.successColor : AppTheme.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}