// 🔷 THE PLATFORM - Core Constants
// Security, Platform, and Feature Constants

/// ==========================================
/// SECURITY CONSTANTS
/// ==========================================

/// PIN Configuration
class PinConstants {
  static const int pinLength = 6;
  static const int minPinLength = 4;
  static const int maxPinLength = 8;
  static const int pinAttemptsMax = 5;
  static const Duration pinLockoutDuration = Duration(minutes: 5);
}

/// Pattern Lock Configuration
class PatternConstants {
  static const int gridSize = 5; // 5x5 grid
  static const int minPatternLength = 4;
  static const int maxPatternLength = 9;
  static const int patternAttemptsMax = 3;
}

/// Biometric Configuration
class BiometricConstants {
  static const bool requireBiometricForSetup = true;
  static const Duration biometricTimeout = Duration(minutes: 5);
}

/// Transaction Auth Thresholds
class TransactionThresholds {
  static const int pinMaxAmount = 100; // PIN for amounts < 100 PINC
  static const int patternMaxAmount = 10000; // Pattern/Biometric for 100-10,000 PINC
  // > 10,000 PINC requires Private Key
}

/// Security Thresholds
class SecurityThresholds {
  static const int antiTheftLockThreshold = 3;
  static const int selfDestructAttempts = 1;
  static const int uninstallProtectionAttempts = 3;
}

/// ==========================================
/// PINC ID CONSTANTS
/// ==========================================

class PincIdConstants {
  static const String prefix = 'PINC';
  static const int idLength = 8; // 8 characters after PINC-
  static const String regex = r'^PINC-[A-Z0-9]{8}$';
  static const String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
}

/// ==========================================
/// PLATFORM CONSTANTS
/// ==========================================

class PlatformConstants {
  static const String appName = 'THE PLATFORM';
  static const String appVersion = '1.0.0';
  static const int platformFeeMonthly = 325; // PINC/month
}

/// ==========================================
/// UI CONSTANTS
/// ==========================================

class ThemeConstants {
  // Color Scheme (Dark Theme)
  static const int primaryColor = 0xFF00D4AA;
  static const int secondaryColor = 0xFF7B61FF;
  static const int backgroundColor = 0xFF0A0E14;
  static const int surfaceColor = 0xFF131A24;
  static const int errorColor = 0xFFFF4757;
  static const int textPrimary = 0xFFFFFFFF;
  static const int textSecondary = 0xFFB0B0B0;
}

/// ==========================================
/// FEE CONSTANTS
/// ==========================================

class FeeConstants {
  static const int withdrawalMinFee = 3;
  static const int withdrawalMaxFee = 103;
  static const double jobPostFeePercent = 0.03;
  static const double jobPayoutFeePercent = 0.09;
  static const double betFeePercent = 0.07;
  static const double betCreatorFeePercent = 0.05;
  static const int betMinAmount = 20;
  static const double fundraisingFeePercent = 0.09;
}

/// ==========================================
/// GAME CONSTANTS
/// ==========================================

class GameConstants {
  static const int minWagerAmount = 20;
  static const int leagueMaxPlayers = 50;
  static const int challengeFee = 1560;
  static const List<String> builtInGames = [
    'Connect 4',
    'Tic Tac Toe',
    'Memory Match',
    'Snake',
    'Pong',
    'Wordle',
  ];
}