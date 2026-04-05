import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// SLA Status
enum SLAStatus {
  healthy,
  warning,
  critical,
  breached,
}

/// SLA metric types
enum SLAMetricType {
  uptime,
  responseTime,
  deliveryRate,
  satisfaction,
}

/// SLA metric record
class SLAMetric {
  final String metricId;
  final SLAMetricType type;
  final double value;
  final double target;
  final DateTime recordedAt;

  SLAMetric({
    required this.metricId,
    required this.type,
    required this.value,
    required this.target,
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();

  bool get isMet => value >= target;
  double get achievement => target > 0 ? (value / target * 100).clamp(0, 150) : 0;
}

/// SLA record for a seller
class SLARecord {
  final String sellerId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final SLAMetric uptime;
  final SLAMetric responseTime;
  final SLAMetric deliveryRate;
  final SLAMetric satisfaction;
  final SLAStatus overallStatus;

  SLARecord({
    required this.sellerId,
    required this.periodStart,
    required this.periodEnd,
    required this.uptime,
    required this.responseTime,
    required this.deliveryRate,
    required this.satisfaction,
    required this.overallStatus,
  });

  Map<String, dynamic> toJson() => {
    'sellerId': sellerId,
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'uptime': _metricToJson(uptime),
    'responseTime': _metricToJson(responseTime),
    'deliveryRate': _metricToJson(deliveryRate),
    'satisfaction': _metricToJson(satisfaction),
    'overallStatus': overallStatus.name,
  };

  Map<String, dynamic> _metricToJson(SLAMetric m) => {
    'metricId': m.metricId,
    'type': m.type.name,
    'value': m.value,
    'target': m.target,
    'achievement': m.achievement,
  };
}

/// Service for tracking SLA metrics
class SLATrackerService {
  final Map<String, List<SLARecord>> _sellerRecords = {};
  final _recordController = StreamController<List<SLARecord>>.broadcast();
  
  // Target values
  static const double uptimeTarget = 87.0;  // 87% uptime
  static const double responseTimeTarget = 5000; // 5 seconds
  static const double deliveryRateTarget = 95.0; // 95%
  static const double satisfactionTarget = 4.0; // 4 stars
  
  Stream<List<SLARecord>> get recordStream => _recordController.stream;

  /// Record an SLA metric
  SLAMetric recordMetric({
    required String metricId,
    required SLAMetricType type,
    required double value,
  }) {
    double target;
    switch (type) {
      case SLAMetricType.uptime:
        target = uptimeTarget;
        break;
      case SLAMetricType.responseTime:
        target = responseTimeTarget;
        break;
      case SLAMetricType.deliveryRate:
        target = deliveryRateTarget;
        break;
      case SLAMetricType.satisfaction:
        target = satisfactionTarget;
        break;
    }

    return SLAMetric(
      metricId: metricId,
      type: type,
      value: value,
      target: target,
    );
  }

  /// Calculate SLA status from metrics
  SLAStatus calculateStatus({
    required double uptime,
    required double responseTime,
    required double deliveryRate,
    required double satisfaction,
  }) {
    int warnings = 0;
    
    if (uptime < uptimeTarget) warnings++;
    if (responseTime > responseTimeTarget) warnings++;
    if (deliveryRate < deliveryRateTarget) warnings++;
    if (satisfaction < satisfactionTarget * 0.8) warnings++;

    if (warnings >= 3) return SLAStatus.breached;
    if (warnings >= 2) return SLAStatus.critical;
    if (warnings >= 1) return SLAStatus.warning;
    return SLAStatus.healthy;
  }

  /// Create SLA record for a seller
  Future<SLARecord> createRecord({
    required String sellerId,
    required double uptime,
    required double responseTime,
    required double deliveryRate,
    required double satisfaction,
  }) async {
    final uptimeMetric = recordMetric(
      metricId: '${sellerId}_uptime',
      type: SLAMetricType.uptime,
      value: uptime,
    );

    final responseMetric = recordMetric(
      metricId: '${sellerId}_response',
      type: SLAMetricType.responseTime,
      value: responseTime,
    );

    final deliveryMetric = recordMetric(
      metricId: '${sellerId}_delivery',
      type: SLAMetricType.deliveryRate,
      value: deliveryRate,
    );

    final satisfactionMetric = recordMetric(
      metricId: '${sellerId}_satisfaction',
      type: SLAMetricType.satisfaction,
      value: satisfaction,
    );

    final status = calculateStatus(
      uptime: uptime,
      responseTime: responseTime,
      deliveryRate: deliveryRate,
      satisfaction: satisfaction,
    );

    final now = DateTime.now();
    final record = SLARecord(
      sellerId: sellerId,
      periodStart: now.subtract(const Duration(days: 30)),
      periodEnd: now,
      uptime: uptimeMetric,
      responseTime: responseMetric,
      deliveryRate: deliveryMetric,
      satisfaction: satisfactionMetric,
      overallStatus: status,
    );

    _sellerRecords.putIfAbsent(sellerId, () => []);
    _sellerRecords[sellerId]!.add(record);
    _recordController.add(_sellerRecords[sellerId]!);

    debugPrint('Created SLA record for $sellerId: ${status.name}');
    return record;
  }

  /// Get SLA records for a seller
  List<SLARecord> getRecords(String sellerId) => 
    _sellerRecords[sellerId] ?? [];

  /// Get latest SLA record
  SLARecord? getLatestRecord(String sellerId) {
    final records = _sellerRecords[sellerId];
    if (records == null || records.isEmpty) return null;
    return records.last;
  }

  /// Check if seller meets SLA
  bool meetsSLA(String sellerId) {
    final record = getLatestRecord(sellerId);
    if (record == null) return true;
    return record.overallStatus == SLAStatus.healthy;
  }

  /// Get SLA statistics across all sellers
  Map<String, dynamic> getSLAStats() {
    final allRecords = _sellerRecords.values.expand((r) => r).toList();
    if (allRecords.isEmpty) {
      return {
        'totalRecords': 0,
        'healthy': 0,
        'warning': 0,
        'critical': 0,
        'breached': 0,
      };
    }

    return {
      'totalRecords': allRecords.length,
      'healthy': allRecords.where((r) => r.overallStatus == SLAStatus.healthy).length,
      'warning': allRecords.where((r) => r.overallStatus == SLAStatus.warning).length,
      'critical': allRecords.where((r) => r.overallStatus == SLAStatus.critical).length,
      'breached': allRecords.where((r) => r.overallStatus == SLAStatus.breached).length,
      'complianceRate': _calculateComplianceRate(allRecords),
    };
  }

  double _calculateComplianceRate(List<SLARecord> records) {
    if (records.isEmpty) return 100.0;
    final healthy = records.where((r) => r.overallStatus == SLAStatus.healthy).length;
    return (healthy / records.length) * 100;
  }

  /// Simulate SLA calculation (for demo purposes)
  Future<SLARecord> simulateSLA(String sellerId) async {
    final random = Random();
    final uptime = 70.0 + random.nextDouble() * 30; // 70-100%
    final responseTime = 1000 + random.nextDouble() * 9000; // 1-10s
    final deliveryRate = 80.0 + random.nextDouble() * 20; // 80-100%
    final satisfaction = 3.0 + random.nextDouble() * 2; // 3-5 stars

    return createRecord(
      sellerId: sellerId,
      uptime: uptime,
      responseTime: responseTime,
      deliveryRate: deliveryRate,
      satisfaction: satisfaction,
    );
  }

  void dispose() {
    _recordController.close();
  }
}