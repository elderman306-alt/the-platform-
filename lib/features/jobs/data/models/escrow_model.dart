// Escrow status enum
enum EscrowStatus {
  pending,
  funded,
  released,
  refunded,
  dispute,
}

// Escrow model for job payments
class JobEscrow {
  final String id;
  final String jobId;
  final String bidId;
  final String employerId;
  final String freelancerId;
  final double amount;
  final double platformFee; // 3% for job posting, 9% for payout
  final double totalAmount;
  final DateTime createdAt;
  final EscrowStatus status;
  final List<WorkSubmission> submissions;
  final String? disputeId;

  const JobEscrow({
    required this.id,
    required this.jobId,
    required this.bidId,
    required this.employerId,
    required this.freelancerId,
    required this.amount,
    required this.platformFee,
    required this.totalAmount,
    required this.createdAt,
    required this.status,
    this.submissions = const [],
    this.disputeId,
  });

  JobEscrow copyWith({
    String? id,
    String? jobId,
    String? bidId,
    String? employerId,
    String? freelancerId,
    double? amount,
    double? platformFee,
    double? totalAmount,
    DateTime? createdAt,
    EscrowStatus? status,
    List<WorkSubmission>? submissions,
    String? disputeId,
  }) {
    return JobEscrow(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      bidId: bidId ?? this.bidId,
      employerId: employerId ?? this.employerId,
      freelancerId: freelancerId ?? this.freelancerId,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      submissions: submissions ?? this.submissions,
      disputeId: disputeId ?? this.disputeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'bidId': bidId,
      'employerId': employerId,
      'freelancerId': freelancerId,
      'amount': amount,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'submissions': submissions.map((s) => s.toJson()).toList(),
      'disputeId': disputeId,
    };
  }

  factory JobEscrow.fromJson(Map<String, dynamic> json) {
    return JobEscrow(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      bidId: json['bidId'] as String,
      employerId: json['employerId'] as String,
      freelancerId: json['freelancerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: EscrowStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EscrowStatus.pending,
      ),
      submissions: (json['submissions'] as List<dynamic>?)
              ?.map((e) => WorkSubmission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      disputeId: json['disputeId'] as String?,
    );
  }
}

// Work submission model
class WorkSubmission {
  final String id;
  final String escrowId;
  final String freelancerId;
  final String description;
  final List<String> attachments; // URLs to files
  final DateTime submittedAt;
  final int revisionNumber;
  final String? feedback;

  const WorkSubmission({
    required this.id,
    required this.escrowId,
    required this.freelancerId,
    required this.description,
    required this.attachments,
    required this.submittedAt,
    required this.revisionNumber,
    this.feedback,
  });

  WorkSubmission copyWith({
    String? id,
    String? escrowId,
    String? freelancerId,
    String? description,
    List<String>? attachments,
    DateTime? submittedAt,
    int? revisionNumber,
    String? feedback,
  }) {
    return WorkSubmission(
      id: id ?? this.id,
      escrowId: escrowId ?? this.escrowId,
      freelancerId: freelancerId ?? this.freelancerId,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      submittedAt: submittedAt ?? this.submittedAt,
      revisionNumber: revisionNumber ?? this.revisionNumber,
      feedback: feedback ?? this.feedback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'escrowId': escrowId,
      'freelancerId': freelancerId,
      'description': description,
      'attachments': attachments,
      'submittedAt': submittedAt.toIso8601String(),
      'revisionNumber': revisionNumber,
      'feedback': feedback,
    };
  }

  factory WorkSubmission.fromJson(Map<String, dynamic> json) {
    return WorkSubmission(
      id: json['id'] as String,
      escrowId: json['escrowId'] as String,
      freelancerId: json['freelancerId'] as String,
      description: json['description'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      revisionNumber: json['revisionNumber'] as int,
      feedback: json['feedback'] as String?,
    );
  }
}