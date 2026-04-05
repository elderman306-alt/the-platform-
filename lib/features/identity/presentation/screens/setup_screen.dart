// 🔷 THE PLATFORM - Setup Screen
// First launch setup for new users

import 'package:flutter/material.dart';
import 'package:the_platform-/features/identity/data/models/pinc_id.dart';
import 'package:the_platform-/core/security/security_service.dart';
import 'package:the_platform-/core/security/auth_service.dart';
import 'package:the_platform-/core/security/seed_generator.dart';

/// ==========================================
/// IDENTITY SETUP SCREEN
/// ==========================================

class IdentitySetupScreen extends StatefulWidget {
  const IdentitySetupScreen({super.key});

  @override
  State<IdentitySetupScreen> createState() => _IdentitySetupScreenState();
}

class _IdentitySetupScreenState extends State<IdentitySetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State
  String? _pincId;
  String? _deviceFingerprint;
  bool _isSecureEnclaveAvailable = false;
  String _pin = '';
  String _confirmPin = '';
  List<int> _pattern = [];
  String _seedPhrase = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeIdentity();
  }

  Future<void> _initializeIdentity() async {
    setState(() => _isLoading = true);

    try {
      // Get device fingerprint
      final security = SecurityService();
      final fingerprint = await security.getDeviceFingerprint();
      final isSecure = security.getSecurityStatus().hasSecureEnclave;

      // Generate PINC ID
      final pincId = PincId.create(
        deviceFingerprint: fingerprint.combined,
      );

      setState(() {
        _pincId = pincId.id;
        _deviceFingerprint = fingerprint.combined;
        _isSecureEnclaveAvailable = isSecure;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Setup',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D4AA),
              ),
            )
          : PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWelcomePage(),
                _buildPinPage(),
                _buildConfirmPinPage(),
                _buildPatternPage(),
                _buildSeedPhrasePage(),
                _buildCompletePage(),
              ],
            ),
    );
  }

  /// Welcome Page
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Icon(
            Icons.security,
            size: 80,
            color: Color(0xFF00D4AA),
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome to\nTHE PLATFORM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your PINC ID: $_pincId',
            style: const TextStyle(
              color: Color(0xFF00D4AA),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Device: ${_deviceFingerprint?.substring(0, 16)}...',
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _nextPage,
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PIN Page
  Widget _buildPinPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Text(
            'Create PIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '6-digit PIN for transactions under 100 PINC',
            style: TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          _buildPinInput(
            value: _pin,
            onChanged: (value) => setState(() => _pin = value),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _pin.length >= 6 ? _nextPage : null,
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirm PIN Page
  Widget _buildConfirmPinPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Text(
            'Confirm PIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your PIN again to confirm',
            style: TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          _buildPinInput(
            value: _confirmPin,
            onChanged: (value) => setState(() => _confirmPin = value),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _confirmPin == _pin && _confirmPin.length >= 6
                  ? _nextPage
                  : null,
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pattern Page
  Widget _buildPatternPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Text(
            'Create Pattern',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pattern for transactions 100-10,000 PINC',
            style: TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF131A24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 25,
                itemBuilder: (context, index) {
                  final isSelected = _pattern.contains(index);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _pattern.remove(index);
                        } else {
                          _pattern.add(index);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00D4AA)
                            : const Color(0xFF0A0E14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00D4AA),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _pattern.length >= 4 ? _nextPage : null,
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Seed Phrase Page
  Widget _buildSeedPhrasePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Text(
            'Seed Phrase',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your 15-word recovery phrase. Write it down!',
            style: TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          if (_seedPhrase.isEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  final seed = SeedGenerator();
                  setState(() => _seedPhrase = seed.generateSeedPhrase());
                },
                child: const Text(
                  'Generate Seed Phrase',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131A24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _seedPhrase.split(' ').asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${e.key + 1}.',
                            style: const TextStyle(
                              color: Color(0xFF00D4AA),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _seedPhrase.isNotEmpty ? _nextPage : null,
              child: const Text(
                'I\'ve Saved My Seed Phrase',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Complete Page
  Widget _buildCompletePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Color(0xFF00D4AA),
          ),
          const SizedBox(height: 24),
          const Text(
            'Setup Complete!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PINC ID: $_pincId',
            style: const TextStyle(
              color: Color(0xFF00D4AA),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your device is now secured',
            style: TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () {
                // TODO: Navigate to main app
              },
              child: const Text(
                'Enter THE PLATFORM',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PIN Input Widget
  Widget _buildPinInput({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < value.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF131A24),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF00D4AA),
              width: 2,
            ),
          ),
          child: Center(
            child: isFilled
                ? const Icon(
                    Icons.circle,
                    color: Color(0xFF00D4AA),
                    size: 16,
                  )
                : null,
          ),
        );
      }),
    );
  }
}