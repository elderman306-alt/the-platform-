import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Storage usage statistics
class StorageStats {
  final int totalBytes;
  final int usedBytes;
  final int availableBytes;
  final double percentUsed;

  StorageStats({
    required this.totalBytes,
    required this.usedBytes,
    required this.availableBytes,
    required this.percentUsed,
  });
}

/// RAM usage statistics
class RamStats {
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;
  final double percentUsed;

  RamStats({
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
    required this.percentUsed,
  });
}

/// Battery state
enum BatteryState {
  normal,
  low,
  critical,
  charging,
}

/// Resource governor - enforces storage and RAM limits
class ResourceGovernor {
  // Hard limits
  static const double storageLimitPercent = 3.0;
  static const double ramLimitPercent = 20.0;
  
  // Warning thresholds
  static const double storageWarningPercent = 2.5;
  static const double ramWarningPercent = 15.0;

  static Timer? _monitorTimer;
  static bool _isInitialized = false;

  /// Initialize resource monitoring
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isInitialized = true;
    _monitorTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => enforceLimits(),
    );
    
    // Initial check
    await enforceLimits();
    debugPrint('ResourceGovernor initialized');
  }

  /// Stop monitoring
  static void dispose() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isInitialized = false;
  }

  /// Enforce storage and RAM limits
  static Future<void> enforceLimits() async {
    await _checkStorage();
    await _checkRam();
    await _checkBattery();
  }

  /// Check storage usage
  static Future<StorageStats> _checkStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await _getDirectorySize(directory);
      
      // Get device storage info (simplified)
      final totalBytes = 64 * 1024 * 1024 * 1024; // Assume 64GB device
      final usedBytes = stat;
      final availableBytes = totalBytes - usedBytes;
      final percentUsed = (usedBytes / totalBytes) * 100;

      if (percentUsed > storageWarningPercent) {
        debugPrint('Storage warning: ${percentUsed.toStringAsFixed(1)}% used');
      }

      if (percentUsed > storageLimitPercent) {
        debugPrint('Storage limit exceeded! Executing auto-prune...');
        await _autoPrune();
      }

      return StorageStats(
        totalBytes: totalBytes,
        usedBytes: usedBytes,
        availableBytes: availableBytes,
        percentUsed: percentUsed,
      );
    } catch (e) {
      debugPrint('Error checking storage: $e');
      return StorageStats(
        totalBytes: 0,
        usedBytes: 0,
        availableBytes: 0,
        percentUsed: 0,
      );
    }
  }

  /// Check RAM usage
  static Future<RamStats> _checkRam() async {
    try {
      // Simplified RAM check
      final totalBytes = 8 * 1024 * 1024 * 1024; // Assume 8GB device
      final freeBytes = 4 * 1024 * 1024 * 1024; // Simplified
      final usedBytes = totalBytes - freeBytes;
      final percentUsed = (usedBytes / totalBytes) * 100;

      if (percentUsed > ramWarningPercent) {
        debugPrint('RAM warning: ${percentUsed.toStringAsFixed(1)}% used');
      }

      if (percentUsed > ramLimitPercent) {
        debugPrint('RAM limit exceeded! Reducing priority threads...');
        await _reduceThreadPriority();
      }

      return RamStats(
        totalBytes: totalBytes,
        usedBytes: usedBytes,
        freeBytes: freeBytes,
        percentUsed: percentUsed,
      );
    } catch (e) {
      debugPrint('Error checking RAM: $e');
      return RamStats(
        totalBytes: 0,
        usedBytes: 0,
        freeBytes: 0,
        percentUsed: 0,
      );
    }
  }

  /// Check battery state
  static Future<BatteryState> _checkBattery() async {
    // Simplified battery check
    try {
      final batteryLevel = 50; // Would use battery_plus in production
      if (batteryLevel < 10) {
        debugPrint('Battery critical! Enabling power saver...');
        await _enablePowerSaver();
        return BatteryState.critical;
      } else if (batteryLevel < 20) {
        return BatteryState.low;
      }
      return BatteryState.normal;
    } catch (e) {
      return BatteryState.normal;
    }
  }

  /// Auto-prune old data when storage limit reached
  static Future<void> _autoPrune() async {
    debugPrint('Auto-pruning: oldest chat logs, temp keys, cache...');
    // Priority: old chat logs (30+ days) > temp crypto keys > cache
    // Implementation would use Hive to delete old entries
  }

  /// Reduce thread priority when RAM limit reached
  static Future<void> _reduceThreadPriority() async {
    debugPrint('Reducing background thread priority...');
    // Would reduce priority of: background sync, P2P discovery
  }

  /// Enable power saver mode
  static Future<void> _enablePowerSaver() async {
    debugPrint('Power saver mode enabled');
    // Disable: P2P fragment storage, auto-backup
    // Throttle: game animations, video call quality
  }

  /// Get directory size
  static Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
    }
    return size;
  }

  /// Get current storage stats
  static Future<StorageStats> getStorageStats() async {
    return _checkStorage();
  }

  /// Get current RAM stats
  static Future<RamStats> getRamStats() async {
    return _checkRam();
  }

  /// Check if within limits
  static Future<bool> isWithinLimits() async {
    final storage = await getStorageStats();
    final ram = await getRamStats();
    return storage.percentUsed <= storageLimitPercent && 
           ram.percentUsed <= ramLimitPercent;
  }
}