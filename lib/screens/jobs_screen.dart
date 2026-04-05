import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../features/jobs/data/models/job_model.dart';
import '../features/jobs/data/models/bid_model.dart';
import '../features/jobs/data/repositories/jobs_repository.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JobsRepository _repository = JobsRepository();
  
  List<Job> _allJobs = [];
  List<Job> _myJobs = [];
  List<Job> _myBids = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
  }
  
  void _loadJobs() {
    // Load sample data
    setState(() {
      _allJobs = _repository.getAllJobs();
      _myJobs = _repository.getMyPostedJobs('current_user');
      _myBids = _repository.getMyBids('current_user');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        bottom: TabBar(
          controller: _tabController,
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
    if (_allJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No jobs available',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(2),
              child: const Text('Post a Job'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allJobs.length,
      itemBuilder: (context, index) {
        final job = _allJobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${job.budget.toStringAsFixed(0)} PINC',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: TextStyle(color: AppTheme.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      job.category,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${job.bidCount} bids',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showBidDialog(job),
                child: const Text('Place Bid'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyJobsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Posted'),
              Tab(text: 'Working'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _myJobs.isEmpty
                    ? Center(child: Text('No posted jobs', style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _myJobs.length,
                        itemBuilder: (context, index) => _buildJobCard(_myJobs[index]),
                      ),
                _myBids.isEmpty
                    ? Center(child: Text('No active bids', style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _myBids.length,
                        itemBuilder: (context, index) => _buildJobCard(_myBids[index]),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostJobTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Post a New Job',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '3% platform fee applies',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Job Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Budget (PINC)',
              border: OutlineInputBorder(),
              prefixText: '',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job posted successfully! (3% fee applied)')),
                );
                _tabController.animateTo(0);
              },
              child: const Text('Post Job'),
            ),
          ),
        ],
      ),
    );
  }

  void _showBidDialog(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Place Bid - ${job.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Budget: ${job.budget} PINC'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Your Bid (PINC)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Proposal',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bid placed successfully!')),
              );
            },
            child: const Text('Submit Bid'),
          ),
        ],
      ),
    );
  }
}