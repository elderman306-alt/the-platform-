// App Configuration
// THE PLATFORM - PINC Network

class AppConfig {
  // App Info
  static const String appName = 'THE PLATFORM';
  static const String appVersion = '1.0.0';
  static const String network = 'PINC Network';
  
  // Security Requirements
  static const int minSecurityLevel = 1;
  static const int maxSecurityLevel = 5;
  
  // Resource Limits
  static const double maxRAM = 0.20;        // 20% of device RAM
  static const double maxStorage = 0.03;    // 3% of storage
  static const int maxThreads = 8;
  static const double batteryMin = 0.15;    // StopP2P at 15% battery
  
  // Network
  static const int maxPeers = 100;
  static const int minPeers = 3;
  static const int connectionTimeout = 30;
  static const int heartbeatInterval = 60;
  
  // Fees
  static const double internalTransferFee = 0.0;
  static const double depositFee = 0.0;
  static const double withdrawalFee = 3.0;   // 3 PINC
  static const double jobEscrowFee = 0.03;   // 3%
  static const double jobPayoutFee = 0.09;    // 9%
  static const double bettingFee = 0.07;     // 7%
  static const double bettingCreatorFee = 0.05; // 5%
  
  // Timing
  static const int escrowReleaseDays = 7;
  static const int transactionExpiryDays = 365;
  static const int freeBidsPerMonth = 15;
  
  // Security Triggers
  static const List<String> selfDestructTriggers = [
    'rootDetected',
    'debuggerAttached',
    'emulatorDetected',
    'decompilationAttempt',
    'unauthorizedMemoryAccess',
    'tamperedBinaryHash',
  ];
  
  // API Endpoints
  static const String p2pServer = 'wss://pinc-network.io';
  static const String paymentServer = 'https://payment.pinc.io';
  static const String updateServer = 'https://update.pinc.io';
}