/// Voice and Video Call screens
library;

import 'package:flutter/material.dart';

/// Call state enum
enum CallState {
  idle,
  connecting,
  ringing,
  active,
  ended,
  failed,
}

/// Call type enum
enum CallType {
  voice,
  video,
  group,
  screenShare,
}

/// Voice call screen
class VoiceCallScreen extends StatefulWidget {
  final String contactId;
  final String contactName;
  final bool isOutgoing;
  final bool callerPaysMode;
  final double estimatedCostPerMinute;

  const VoiceCallScreen({
    super.key,
    required this.contactId,
    required this.contactName,
    this.isOutgoing = true,
    this.callerPaysMode = false,
    this.estimatedCostPerMinute = 0.5,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  CallState _callState = CallState.connecting;
  Duration _callDuration = Duration.zero;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isHold = false;

  @override
  void initState() {
    super.initState();
    // Simulate connection
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _callState = CallState.active;
        });
        _startDurationTimer();
      }
    });
  }

  void _startDurationTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _callState == CallState.active) {
        setState(() {
          _callDuration += const Duration(seconds: 1);
        });
        return true;
      }
      return false;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _currentCost {
    return _callDuration.inSeconds / 60 * widget.estimatedCostPerMinute;
  }

  void _endCall() {
    setState(() {
      _callState = CallState.ended;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            
            // Contact avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF00D4AA),
              child: Text(
                widget.contactName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0E14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Contact name
            Text(
              widget.contactName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Call status
            Text(
              _getCallStatusText(),
              style: TextStyle(
                fontSize: 16,
                color: _callState == CallState.active 
                    ? Colors.green 
                    : Colors.grey,
              ),
            ),
            
            // Caller pays mode indicator
            if (widget.callerPaysMode && _callState == CallState.active) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payments, 
                              color: Color(0xFF00D4AA), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Cost: ~${_currentCost.toStringAsFixed(2)} PINC/min',
                      style: const TextStyle(
                        color: Color(0xFF00D4AA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const Spacer(),
            
            // Duration (only when active)
            if (_callState == CallState.active) ...[
              Text(
                _formatDuration(_callDuration),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
            ],
            
            // Call controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted ? 'Unmute' : 'Mute',
                  isActive: _isMuted,
                  onTap: () => setState(() => _isMuted = !_isMuted),
                ),
                
                // Speaker button
                _buildControlButton(
                  icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                  label: 'Speaker',
                  isActive: _isSpeakerOn,
                  onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                ),
                
                // Hold button
                _buildControlButton(
                  icon: _isHold ? Icons.pause : Icons.pause,
                  label: 'Hold',
                  isActive: _isHold,
                  onTap: () => setState(() => _isHold = !_isHold),
                ),
                
                // End call button
                _buildEndCallButton(),
              ],
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  String _getCallStatusText() {
    switch (_callState) {
      case CallState.connecting:
        return 'Connecting...';
      case CallState.ringing:
        return 'Ringing...';
      case CallState.active:
        return 'Connected';
      case CallState.ended:
        return 'Call ended';
      case CallState.failed:
        return 'Call failed';
      default:
        return '';
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive 
                  ? const Color(0xFF00D4AA) 
                  : const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF0A0E14) : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF00D4AA) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: _endCall,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'End',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Video call screen
class VideoCallScreen extends StatefulWidget {
  final String contactId;
  final String contactName;
  final bool isOutgoing;
  final bool callerPaysMode;
  final double estimatedCostPerMinute;

  const VideoCallScreen({
    super.key,
    required this.contactId,
    required this.contactName,
    this.isOutgoing = true,
    this.callerPaysMode = false,
    this.estimatedCostPerMinute = 1.0,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  CallState _callState = CallState.connecting;
  Duration _callDuration = Duration.zero;
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isFrontCamera = true;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _callState = CallState.active;
        });
        _startDurationTimer();
      }
    });
  }

  void _startDurationTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _callState == CallState.active) {
        setState(() {
          _callDuration += const Duration(seconds: 1);
        });
        return true;
      }
      return false;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _currentCost {
    return _callDuration.inSeconds / 60 * widget.estimatedCostPerMinute;
  }

  void _endCall() {
    setState(() {
      _callState = CallState.ended;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Stack(
        children: [
          // Video placeholder (remote video)
          Container(
            color: const Color(0xFF1E1E1E),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 120, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Remote Video',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          
          // Local video (picture-in-picture)
          Positioned(
            top: 60,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() => _isFrontCamera = !_isFrontCamera);
              },
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2E2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00D4AA), width: 2),
                ),
                child: _isCameraOn
                    ? const Center(
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                      )
                    : const Center(
                        child: Icon(Icons.videocam_off, 
                                    size: 40, color: Colors.grey),
                      ),
              ),
            ),
          ),
          
          // Top bar with info
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.contactName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_callState == CallState.active)
                            Text(
                              _formatDuration(_callDuration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                        ],
                      ),
                      if (widget.callerPaysMode) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, 
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4AA).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Cost: ~${_currentCost.toStringAsFixed(2)} PINC/min',
                            style: const TextStyle(
                              color: Color(0xFF00D4AA),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          
          // Bottom controls
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildVideoControl(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        isActive: _isMuted,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      _buildVideoControl(
                        icon: _isCameraOn 
                            ? Icons.videocam 
                            : Icons.videocam_off,
                        isActive: !_isCameraOn,
                        onTap: () => setState(() => _isCameraOn = !_isCameraOn),
                      ),
                      _buildVideoControl(
                        icon: Icons.flip_camera_android,
                        isActive: false,
                        onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
                      ),
                      _buildVideoControl(
                        icon: Icons.screen_share,
                        isActive: false,
                        onTap: () {
                          // Start screen share
                        },
                      ),
                      GestureDetector(
                        onTap: _endCall,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Tap to toggle controls
          GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControl({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? Colors.red : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

/// Group call screen (up to 50 participants)
class GroupCallScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final int maxParticipants;

  const GroupCallScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    this.maxParticipants = 50,
  });

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  CallState _callState = CallState.active;
  Duration _callDuration = Duration.zero;
  final List<Map<String, String>> _participants = [
    {'id': '1', 'name': 'You', 'isMuted': 'false'},
    {'id': '2', 'name': 'Alice', 'isMuted': 'false'},
    {'id': '3', 'name': 'Bob', 'isMuted': 'true'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.roomName,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '${_participants.length}/${widget.maxParticipants} participants',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Color(0xFF00D4AA)),
            onPressed: () {
              // Add participant
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Duration
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              _formatDuration(_callDuration),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          
          // Participants grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final participant = _participants[index];
                final isMuted = participant['isMuted'] == 'true';
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: index == 0 
                        ? Border.all(color: const Color(0xFF00D4AA), width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF00D4AA),
                        child: Text(
                          participant['name']![0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0A0E14),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            participant['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          if (isMuted) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.mic_off, 
                                      size: 12, color: Colors.red),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Controls
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGroupControl(Icons.mic_off, 'Mute', true),
                _buildGroupControl(Icons.videocam, 'Video', true),
                _buildGroupControl(Icons.screen_share, 'Share', false),
                _buildGroupControl(Icons.call_end, 'Leave', false, isRed: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildGroupControl(
    IconData icon, 
    String label, 
    bool isActive, 
    {bool isRed = false}
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isRed 
                ? Colors.red 
                : (isActive ? Colors.white : Colors.white.withOpacity(0.2)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isRed || !isActive ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

/// Screen share screen
class ScreenShareScreen extends StatefulWidget {
  final String contactId;
  final String contactName;

  const ScreenShareScreen({
    super.key,
    required this.contactId,
    required this.contactName,
  });

  @override
  State<ScreenShareScreen> createState() => _ScreenShareScreenState();
}

class _ScreenShareScreenState extends State<ScreenShareScreen> {
  bool _isSharing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: Row(
          children: [
            const Icon(Icons.screen_share, color: Color(0xFF00D4AA)),
            const SizedBox(width: 8),
            Text('Sharing with ${widget.contactName}'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => _isSharing = !_isSharing);
            },
            icon: Icon(
              _isSharing ? Icons.stop : Icons.play_arrow,
              color: _isSharing ? Colors.red : Colors.green,
            ),
            label: Text(
              _isSharing ? 'Stop' : 'Start',
              style: TextStyle(
                color: _isSharing ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSharing ? Icons.screen_share : Icons.screen_share_outlined,
              size: 100,
              color: _isSharing ? const Color(0xFF00D4AA) : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              _isSharing 
                  ? 'Screen sharing is active'
                  : 'Screen sharing is paused',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Encrypted via P2P mesh',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (_isSharing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield, color: Color(0xFF00D4AA)),
                    SizedBox(width: 8),
                    Text(
                      'End-to-end encrypted',
                      style: TextStyle(color: Color(0xFF00D4AA)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}