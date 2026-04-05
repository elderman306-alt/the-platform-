// Dispute status enum
enum DisputeStatus {
  open,
  voting,
  resolved,
  appealed,
}

// Dispute model for job conflicts
class Dispute {
  final String id;
  final String escrowId;
  final String jobId;
  final String raisedBy; // User ID who raised the dispute
  final String against; // User ID being disputed against
  final String reason;
  final String evidence;
  final DateTime createdAt;
  final DisputeStatus status;
  final List<Referee> referees; // 3 random referees
  final String? winnerId;
  final String? resolution;
  final DateTime? resolvedAt;

  const Dispute({
    required this.id,
    required this.escrowId,
    required this.jobId,
    required this.raisedBy,
    required this.against,
    required this.reason,
    required this.evidence,
    required this.createdAt,
    required this.status,
    this.referees = const [],
    this.winnerId,
    this.resolution,
    this.resolvedAt,
  });

  Dispute copyWith({
    String? id,
    String? escrowId,
    String? jobId,
    String? raisedBy,
    String? against,
    String? reason,
    String? evidence,
    DateTime? createdAt,
    DisputeStatus? status,
    List<Referee>? referees,
    String? winnerId,
    String? resolution,
    DateTime? resolvedAt,
  }) {
    return Dispute(
      id: id ?? this.id,
      escrowId: escrowId ?? this.escrowId,
      jobId: jobId ?? this.jobId,
      raisedBy: raisedBy ?? this.raisedBy,
      against: against ?? this.against,
      reason: reason ?? this.reason,
      evidence: evidence ?? this.evidence,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      referees: referees ?? this.referees,
      winnerId: winnerId ?? this.winnerId,
      resolution: resolution ?? this.resolution,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'escrowId': escrowId,
      'jobId': jobId,
      'raisedBy': raisedBy,
      'against': against,
      'reason': reason,
      'evidence': evidence,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'referees': referees.map((r) => r.toJson()).toList(),
      'winnerId': winnerId,
      'resolution': resolution,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'] as String,
      escrowId: json['escrowId'] as String,
      jobId: json['jobId'] as String,
      raisedBy: json['raisedBy'] as String,
      against: json['against'] as String,
      reason: json['reason'] as String,
      evidence: json['evidence'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: DisputeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DisputeStatus.open,
      ),
      referees: (json['referees'] as List<dynamic>?)
              ?.map((e) => Referee.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      winnerId: json['winnerId'] as String?,
      resolution: json['resolution'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }
}

// Referee model - randomly selected to resolve disputes
class Referee {
  final String id;
  final String userId;
  final String userName;
  final String? vote; // 'employer' or 'freelancer'
  final DateTime? votedAt;
  final String? voteReason;

  const Referee({
    required this.id,
    required this.userId,
    required this.userName,
    this.vote,
    this.votedAt,
    this.voteReason,
  });

  Referee copyWith({
    String? id,
    String? userId,
    String? userName,
    String? vote,
    DateTime? votedAt,
    String? voteReason,
  }) {
    return Referee(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      vote: vote ?? this.vote,
      votedAt: votedAt ?? this.votedAt,
      voteReason: voteReason ?? this.voteReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'vote': vote,
      'votedAt': votedAt?.toIso8601String(),
      'voteReason': voteReason,
    };
  }

  factory Referee.fromJson(Map<String, dynamic> json) {
    return Referee(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      vote: json['vote'] as String?,
      votedAt: json['votedAt'] != null
          ? DateTime.parse(json['votedAt'] as String)
          : null,
      voteReason: json['voteReason'] as String?,
    );
  }
}