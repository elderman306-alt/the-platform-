// 🔷 THE PLATFORM - Login Screen
// Authentication screen for returning users

import 'package:flutter/material.dart';
import 'package:the_platform-/core/security/auth_service.dart';
import 'package:the_platform-/core/constants.dart';

/// ==========================================
/// LOGIN SCREEN
/// ==========================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  String _pin = '';
  bool _showPin = false;
  String? _errorMessage;
  bool _isLoading = false;

  // In production, load from secure storage
  String _storedPin = '';

  void _onPinPressed(String digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
        _errorMessage = null;
      });

      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onPinBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_storedPin.isEmpty) {
      // First time - store the PIN
      setState(() {
        _storedPin = _pin;
        _pin = '';
        _showPin = true;
      });
      return;
    }

    setState(() => _isLoading = true);

    final result = _auth.verifyPin(_pin, _storedPin);

    setState(() {
      _isLoading = false;
      if (result.success) {
        // Navigate to app
        _errorMessage = null;
      } else {
        _pin = '';
        _errorMessage = result.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Header
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: Color(0xFF00D4AA),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter PIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFFF4757),
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 32),

            // PIN Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                final isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? const Color(0xFF00D4AA)
                        : Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFF00D4AA),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            const Spacer(),

            // Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['', '0', '⌫']),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // Biometric login
                  },
                  child: const Text(
                    'Use Biometric',
                    style: TextStyle(
                      color: Color(0xFF00D4AA),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    // Pattern login
                  },
                  child: const Text(
                    'Use Pattern',
                    style: TextStyle(
                      color: Color(0xFF00D4AA),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 72, height: 72);
        }
        return _buildKeypadButton(key);
      }).toList(),
    );
  }

  Widget _buildKeypadButton(String key) {
    final isBackspace = key == '⌫';

    return GestureDetector(
      onTap: isBackspace ? _onPinBackspace : () => _onPinPressed(key),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF131A24),
        ),
        child: Center(
          child: isBackspace
              ? const Icon(
                  Icons.backspace_outlined,
                  color: Colors.white,
                  size: 24,
                )
              : Text(
                  key,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}