import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// WebSocket message types
enum WSMessageType {
  text,
  binary,
  ping,
  pong,
  subscribe,
  unsubscribe,
  broadcast,
}

/// WebSocket message wrapper
class WSMessage {
  final WSMessageType type;
  final String? channel;
  final String? targetPeerId;
  final dynamic payload;
  final DateTime timestamp;

  WSMessage({
    required this.type,
    this.channel,
    this.targetPeerId,
    this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'channel': channel,
    'targetPeerId': targetPeerId,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
  };

  factory WSMessage.fromJson(Map<String, dynamic> json) => WSMessage(
    type: WSMessageType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => WSMessageType.text,
    ),
    channel: json['channel'] as String?,
    targetPeerId: json['targetPeerId'] as String?,
    payload: json['payload'],
    timestamp: json['timestamp'] != null
      ? DateTime.parse(json['timestamp'] as String)
      : DateTime.now(),
  );
}

/// Chat message
class ChatMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isEncrypted;
  final String? replyToId;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    DateTime? timestamp,
    this.isEncrypted = false,
    this.replyToId,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'senderId': senderId,
    'senderName': senderName,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isEncrypted': isEncrypted,
    'replyToId': replyToId,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    messageId: json['messageId'] as String,
    senderId: json['senderId'] as String,
    senderName: json['senderName'] as String,
    content: json['content'] as String,
    timestamp: json['timestamp'] != null
      ? DateTime.parse(json['timestamp'] as String)
      : DateTime.now(),
    isEncrypted: json['isEncrypted'] as bool? ?? false,
    replyToId: json['replyToId'] as String?,
  );
}

/// Chat service for peer-to-peer messaging
class ChatService {
  final Map<String, List<ChatMessage>> _channels = {};
  final Map<String, List<String>> _channelMembers = {};
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _channelController = StreamController<List<String>>.broadcast();
  
  final String _selfId;
  final String _selfName;

  ChatService({
    required String selfId,
    required String selfName,
  }) : _selfId = selfId,
       _selfName = selfName;

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond % 999999;
    return sha256.convert(utf8.encode('msg-$timestamp-$random')).toString().substring(0, 12);
  }

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<List<String>> get channelStream => _channelController.stream;

  /// Create or get channel
  Future<void> createChannel(String channelId) async {
    if (!_channels.containsKey(channelId)) {
      _channels[channelId] = [];
      _channelMembers[channelId] = [];
      _channelController.add(channels);
      debugPrint('Created channel: $channelId');
    }
  }

  /// Join a channel
  Future<void> joinChannel(String channelId, String peerId) async {
    await createChannel(channelId);
    if (!_channelMembers[channelId]!.contains(peerId)) {
      _channelMembers[channelId]!.add(peerId);
      debugPrint('Peer $peerId joined channel $channelId');
    }
  }

  /// Leave a channel
  Future<void> leaveChannel(String channelId, String peerId) async {
    _channelMembers[channelId]?.remove(peerId);
    debugPrint('Peer $peerId left channel $channelId');
  }

  /// Send message to channel
  Future<ChatMessage> sendMessage({
    required String channelId,
    required String content,
    bool isEncrypted = false,
    String? replyToId,
  }) async {
    final messageId = _generateId();
    
    final message = ChatMessage(
      messageId: messageId,
      senderId: _selfId,
      senderName: _selfName,
      content: content,
      isEncrypted: isEncrypted,
      replyToId: replyToId,
    );

    _channels.putIfAbsent(channelId, () => []);
    _channels[channelId]!.add(message);
    _messageController.add(message);

    debugPrint('Sent message to channel $channelId: ${message.content.substring(0, content.length > 20 ? 20 : content.length)}...');
    return message;
  }

  /// Send direct message to peer
  Future<ChatMessage> sendDirectMessage({
    required String targetPeerId,
    required String content,
    bool isEncrypted = false,
  }) async {
    final channelId = _getDirectChannelId(targetPeerId);
    return sendMessage(
      channelId: channelId,
      content: content,
      isEncrypted: isEncrypted,
    );
  }

  String _getDirectChannelId(String peerId) {
    final ids = [_selfId, peerId]..sort();
    return 'dm_${ids.join('_')}';
  }

  /// Get messages from channel
  List<ChatMessage> getMessages(String channelId) {
    return _channels[channelId] ?? [];
  }

  /// Get direct messages with peer
  List<ChatMessage> getDirectMessages(String peerId) {
    final channelId = _getDirectChannelId(peerId);
    return getMessages(channelId);
  }

  /// Get all channels
  List<String> get channels => _channels.keys.toList();

  /// Get members of a channel
  List<String> getMembers(String channelId) {
    return _channelMembers[channelId] ?? [];
  }

  /// Delete message
  Future<bool> deleteMessage(String channelId, String messageId) async {
    final messages = _channels[channelId];
    if (messages == null) return false;

    messages.removeWhere((m) => m.messageId == messageId);
    return true;
  }

  /// Edit message
  Future<bool> editMessage(String channelId, String messageId, String newContent) async {
    final messages = _channels[channelId];
    if (messages == null) return false;

    final index = messages.indexWhere((m) => m.messageId == messageId);
    if (index == -1) return false;

    // Create new message with updated content
    final oldMessage = messages[index];
    final updated = ChatMessage(
      messageId: oldMessage.messageId,
      senderId: oldMessage.senderId,
      senderName: oldMessage.senderName,
      content: newContent,
      timestamp: oldMessage.timestamp,
      isEncrypted: oldMessage.isEncrypted,
    );
    
    messages[index] = updated;
    return true;
  }

  /// Get chat statistics
  Map<String, dynamic> getStats() => {
    'totalChannels': _channels.length,
    'totalMessages': _channels.values.fold(0, (sum, msgs) => sum + msgs.length),
    'totalMembers': _channelMembers.values.fold(0, (sum, ms) => sum + ms.length),
  };

  void dispose() {
    _messageController.close();
    _channelController.close();
  }
}