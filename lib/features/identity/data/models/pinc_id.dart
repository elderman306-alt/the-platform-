// 🔷 THE PLATFORM - PINC ID Model
// Unique 8-character hardware-bound identifier

import 'dart:math';
import 'dart:typed_data';
import 'package:the_platform-/core/constants.dart';

/// ==========================================
/// PINC ID ENTITY
/// ==========================================

class PincId {
  final String id;
  final String deviceFingerprint;
  final DateTime createdAt;
  final DateTime? lastVerified;
  final bool isActive;

  const PincId({
    required this.id,
    required this.deviceFingerprint,
    required this.createdAt,
    this.lastVerified,
    this.isActive = true,
  });

  /// Generate format: PINC-XXXXXXXX
  static String generateFormat(String deviceFingerprint) {
    final chars = PincIdConstants.characters;
    final random = Random(_hashDeviceFingerprint(deviceFingerprint));
    final buffer = StringBuffer('PINC-');

    for (int i = 0; i < PincIdConstants.idLength; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }

  /// Hash device fingerprint for consistent ID generation
  static int _hashDeviceFingerprint(String fingerprint) {
    var hash = 0;
    final bytes = fingerprint.codeUnits;
    for (int i = 0; i < bytes.length; i++) {
      hash = ((hash << 5) - hash) + bytes[i];
      hash = hash & 0xFFFFFFFF;
    }
    return hash;
  }

  /// Create new PINC ID
  factory PincId.create({
    required String deviceFingerprint,
  }) {
    return PincId(
      id: generateFormat(deviceFingerprint),
      deviceFingerprint: deviceFingerprint,
      createdAt: DateTime.now(),
      lastVerified: DateTime.now(),
      isActive: true,
    );
  }

  /// Validate PINC ID format
  static bool isValidFormat(String id) {
    final regex = RegExp(PincIdConstants.regex);
    return regex.hasMatch(id);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceFingerprint': deviceFingerprint,
        'createdAt': createdAt.toIso8601String(),
        'lastVerified': lastVerified?.toIso8601String(),
        'isActive': isActive,
      };

  /// Create from JSON
  factory PincId.fromJson(Map<String, dynamic> json) => PincId(
        id: json['id'] as String,
        deviceFingerprint: json['deviceFingerprint'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastVerified: json['lastVerified'] != null
            ? DateTime.parse(json['lastVerified'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
      );

  /// Copy with modifications
  PincId copyWith({
    String? id,
    String? deviceFingerprint,
    DateTime? createdAt,
    DateTime? lastVerified,
    bool? isActive,
  }) {
    return PincId(
      id: id ?? this.id,
      deviceFingerprint: deviceFingerprint ?? this.deviceFingerprint,
      createdAt: createdAt ?? this.createdAt,
      lastVerified: lastVerified ?? this.lastVerified,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PincId && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PincId($id)';
}

/// ==========================================
/// DEVICE FINGERPRINT
/// ==========================================

class DeviceFingerprint {
  final String hardwareId;
  final String secureEnclaveId;
  final String installationId;
  final DateTime createdAt;

  const DeviceFingerprint({
    required this.hardwareId,
    required this.secureEnclaveId,
    required this.installationId,
    required this.createdAt,
  });

  /// Generate hardware fingerprint
  /// Combines multiple device identifiers
  String get combined => '$hardwareId:$secureEnclaveId:$installationId';

  /// Check if secure enclave is available
  bool get hasSecureEnclave => secureEnclaveId.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'hardwareId': hardwareId,
        'secureEnclaveId': secureEnclaveId,
        'installationId': installationId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DeviceFingerprint.fromJson(Map<String, dynamic> json) =>
      DeviceFingerprint(
        hardwareId: json['hardwareId'] as String,
        secureEnclaveId: json['secureEnclaveId'] as String,
        installationId: json['installationId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}