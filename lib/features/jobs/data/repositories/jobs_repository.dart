import 'job_model.dart';
import 'bid_model.dart';
import 'escrow_model.dart';
import 'dispute_model.dart';

/// Jobs Repository - handles all job-related data operations
/// Note: This is a stub. In production, this would connect to blockchain/p2p storage
class JobsRepository {
  // In-memory storage (would be replaced with blockchain/p2p storage)
  final Map<String, Job> _jobs = {};
  final Map<String, Bid> _bids = {};
  final Map<String, JobEscrow> _escrows = {};
  final Map<String, Dispute> _disputes = {};

  // Bid limit tracking per user
  final Map<String, int> _bidCountPerUser = {};
  final Map<String, DateTime> _bidResetDate = {};

  // Fee constants
  static const double jobPostingFeePercent = 0.03; // 3%
  static const double payoutFeePercent = 0.09; // 9%
  static const int freeBidsPerMonth = 15;
  static const int unlimitedBidPackageCost = 300;

  /// Create a new job posting
  Future<Job> createJob({
    required String posterId,
    required String title,
    required String description,
    required String category,
    required double budget,
    DateTime? deadline,
    List<String>? requiredSkills,
  }) async {
    final postingFee = budget * jobPostingFeePercent;
    final job = Job(
      id: _generateId(),
      posterId: posterId,
      title: title,
      description: description,
      category: category,
      budget: budget,
      postingFee: postingFee,
      createdAt: DateTime.now(),
      deadline: deadline,
      status: JobStatus.open,
      requiredSkills: requiredSkills ?? [],
    );
    _jobs[job.id] = job;
    return job;
  }

