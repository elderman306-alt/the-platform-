import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// WebRTC signaling message types
enum SignalType {
  offer,
  answer,
  iceCandidate,
  join,
  leave,
  roomsList,
}

/// WebRTC signaling message
class SignalMessage {
  final SignalType type;
  final String fromPeerId;
  final String? toPeerId;
  final String? roomId;
  final dynamic payload;
  final DateTime timestamp;

  SignalMessage({
    required this.type,
    required this.fromPeerId,
    this.toPeerId,
    this.roomId,
    this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'fromPeerId': fromPeerId,
    'toPeerId': toPeerId,
    'roomId': roomId,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SignalMessage.fromJson(Map<String, dynamic> json) => SignalMessage(
    type: SignalType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => SignalType.offer,
    ),
    fromPeerId: json['fromPeerId'] as String,
    toPeerId: json['toPeerId'] as String?,
    roomId: json['roomId'] as String?,
    payload: json['payload'],
    timestamp: json['timestamp'] != null 
      ? DateTime.parse(json['timestamp'] as String)
      : DateTime.now(),
  );
}

/// Call room for WebRTC
class CallRoom {
  final String roomId;
  final String hostPeerId;
  final List<String> participants;
  final bool isVideo;
  final DateTime createdAt;

  CallRoom({
    required this.roomId,
    required this.hostPeerId,
    List<String>? participants,
    this.isVideo = true,
    DateTime? createdAt,
  }) : participants = participants ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'hostPeerId': hostPeerId,
    'participants': participants,
    'isVideo': isVideo,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// WebRTC Signaling Service
/// Handles peer connection setup for voice/video calls
class WebRTCSignalingService {
  final Map<String, CallRoom> _rooms = {};
  final Map<String, List<SignalMessage>> _pendingMessages = {};
  final _signalController = StreamController<SignalMessage>.broadcast();
  final _roomController = StreamController<List<CallRoom>>.broadcast();
  
  final String _selfId;

  WebRTCSignalingService({required String selfId}) : _selfId = selfId;

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random(timestamp).nextInt(999999);
    return sha256.convert(utf8.encode('room-$timestamp-$random')).toString().substring(0, 8);
  }

  Stream<SignalMessage> get signalStream => _signalController.stream;
  Stream<List<CallRoom>> get roomStream => _roomController.stream;
  List<CallRoom> get rooms => _rooms.values.toList();

  /// Create a new call room
  CallRoom createRoom({bool isVideo = true}) {
    final roomId = _generateId();
    final room = CallRoom(
      roomId: roomId,
      hostPeerId: _selfId,
      isVideo: isVideo,
    );
    _rooms[roomId] = room;
    _roomController.add(rooms);
    debugPrint('Created call room: $roomId');
    return room;
  }

  /// Join an existing room
  Future<CallRoom?> joinRoom(String roomId, String peerId) async {
    final room = _rooms[roomId];
    if (room == null) {
      debugPrint('Room not found: $roomId');
      return null;
    }

    if (!room.participants.contains(peerId)) {
      room.participants.add(peerId);
      _rooms[roomId] = room;
      _roomController.add(rooms);
    }

    // Notify host about new participant
    final joinMessage = SignalMessage(
      type: SignalType.join,
      fromPeerId: peerId,
      roomId: roomId,
      payload: {'participant': peerId},
    );
    _signalController.add(joinMessage);

    debugPrint('Peer $peerId joined room $roomId');
    return room;
  }

  /// Leave a room
  Future<void> leaveRoom(String roomId, String peerId) async {
    final room = _rooms[roomId];
    if (room == null) return;

    room.participants.remove(peerId);
    _rooms[roomId] = room;
    _roomController.add(rooms);

    // Notify others
    final leaveMessage = SignalMessage(
      type: SignalType.leave,
      fromPeerId: peerId,
      roomId: roomId,
      payload: {'participant': peerId},
    );
    _signalController.add(leaveMessage);

    debugPrint('Peer $peerId left room $roomId');
  }

  /// Send signaling message
  Future<void> sendSignal(SignalMessage message) async {
    // Store pending message if recipient not connected
    if (message.toPeerId != null) {
      _pendingMessages.putIfAbsent(message.toPeerId!, () => []);
      _pendingMessages[message.toPeerId]!.add(message);
    }
    
    _signalController.add(message);
    debugPrint('Sending signal: ${message.type.name} from ${message.fromPeerId} to ${message.toPeerId}');
  }

  /// Create offer for WebRTC connection
  SignalMessage createOffer(String targetPeerId, Map<String, dynamic> offer) {
    return SignalMessage(
      type: SignalType.offer,
      fromPeerId: _selfId,
      toPeerId: targetPeerId,
      payload: offer,
    );
  }

  /// Create answer for WebRTC connection
  SignalMessage createAnswer(String targetPeerId, Map<String, dynamic> answer) {
    return SignalMessage(
      type: SignalType.answer,
      fromPeerId: _selfId,
      toPeerId: targetPeerId,
      payload: answer,
    );
  }

  /// Create ICE candidate message
  SignalMessage createIceCandidate(String targetPeerId, Map<String, dynamic> candidate) {
    return SignalMessage(
      type: SignalType.iceCandidate,
      fromPeerId: _selfId,
      toPeerId: targetPeerId,
      payload: candidate,
    );
  }

  /// Get pending messages for a peer
  List<SignalMessage> getPendingMessages(String peerId) {
    return _pendingMessages.remove(peerId) ?? [];
  }

  /// Get room by ID
  CallRoom? getRoom(String roomId) => _rooms[roomId];

  /// Get rooms for a peer
  List<CallRoom> getRoomsForPeer(String peerId) {
    return _rooms.values.where((r) => r.participants.contains(peerId)).toList();
  }

  /// Close a room
  void closeRoom(String roomId) {
    _rooms.remove(roomId);
    _roomController.add(rooms);
    debugPrint('Closed room: $roomId');
  }

  /// Get signaling statistics
  Map<String, dynamic> getStats() => {
    'totalRooms': _rooms.length,
    'totalParticipants': _rooms.values.fold(0, (sum, r) => sum + r.participants.length),
    'videoRooms': _rooms.values.where((r) => r.isVideo).length,
    'audioRooms': _rooms.values.where((r) => !r.isVideo).length,
  };

  void dispose() {
    _signalController.close();
    _roomController.close();
  }
}