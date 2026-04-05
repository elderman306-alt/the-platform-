import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Jobs Security & Performance Services
/// Provides encryption, verification, and performance for job marketplace

class JobsSecurity {
  /// Hash job data for integrity
  static String hashJobData(String jobId, String data) {
    final combined = '$jobId:$data';
    final hash = sha256.convert(utf8.encode(combined));
    return hash.toString();
  }
  
  /// Verify job integrity
  static bool verifyJobIntegrity(String jobId, String data, String expectedHash) {
    final actual = hashJobData(jobId, data);
    return actual == expectedHash;
  }
  
  /// Encrypt bid data
  static String encryptBid(String bidData, String key) {
    final keyBytes = utf8.encode(key);
    final dataBytes = utf8.encode(bidData);
    final encrypted = <int>[];
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return base64Encode(encrypted);
  }
  
  /// Decrypt bid data
  static String decryptBid(String encrypted, String key) {
    final keyBytes = utf8.encode(key);
    final encBytes = base64Decode(encrypted);
    final decrypted = <int>[];
    for (int i = 0; i < encBytes.length; i++) {
      decrypted.add(encBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return utf8.decode(decrypted);
  }
  
  /// Generate secure bid ID
  static String generateBidId(String jobId, String freelancerId) {
    final data = '$jobId:$freelancerId:${DateTime.now().millisecondsSinceEpoch}';
    final hash = sha256.convert(utf8.encode(data));
    return hash.toString().substring(0, 16);
  }
  
  /// Calculate dispute resolution hash
  static String hashDisputeResolution(String evidence) {
    final hash = sha256.convert(utf8.encode(evidence));
    return hash.toString();
  }
}

/// Jobs Performance Manager
class JobsPerformanceManager {
  static const int maxParallelJobs = 8;
  static const int cacheExpiryHours = 24;
  
  /// Get recommended batch size for job listing
  static int getRecommendedBatchSize() {
    return 20;
  }
  
  /// Calculate optimal search result limit
  static int getSearchResultLimit() {
    return 50;
  }
  
  /// Check if should paginate
  static bool shouldPaginate(int totalResults) {
    return totalResults > getSearchResultLimit();
  }
}

/// Jobs Fee Calculator (matches financial module)
class JobsFeeCalculator {
  static const double postingFeePercent = 0.03; // 3%
  static const double payoutFeePercent = 0.09; // 9%
  
  /// Calculate posting fee
  static double calculatePostingFee(double budget) {
    return budget * postingFeePercent;
  }
  
  /// Calculate payout fee (deducted from freelancer)
  static double calculatePayoutFee(double amount) {
    return amount * payoutFeePercent;
  }
  
  /// Calculate net payout (after fee)
  static double calculateNetPayout(double grossAmount) {
    final fee = calculatePayoutFee(grossAmount);
    return grossAmount - fee;
  }
  
  /// Calculate total (employer pays posting + amount)
  static double calculateTotalRequired(double budget, double escrowAmount) {
    return calculatePostingFee(budget) + escrowAmount;
  }
}

/// Jobs Cache Manager
class JobsCacheManager {
  final Map<String, _CacheEntry> _cache = {};
  
  void cache(String key, dynamic value, {int ttlHours = 24}) {
    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(Duration(hours: ttlHours)),
    );
  }
  
  dynamic? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }
  
  void clear() => _cache.clear();
  void remove(String key) => _cache.remove(key);
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;
  _CacheEntry({required this.value, required this.expiresAt});
}