// 🔷 THE PLATFORM - Security Settings Screen
// Security configuration and management

import 'package:flutter/material.dart';
import 'package:the_platform-/core/security/security_service.dart';
import 'package:the_platform-/core/security/seed_generator.dart';

/// ==========================================
/// SECURITY SETTINGS SCREEN
/// ==========================================

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final SecurityService _security = SecurityService();
  final SeedGenerator _seedGenerator = SeedGenerator();

  bool _isBiometricEnabled = false;
  bool _isLoading = false;
  String? _seedPhrase;
  SecurityStatus? _securityStatus;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);

    final status = _security.getSecurityStatus();

    setState(() {
      _securityStatus = status;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Security',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D4AA),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Security Status
                _buildSecurityStatusCard(),
                const SizedBox(height: 16),

                // PIN Change
                _buildSettingsTile(
                  icon: Icons.pin,
                  title: 'Change PIN',
                  subtitle: 'Update your 6-digit PIN',
                  onTap: () {
                    // Navigate to change PIN
                  },
                ),

                // Pattern Change
                _buildSettingsTile(
                  icon: Icons.grid_3x3,
                  title: 'Change Pattern',
                  subtitle: 'Update your unlock pattern',
                  onTap: () {
                    // Navigate to change pattern
                  },
                ),

                // Biometric
                _buildSettingsSwitch(
                  icon: Icons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint to unlock',
                  value: _isBiometricEnabled,
                  onChanged: (value) async {
                    final result = await _security.authenticateWithBiometric();
                    if (result.success) {
                      setState(() => _isBiometricEnabled = value);
                    }
                  },
                ),

                const Divider(color: Color(0xFF131A24)),

                // Seed Phrase
                _buildSettingsTile(
                  icon: Icons.key,
                  title: 'View Seed Phrase',
                  subtitle: 'Your 15-word recovery phrase',
                  onTap: _showSeedPhrase,
                ),

                // Anti-Theft
                _buildSettingsTile(
                  icon: Icons.shield,
                  title: 'Anti-Theft Settings',
                  subtitle: 'Device lock, remote wipe',
                  onTap: () {
                    // Navigate to anti-theft settings
                  },
                ),

                // Self-Destruct
                _buildSettingsTile(
                  icon: Icons.warning,
                  title: 'Self-Destruct',
                  subtitle: 'Trigger on tampering',
                  iconColor: const Color(0xFFFF4757),
                  onTap: _showSelfDestruct,
                ),

                const Divider(color: Color(0xFF131A24)),

                // Device Info
                _buildSettingsTile(
                  icon: Icons.phone_android,
                  title: 'Device Info',
                  subtitle: 'View device fingerprint',
                  onTap: _showDeviceInfo,
                ),
              ],
            ),
    );
  }

  Widget _buildSecurityStatusCard() {
    final status = _securityStatus;
    final isSecure = status?.isSecure ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSecure ? const Color(0xFF00D4AA) : const Color(0xFFFF4757),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSecure ? Icons.check_circle : Icons.warning,
                color: isSecure ? const Color(0xFF00D4AA) : const Color(0xFFFF4757),
              ),
              const SizedBox(width: 8),
              Text(
                isSecure ? 'Device Secure' : 'Security Warning',
                style: TextStyle(
                  color: isSecure ? const Color(0xFF00D4AA) : const Color(0xFFFF4757),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            'Secure Enclave',
            status?.hasSecureEnclave ?? false,
          ),
          _buildStatusRow('Emulator', status?.isEmulator ?? false, inverted: true),
          _buildStatusRow('Rooted', status?.isRooted ?? false, inverted: true),
          _buildStatusRow('Debuggable', status?.isDebuggable ?? false, inverted: true),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value, {bool inverted = false}) {
    final isGood = inverted ? !value : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 14,
            ),
          ),
          Icon(
            isGood ? Icons.check : Icons.close,
            color: isGood ? const Color(0xFF00D4AA) : const Color(0xFFFF4757),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? const Color(0xFF00D4AA),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFFB0B0B0)),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFB0B0B0),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: const Color(0xFF00D4AA),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFFB0B0B0)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF00D4AA),
    );
  }

  void _showSeedPhrase() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131A24),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seed Phrase',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'WARNING: Anyone with this phrase can access your account',
              style: TextStyle(color: Color(0xFFFF4757)),
            ),
            const SizedBox(height: 16),
            if (_seedPhrase != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _seedPhrase!,
                  style: const TextStyle(
                    color: Color(0xFF00D4AA),
                    fontFamily: 'monospace',
                  ),
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                ),
                onPressed: () {
                  final seed = _seedGenerator.generateSeedPhrase();
                  setState(() => _seedPhrase = seed);
                },
                child: const Text(
                  'Generate New Seed',
                  style: TextStyle(color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSelfDestruct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131A24),
        title: const Text(
          'Self-Destruct',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently delete all data on this device. '
          'You can recover using your seed phrase.',
          style: TextStyle(color: Color(0xFFB0B0B0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement self-destruct
              Navigator.pop(context);
            },
            child: const Text(
              'Trigger',
              style: TextStyle(color: Color(0xFFFF4757)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131A24),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Info',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Secure Enclave: ${_securityStatus?.hasSecureEnclave ?? false ? 'Available' : 'Not Available'}',
              style: const TextStyle(color: Color(0xFFB0B0B0)),
            ),
            Text(
              'Emulator: ${_securityStatus?.isEmulator ?? false ? 'Detected' : 'Not Detected'}',
              style: const TextStyle(color: Color(0xFFB0B0B0)),
            ),
            Text(
              'Rooted: ${_securityStatus?.isRooted ?? false ? 'Yes' : 'No'}',
              style: const TextStyle(color: Color(0xFFB0B0B0)),
            ),
            Text(
              'Debuggable: ${_securityStatus?.isDebuggable ?? false ? 'Yes' : 'No'}',
              style: const TextStyle(color: Color(0xFFB0B0B0)),
            ),
          ],
        ),
      ),
    );
  }
}