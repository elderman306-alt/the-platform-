// Job status enum
enum JobStatus {
  draft,
  open,
  inProgress,
  underReview,
  dispute,
  completed,
  cancelled,
}

// Job model
class Job {
  final String id;
  final String posterId;
  final String title;
  final String description;
  final String category;
  final double budget;
  final double postingFee; // 3% of budget
  final DateTime createdAt;
  final DateTime? deadline;
  final JobStatus status;
  final int bidCount;
  final String? assignedBidId;
  final List<String> requiredSkills;

  const Job({
    required this.id,
    required this.posterId,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.postingFee,
    required this.createdAt,
    this.deadline,
    required this.status,
    this.bidCount = 0,
    this.assignedBidId,
    this.requiredSkills = const [],
  });

  Job copyWith({
    String? id,
    String? posterId,
    String? title,
    String? description,
    String? category,
    double? budget,
    double? postingFee,
    DateTime? createdAt,
    DateTime? deadline,
    JobStatus? status,
    int? bidCount,
    String? assignedBidId,
    List<String>? requiredSkills,
  }) {
    return Job(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      budget: budget ?? this.budget,
      postingFee: postingFee ?? this.postingFee,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      bidCount: bidCount ?? this.bidCount,
      assignedBidId: assignedBidId ?? this.assignedBidId,
      requiredSkills: requiredSkills ?? this.requiredSkills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'posterId': posterId,
      'title': title,
      'description': description,
      'category': category,
      'budget': budget,
      'postingFee': postingFee,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'status': status.name,
      'bidCount': bidCount,
      'assignedBidId': assignedBidId,
      'requiredSkills': requiredSkills,
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      posterId: json['posterId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      budget: (json['budget'] as num).toDouble(),
      postingFee: (json['postingFee'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      status: JobStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => JobStatus.draft,
      ),
      bidCount: json['bidCount'] as int? ?? 0,
      assignedBidId: json['assignedBidId'] as String?,
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}