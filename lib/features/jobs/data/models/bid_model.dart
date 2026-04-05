// Bid status enum
enum BidStatus {
  pending,
  accepted,
  rejected,
  withdrawn,
  withdrawnByAdmin,
}

// Bid model
class Bid {
  final String id;
  final String jobId;
  final String bidderId;
  final String bidderName;
  final double proposedAmount;
  final int deliveryDays;
  final String proposal;
  final DateTime createdAt;
  final BidStatus status;
  final int revisionsUsed; // Max 3 allowed

  const Bid({
    required this.id,
    required this.jobId,
    required this.bidderId,
    required this.bidderName,
    required this.proposedAmount,
    required this.deliveryDays,
    required this.proposal,
    required this.createdAt,
    required this.status,
    this.revisionsUsed = 0,
  });

  Bid copyWith({
    String? id,
    String? jobId,
    String? bidderId,
    String? bidderName,
    double? proposedAmount,
    int? deliveryDays,
    String? proposal,
    DateTime? createdAt,
    BidStatus? status,
    int? revisionsUsed,
  }) {
    return Bid(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      bidderId: bidderId ?? this.bidderId,
      bidderName: bidderName ?? this.bidderName,
      proposedAmount: proposedAmount ?? this.proposedAmount,
      deliveryDays: deliveryDays ?? this.deliveryDays,
      proposal: proposal ?? this.proposal,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      revisionsUsed: revisionsUsed ?? this.revisionsUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'proposedAmount': proposedAmount,
      'deliveryDays': deliveryDays,
      'proposal': proposal,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'revisionsUsed': revisionsUsed,
    };
  }

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      bidderId: json['bidderId'] as String,
      bidderName: json['bidderName'] as String,
      proposedAmount: (json['proposedAmount'] as num).toDouble(),
      deliveryDays: json['deliveryDays'] as int,
      proposal: json['proposal'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: BidStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BidStatus.pending,
      ),
      revisionsUsed: json['revisionsUsed'] as int? ?? 0,
    );
  }
}