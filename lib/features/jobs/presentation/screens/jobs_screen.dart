import 'package:flutter/material.dart';
import '../data/models/job_model.dart';
import '../data/models/bid_model.dart';
import '../data/repositories/jobs_repository.dart';

/// Jobs Screen - Main screen for the Jobs feature
/// Displays job listings, allows posting jobs, and managing bids
class JobsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final JobsRepository repository;

  const JobsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.repository,
  });

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Job> _openJobs = [];
  List<Job> _myJobs = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Development',
    'Design',
    'Writing',
    'Marketing',
    'Video',
    'Music',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      final openJobs = await widget.repository.getOpenJobs();
      final myJobs = await widget.repository.getJobsByPoster(widget.userId);
      setState(() {
        _openJobs = openJobs;
        _myJobs = myJobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load jobs');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        backgroundColor: const Color(0xFF131A24),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D4AA),
          tabs: const [
            Tab(text: 'Find Jobs'),
            Tab(text: 'My Jobs'),
            Tab(text: 'Post Job'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindJobsTab(),
          _buildMyJobsTab(),
          _buildPostJobTab(),
        ],
      ),
    );
  }

  Widget _buildFindJobsTab() {
    return Column(
      children: [
        // Category filter
        Container(
          height: 50,
          color: const Color(0xFF0A0E14),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                  selectedColor: const Color(0xFF00D4AA),
                  backgroundColor: const Color(0xFF131A24),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
        // Job list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadJobs,
                  color: const Color(0xFF00D4AA),
                  child: _filteredJobs.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredJobs.length,
                          itemBuilder: (context, index) {
                            return _buildJobCard(_filteredJobs[index]);
                          },
                        ),
                ),
        ),
      ],
    );
  }

  List<Job> get _filteredJobs {
    if (_selectedCategory == 'All') return _openJobs;
    return _openJobs.where((j) => j.category == _selectedCategory).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to post a job!',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
      color: const Color(0xFF131A24),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showJobDetails(job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${job.budget.toStringAsFixed(0)} PINC',
                      style: const TextStyle(
                        color: Color(0xFF00D4AA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: TextStyle(color: Colors.grey[400]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    job.category,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${job.bidCount} bids',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0E14),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _JobDetailsSheet(
            job: job,
            userId: widget.userId,
            userName: widget.userName,
            repository: widget.repository,
            scrollController: scrollController,
            onBidPlaced: _loadJobs,
          );
        },
      ),
    );
  }

  Widget _buildMyJobsTab() {
    if (_myJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No jobs posted yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      color: const Color(0xFF00D4AA),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myJobs.length,
        itemBuilder: (context, index) {
          final job = _myJobs[index];
          return _buildMyJobCard(job);
        },
      ),
    );
  }

  Widget _buildMyJobCard(Job job) {
    Color statusColor;
    String statusText;
    
    switch (job.status) {
      case JobStatus.open:
        statusColor = Colors.green;
        statusText = 'Open';
        break;
      case JobStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'In Progress';
        break;
      case JobStatus.underReview:
        statusColor = Colors.orange;
        statusText = 'Under Review';
        break;
      case JobStatus.dispute:
        statusColor = Colors.red;
        statusText = 'Dispute';
        break;
      case JobStatus.completed:
        statusColor = Colors.purple;
        statusText = 'Completed';
        break;
      case JobStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Draft';
    }

    return Card(
      color: const Color(0xFF131A24),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Budget: ${job.budget.toStringAsFixed(0)} PINC',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(width: 16),
                Text(
                  '${job.bidCount} bids',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostJobTab() {
    return _PostJobForm(
      userId: widget.userId,
      categories: _categories.where((c) => c != 'All').toList(),
      repository: widget.repository,
      onJobPosted: () {
        _showSuccess('Job posted! 3% fee applied.');
        _tabController.animateTo(1);
        _loadJobs();
      },
      onError: _showError,
    );
  }
}

/// Job details bottom sheet
class _JobDetailsSheet extends StatefulWidget {
  final Job job;
  final String userId;
  final String userName;
  final JobsRepository repository;
  final ScrollController scrollController;
  final VoidCallback onBidPlaced;

  const _JobDetailsSheet({
    required this.job,
    required this.userId,
    required this.userName,
    required this.repository,
    required this.scrollController,
    required this.onBidPlaced,
  });

  @override
  State<_JobDetailsSheet> createState() => _JobDetailsSheetState();
}

class _JobDetailsSheetState extends State<_JobDetailsSheet> {
  List<Bid> _bids = [];
  bool _loadingBids = true;

  @override
  void initState() {
    super.initState();
    _loadBids();
  }

  Future<void> _loadBids() async {
    setState(() => _loadingBids = true);
    final bids = await widget.repository.getBidsForJob(widget.job.id);
    setState(() {
      _bids = bids;
      _loadingBids = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: widget.scrollController,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Job title
          Text(
            widget.job.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Budget
          Text(
            '${widget.job.budget.toStringAsFixed(0)} PINC',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4AA),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            widget.job.description,
            style: TextStyle(color: Colors.grey[300]),
          ),
          const SizedBox(height: 16),
          // Details
          Row(
            children: [
              _buildInfoChip(Icons.category, widget.job.category),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.calendar_today, 
                widget.job.deadline != null 
                  ? '${widget.job.deadline!.difference(DateTime.now()).inDays} days left'
                  : 'No deadline'),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.job.requiredSkills.isNotEmpty)
            Wrap(
              spacing: 8,
              children: widget.job.requiredSkills
                  .map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        backgroundColor: const Color(0xFF131A24),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 24),
          // Bid button
          if (widget.job.posterId != widget.userId)
            ElevatedButton(
              onPressed: () => _showBidDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Place Bid',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 24),
          // Bids section
          if (widget.job.posterId == widget.userId) ...[
            const Text(
              'Bids',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (_loadingBids)
              const Center(child: CircularProgressIndicator())
            else if (_bids.isEmpty)
              Text('No bids yet', style: TextStyle(color: Colors.grey[500]))
            else
              ..._bids.map((bid) => _buildBidCard(bid)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF131A24),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBidCard(Bid bid) {
    return Card(
      color: const Color(0xFF131A24),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bid.bidderName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${bid.proposedAmount.toStringAsFixed(0)} PINC',
                  style: const TextStyle(
                    color: Color(0xFF00D4AA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              bid.proposal,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${bid.deliveryDays} days',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (widget.job.status == JobStatus.open &&
                    bid.status == BidStatus.pending)
                  TextButton(
                    onPressed: () => _acceptBid(bid),
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: Color(0xFF00D4AA)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBidDialog() {
    final amountController = TextEditingController();
    final daysController = TextEditingController();
    final proposalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131A24),
        title: const Text('Place Bid', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your bid (PINC)',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: Color(0xFF00D4AA),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Delivery days',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: Color(0xFF00D4AA),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: proposalController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your proposal',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: Color(0xFF00D4AA),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              final days = int.tryParse(daysController.text);
              final proposal = proposalController.text;

              if (amount == null || days == null || proposal.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final bid = await widget.repository.placeBid(
                jobId: widget.job.id,
                bidderId: widget.userId,
                bidderName: widget.userName,
                proposedAmount: amount,
                deliveryDays: days,
                proposal: proposal,
              );

              if (bid != null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bid placed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                widget.onBidPlaced();
                _loadBids();
              } else {
                final remaining = widget.repository.getRemainingFreeBids(widget.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot bid. $remaining free bids remaining. Buy unlimited for 300 PINC.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
            ),
            child: const Text('Submit Bid', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptBid(Bid bid) async {
    final escrow = await widget.repository.acceptBid(bid.id);
    if (escrow != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bid accepted! Escrow created.'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onBidPlaced();
    }
  }
}

/// Post job form
class _PostJobForm extends StatefulWidget {
  final String userId;
  final List<String> categories;
  final JobsRepository repository;
  final VoidCallback onJobPosted;
  final Function(String) onError;

  const _PostJobForm({
    required this.userId,
    required this.categories,
    required this.repository,
    required this.onJobPosted,
    required this.onError,
  });

  @override
  State<_PostJobForm> createState() => _PostJobFormState();
}

class _PostJobFormState extends State<_PostJobForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _skillsController = TextEditingController();
  
  String _selectedCategory = 'Development';
  DateTime? _deadline;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final budget = double.parse(_budgetController.text);
      final postingFee = budget * JobsRepository.jobPostingFeePercent;

      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await widget.repository.createJob(
        posterId: widget.userId,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        budget: budget,
        deadline: _deadline,
        requiredSkills: skills,
      );

      widget.onJobPosted();
    } catch (e) {
      widget.onError('Failed to post job: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post a New Job',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '3% platform fee applies',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            // Title
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Job Title',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: Color(0xFF00D4AA),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: const Color(0xFF131A24),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: Color(0xFF00D4AA),
                ),
              ),
              items: widget.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 16),
            // Budget
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Budget (PINC)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: Color(0xFF00D4AA),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget';
                }
                final budget = double.tryParse(value);
                if (budget == null || budget <= 0) {
                  return 'Please enter a valid budget';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Deadline
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _deadline != null
                    ? 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                    : 'Set Deadline (Optional)',
                style: TextStyle(color: Colors.grey[400]),
              ),
              trailing: Icon(Icons.calendar_today, color: Colors.grey[400]),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _deadline = date);
                }
              },
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Job Description',
                labelStyle: TextStyle(color: Colors.grey[400]),
                alignLabelWithHint: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: Color(0xFF00D4AA),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Skills
            TextFormField(
              controller: _skillsController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Required Skills (comma separated)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: Color(0xFF00D4AA),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Post Job',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}