  /// Get all open jobs
  Future<List<Job>> getOpenJobs() async {
    return _jobs.values
        .where((job) => job.status == JobStatus.open)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get jobs by category
  Future<List<Job>> getJobsByCategory(String category) async {
    return _jobs.values
        .where((job) => job.category == category && job.status == JobStatus.open)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get jobs for a specific poster
  Future<List<Job>> getJobsByPoster(String posterId) async {
    return _jobs.values
        .where((job) => job.posterId == posterId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get a specific job by ID
  Future<Job?> getJob(String jobId) async {
    return _jobs[jobId];
  }

  /// Update job status
  Future<Job?> updateJobStatus(String jobId, JobStatus status) async {
    final job = _jobs[jobId];
    if (job != null) {
      _jobs[jobId] = job.copyWith(status: status);
      return _jobs[jobId];
    }
    return null;
  }

  /// Check if user can bid (free bids: 15/month, unlimited: +300 PINC)
  bool canBid(String userId) {
    _resetBidCountIfNeeded(userId);
    return _bidCountPerUser[userId] ?? 0 < freeBidsPerMonth;
  }

  /// Get remaining free bids for user
  int getRemainingFreeBids(String userId) {
    _resetBidCountIfNeeded(userId);
    return freeBidsPerMonth - (_bidCountPerUser[userId] ?? 0);
  }

  /// Bid on a job
  Future<Bid?> placeBid({
    required String jobId,
    required String bidderId,
    required String bidderName,
    required double proposedAmount,
    required int deliveryDays,
    required String proposal,
  }) async {
    if (!canBid(bidderId)) {
      // User has exceeded free bid limit
      return null;
    }

    final job = _jobs[jobId];
    if (job == null || job.status != JobStatus.open) {
      return null;
    }

    final bid = Bid(
      id: _generateId(),
      jobId: jobId,
      bidderId: bidderId,
      bidderName: bidderName,
      proposedAmount: proposedAmount,
      deliveryDays: deliveryDays,
      proposal: proposal,
      createdAt: DateTime.now(),
      status: BidStatus.pending,
    );

    _bids[bid.id] = bid;

    // Increment user's bid count
    _bidCountPerUser[bidderId] = (_bidCountPerUser[bidderId] ?? 0) + 1;

    // Update job bid count
    _jobs[jobId] = job.copyWith(bidCount: job.bidCount + 1);

    return bid;
  }

  /// Get bids for a job
  Future<List<Bid>> getBidsForJob(String jobId) async {
    return _bids.values
        .where((bid) => bid.jobId == jobId)
        .toList()
      ..sort((a, b) => a.proposedAmount.compareTo(b.proposedAmount));
  }

  /// Accept a bid
  Future<JobEscrow?> acceptBid(String bidId) async {
    final bid = _bids[bidId];
    if (bid == null || bid.status != BidStatus.pending) {
      return null;
    }

    final job = _jobs[bid.jobId];
    if (job == null) {
      return null;
    }

    // Update bid status
    _bids[bidId] = bid.copyWith(status: BidStatus.accepted);

    // Update job status and assigned bid
    _jobs[bid.jobId] = job.copyWith(
      status: JobStatus.inProgress,
      assignedBidId: bidId,
    );

    // Reject all other bids
    for (final otherBid in _bids.values) {
      if (otherBid.jobId == bid.jobId && otherBid.id != bidId) {
        _bids[otherBid.id] = otherBid.copyWith(status: BidStatus.rejected);
      }
    }

    // Create escrow
    final platformFee = bid.proposedAmount * payoutFeePercent;
    final escrow = JobEscrow(
      id: _generateId(),
      jobId: bid.jobId,
      bidId: bidId,
      employerId: job.posterId,
      freelancerId: bid.bidderId,
      amount: bid.proposedAmount,
      platformFee: platformFee,
      totalAmount: bid.proposedAmount + platformFee,
      createdAt: DateTime.now(),
      status: EscrowStatus.pending,
    );

    _escrows[escrow.id] = escrow;
    return escrow;
  }

  /// Fund escrow (employer pays into escrow)
  Future<JobEscrow?> fundEscrow(String escrowId) async {
    final escrow = _escrows[escrowId];
    if (escrow == null || escrow.status != EscrowStatus.pending) {
      return null;
    }

    _escrows[escrowId] = escrow.copyWith(status: EscrowStatus.funded);
    return _escrows[escrowId];
  }

  /// Submit work
  Future<WorkSubmission?> submitWork({
    required String escrowId,
    required String freelancerId,
    required String description,
    List<String>? attachments,
  }) async {
    final escrow = _escrows[escrowId];
    if (escrow == null || 
        escrow.status != EscrowStatus.funded ||
        escrow.freelancerId != freelancerId) {
      return null;
    }

    final currentRevisions = escrow.submissions.length;
    if (currentRevisions >= 3) {
      // Max 3 revisions reached
      return null;
    }

    final submission = WorkSubmission(
      id: _generateId(),
      escrowId: escrowId,
      freelancerId: freelancerId,
      description: description,
      attachments: attachments ?? [],
      submittedAt: DateTime.now(),
      revisionNumber: currentRevisions + 1,
    );

    _escrows[escrowId] = escrow.copyWith(
      submissions: [...escrow.submissions, submission],
    );

    // Update job status
    _jobs[escrow.jobId] = _jobs[escrow.jobId]!.copyWith(status: JobStatus.underReview);

    return submission;
  }

  /// Review work submission (employer approves or requests revision)
  Future<bool> reviewSubmission({
    required String escrowId,
    required String employerId,
    required int submissionIndex,
    required bool approved,
    String? feedback,
  }) async {
    final escrow = _escrows[escrowId];
    if (escrow == null || escrow.employerId != employerId) {
      return false;
    }

    if (submissionIndex < 0 || submissionIndex >= escrow.submissions.length) {
      return false;
    }

    final submission = escrow.submissions[submissionIndex];
    
    if (approved) {
      // Approve and release payment
      _escrows[escrowId] = escrow.copyWith(status: EscrowStatus.released);
      _jobs[escrow.jobId] = _jobs[escrow.jobId]!.copyWith(status: JobStatus.completed);
      return true;
    } else {
      // Request revision - update feedback
      _escrows[escrowId] = escrow.copyWith(
        submissions: escrow.submissions.asMap().map((index, sub) {
          if (index == submissionIndex) {
            return MapEntry(index, sub.copyWith(feedback: feedback));
          }
          return MapEntry(index, sub);
        }).values.toList(),
      );
      return true;
    }
  }

  /// Raise a dispute
  Future<Dispute?> raiseDispute({
    required String escrowId,
    required String raisedBy,
    required String reason,
    required String evidence,
  }) async {
    final escrow = _escrows[escrowId];
    if (escrow == null) {
      return null;
    }

    // Determine who the dispute is against
    final against = escrow.employerId == raisedBy 
        ? escrow.freelancerId 
        : escrow.employerId;

    final dispute = Dispute(
      id: _generateId(),
      escrowId: escrowId,
      jobId: escrow.jobId,
      raisedBy: raisedBy,
      against: against,
      reason: reason,
      evidence: evidence,
      createdAt: DateTime.now(),
      status: DisputeStatus.open,
    );

    _disputes[dispute.id] = dispute;

    // Update escrow status
    _escrows[escrowId] = escrow.copyWith(
      status: EscrowStatus.dispute,
      disputeId: dispute.id,
    );

    // Update job status
    _jobs[escrow.jobId] = _jobs[escrow.jobId]!.copyWith(status: JobStatus.dispute);

    return dispute;
  }

  /// Add referees to dispute (randomly selected)
  Future<Dispute?> addRefereesToDispute(String disputeId, List<Referee> referees) async {
    final dispute = _disputes[disputeId];
    if (dispute == null || dispute.status != DisputeStatus.open) {
      return null;
    }

    if (referees.length != 3) {
      return null;
    }

    _disputes[disputeId] = dispute.copyWith(
      status: DisputeStatus.voting,
      referees: referees,
    );

    return _disputes[disputeId];
  }

  /// Vote on dispute (referee casts vote)
  Future<Dispute?> voteOnDispute({
    required String disputeId,
    required String refereeId,
    required String vote, // 'employer' or 'freelancer'
    required String voteReason,
  }) async {
    final dispute = _disputes[disputeId];
    if (dispute == null || dispute.status != DisputeStatus.voting) {
      return null;
    }

    final refereeIndex = dispute.referees.indexWhere((r) => r.id == refereeId);
    if (refereeIndex == -1) {
      return null;
    }

    final updatedReferees = dispute.referees.asMap().map((index, referee) {
      if (index == refereeIndex) {
        return MapEntry(index, referee.copyWith(
          vote: vote,
          votedAt: DateTime.now(),
          voteReason: voteReason,
        ));
      }
      return MapEntry(index, referee);
    }).values.toList();

    _disputes[disputeId] = dispute.copyWith(referees: updatedReferees);

    // Check if all referees have voted
    if (updatedReferees.every((r) => r.vote != null)) {
      _resolveDispute(disputeId);
    }

    return _disputes[disputeId];
  }

  /// Resolve dispute based on votes
  void _resolveDispute(String disputeId) {
    final dispute = _disputes[disputeId];
    if (dispute == null) return;

    final employerVotes = dispute.referees.where((r) => r.vote == 'employer').length;
    final freelancerVotes = dispute.referees.where((r) => r.vote == 'freelancer').length;

    String winnerId;
    if (employerVotes > freelancerVotes) {
      winnerId = dispute.against; // Employer wins, so freelancer (against) gets nothing
    } else if (freelancerVotes > employerVotes) {
      winnerId = dispute.raisedBy; // Freelancer wins
    } else {
      // Tie - employer wins by default
      winnerId = dispute.against;
    }

    _disputes[disputeId] = dispute.copyWith(
      status: DisputeStatus.resolved,
      winnerId: winnerId,
      resolvedAt: DateTime.now(),
      resolution: '$employerVotes employer votes, $freelancerVotes freelancer votes',
    );

    // Update escrow based on winner
    final escrow = _escrows[dispute.escrowId];
    if (escrow != null) {
      if (winnerId == escrow.freelancerId) {
        _escrows[dispute.escrowId] = escrow.copyWith(status: EscrowStatus.released);
      } else {
        _escrows[dispute.escrowId] = escrow.copyWith(status: EscrowStatus.refunded);
      }
    }
  }

  /// Purchase unlimited bid package
  Future<bool> purchaseUnlimitedBids(String userId, double amount) async {
    // This would integrate with the wallet to verify payment
    if (amount < unlimitedBidPackageCost) {
      return false;
    }
    // Mark user as having unlimited bids
    _bidCountPerUser[userId] = freeBidsPerMonth + 1; // Will always allow bidding
    return true;
  }

  /// Get escrow for job
  Future<JobEscrow?> getEscrowForJob(String jobId) async {
    return _escrows.values.where((e) => e.jobId == jobId).firstOrNull;
  }

  /// Get active disputes for user
  Future<List<Dispute>> getDisputesForUser(String userId) async {
    return _disputes.values
        .where((d) => d.raisedBy == userId || d.against == userId)
        .toList();
  }

  /// Reset bid count for new month
  void _resetBidCountIfNeeded(String userId) {
    final now = DateTime.now();
    final resetDate = _bidResetDate[userId];
    
    if (resetDate == null || now.month != resetDate.month) {
      _bidCountPerUser[userId] = 0;
      _bidResetDate[userId] = now;
    }
  }

  /// Generate unique ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}