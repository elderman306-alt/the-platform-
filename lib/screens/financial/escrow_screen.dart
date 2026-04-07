import 'package:flutter/material.dart';
import '../../models/wallet_model.dart';

class EscrowScreen extends StatefulWidget {
  final String? currentPincoderId;
  
  const EscrowScreen({super.key, this.currentPincoderId});
  
  @override
  State<EscrowScreen> createState() => _EscrowScreenState();
}

class _EscrowScreenState extends State<EscrowScreen> {
  final List<EscrowJob> _activeEscrows = [];
  final List<EscrowJob> _completedEscrows = [];
  int _selectedTab = 0;
  
  // Sample escrow data
  final List<EscrowJob> _sampleActiveEscrows = [
    EscrowJob(
      id: 'ESC-001',
      jobTitle: 'Mobile App UI Design',
      employerId: 'PINC-1234567890',
      freelancerId: 'PINC-0987654321',
      amount: 500.0,
      status: EscrowStatus.funded,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    EscrowJob(
      id: 'ESC-002',
      jobTitle: 'Backend API Development',
      employerId: 'PINC-1234567890',
      freelancerId: 'PINC-1122334455',
      amount: 1200.0,
      status: EscrowStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    // Load sample data
    _activeEscrows.addAll(_sampleActiveEscrows);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131A24),
        title: const Text('Job Escrow', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showCreateEscrowDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoBanner(),
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateEscrowDialog,
        backgroundColor: const Color(0xFF00D4AA),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('New Escrow', style: TextStyle(color: Colors.black)),
      ),
    );
  }
  
  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF00D4AA)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Secure Payments',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '9% fee | Funds held until work is approved',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTab('Active', 0),
          _buildTab('Completed', 1),
          _buildTab('Create', 2),
        ],
      ),
    );
  }
  
  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF00D4AA) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00D4AA) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildActiveEscrowsList();
      case 1:
        return _buildCompletedEscrowsList();
      case 2:
        return _buildCreateSection();
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildActiveEscrowsList() {
    if (_activeEscrows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            const Text('No active escrows', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showCreateEscrowDialog,
              child: const Text('Create one now'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeEscrows.length,
      itemBuilder: (context, index) {
        return _buildEscrowCard(_activeEscrows[index]);
      },
    );
  }
  
  Widget _buildEscrowCard(EscrowJob escrow) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (escrow.status) {
      case EscrowStatus.funded:
        statusColor = Colors.orange;
        statusText = 'Funded - Awaiting Start';
        statusIcon = Icons.pause_circle;
        break;
      case EscrowStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'In Progress';
        statusIcon = Icons.play_circle;
        break;
      case EscrowStatus.pendingRelease:
        statusColor = Colors.purple;
        statusText = 'Awaiting Release';
        statusIcon = Icons.hourglass_empty;
        break;
      case EscrowStatus.completed:
        statusColor = Colors.green;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
      case EscrowStatus.disputed:
        statusColor = Colors.red;
        statusText = 'Disputed';
        statusIcon = Icons.warning;
        break;
      case EscrowStatus.refunded:
        statusColor = Colors.grey;
        statusText = 'Refunded';
        statusIcon = Icons.undo;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '#${escrow.id}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            escrow.jobTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip('Employer', escrow.employerId),
              const SizedBox(width: 8),
              _buildInfoChip('Freelancer', escrow.freelancerId),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Text(
                    '₿ ${escrow.amount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Created', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Text(
                    _formatDate(escrow.createdAt),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (escrow.status == EscrowStatus.funded)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSnackBar('Starting work...'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Start Work'),
                  ),
                ),
              if (escrow.status == EscrowStatus.inProgress)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markWorkComplete(escrow.id),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Mark Complete'),
                  ),
                ),
              if (escrow.status == EscrowStatus.pendingRelease)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _releaseFunds(escrow.id),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00D4AA)),
                    child: const Text('Release Funds', style: TextStyle(color: Colors.black)),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showDisputeDialog(escrow.id),
                icon: const Icon(Icons.report_problem, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          Text(value, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 10)),
        ],
      ),
    );
  }
  
  Widget _buildCompletedEscrowsList() {
    if (_completedEscrows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            const Text('No completed escrows yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedEscrows.length,
      itemBuilder: (context, index) {
        return _buildEscrowCard(_completedEscrows[index]);
      },
    );
  }
  
  Widget _buildCreateSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCreateStep(
          1,
          'Create Job',
          'Post your job on the Jobs marketplace',
          Icons.work,
        ),
        _buildCreateStep(
          2,
          'Fund Escrow',
          'Lock funds in secure escrow (9% fee)',
          Icons.account_balance_wallet,
        ),
        _buildCreateStep(
          3,
          'Work Progress',
          'Freelancer completes the work',
          Icons.engineering,
        ),
        _buildCreateStep(
          4,
          'Approve & Release',
          'Review work and release payment',
          Icons.check_circle,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _showCreateEscrowDialog,
          icon: const Icon(Icons.add),
          label: const Text('Create Escrow for Job'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D4AA),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCreateStep(int step, String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4AA).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(color: Color(0xFF00D4AA), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFF00D4AA)),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
  
  void _showCreateEscrowDialog() {
    final jobTitleController = TextEditingController();
    final amountController = TextEditingController();
    final freelancerIdController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Escrow', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('9% fee applies to all job payments', style: TextStyle(color: Colors.orange)),
            const SizedBox(height: 20),
            TextField(
              controller: jobTitleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Job Title',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D4AA))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: freelancerIdController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Freelancer PINC ID',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D4AA))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (PINC)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D4AA))),
                prefixText: '₿ ',
                prefixStyle: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (jobTitleController.text.isEmpty || 
                      amountController.text.isEmpty ||
                      freelancerIdController.text.isEmpty) {
                    _showSnackBar('Please fill all fields', isError: true);
                    return;
                  }
                  Navigator.pop(context);
                  _showSnackBar('Escrow created! (Requires wallet integration)');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Escrow', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  void _markWorkComplete(String escrowId) {
    _showSnackBar('Work marked as complete. Waiting for approval.');
  }
  
  void _releaseFunds(String escrowId) {
    _showSnackBar('Funds released to freelancer!');
  }
  
  void _showDisputeDialog(String escrowId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131A24),
        title: const Text('Report Dispute', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to report a dispute? An admin will review your case.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Dispute filed. Admin will review shortly.');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}

class EscrowJob {
  final String id;
  final String jobTitle;
  final String employerId;
  final String freelancerId;
  final double amount;
  final EscrowStatus status;
  final DateTime createdAt;
  
  EscrowJob({
    required this.id,
    required this.jobTitle,
    required this.employerId,
    required this.freelancerId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });
}

enum EscrowStatus {
  funded,
  inProgress,
  pendingRelease,
  completed,
  disputed,
  refunded,
}