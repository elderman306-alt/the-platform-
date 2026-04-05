/// Chat data layer - models and repositories
library;

import 'dart:convert';
import 'dart:typed_data';
import '../domain/entities/message_entity.dart';
import '../domain/repositories/message_repository.dart';

/// Message model for data layer
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String encryptedContent;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? replyToId;
  final List<String> reactions;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.encryptedContent,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.replyToId,
    this.reactions = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      encryptedContent: json['encrypted_content'] as String,
      type: MessageType.values.byName(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      replyToId: json['reply_to_id'] as String?,
      reactions: List<String>.from(json['reactions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'encrypted_content': encryptedContent,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'reply_to_id': replyToId,
      'reactions': reactions,
    };
  }

  MessageEntity toEntity(String decryptedContent) {
    return MessageEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: decryptedContent,
      type: type,
      timestamp: timestamp,
      isRead: isRead,
      replyToId: replyToId,
      reactions: reactions,
    );
  }
}

/// Chat repository implementation
class ChatRepositoryImpl implements ChatRepository {
  final Map<String, List<MessageModel>> _messages = {};
  final MessageEncryption _encryption;

  ChatRepositoryImpl(this._encryption);

  @override
  Future<List<MessageEntity>> getMessages(String userId, String contactId) async {
    final key = _getChatKey(userId, contactId);
    final messageModels = _messages[key] ?? [];
    return messageModels.map((m) {
      final decrypted = _encryption.decrypt(m.encryptedContent);
      return m.toEntity(decrypted);
    }).toList();
  }

  @override
  Future<void> sendMessage(MessageEntity message) async {
    final key = _getChatKey(message.senderId, message.receiverId);
    final encrypted = _encryption.encrypt(message.content);
    
    final model = MessageModel(
      id: message.id,
      senderId: message.senderId,
      receiverId: message.receiverId,
      encryptedContent: encrypted,
      type: message.type,
      timestamp: message.timestamp,
      isRead: false,
      replyToId: message.replyToId,
      reactions: message.reactions,
    );
    
    _messages[key] = [...(_messages[key] ?? []), model];
  }

  @override
  Future<void> deleteMessage(String messageId, String userId) async {
    for (var messages in _messages.values) {
      messages.removeWhere((m) => m.id == messageId && m.senderId == userId);
    }
  }

  @override
  Future<void> markAsRead(String messageId, String userId) async {
    for (var messages in _messages.values) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = MessageModel(
          id: messages[index].id,
          senderId: messages[index].senderId,
          receiverId: messages[index].receiverId,
          encryptedContent: messages[index].encryptedContent,
          type: messages[index].type,
          timestamp: messages[index].timestamp,
          isRead: true,
          replyToId: messages[index].replyToId,
          reactions: messages[index].reactions,
        );
        break;
      }
    }
  }

  String _getChatKey(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}

/// Message encryption service
class MessageEncryption {
  final String _userId;
  final Uint8List _encryptionKey;
  
  MessageEncryption(this._userId, this._encryptionKey);
  
  String encrypt(String plainText) {
    // Simplified XOR encryption for demo
    // In production, use proper AES-256-GCM
    final plainBytes = utf8.encode(plainText);
    final keyBytes = _encryptionKey;
    final encrypted = Uint8List(plainBytes.length);
    
    for (var i = 0; i < plainBytes.length; i++) {
      encrypted[i] = plainBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    
    return base64Encode(encrypted);
  }
  
  String decrypt(String encryptedText) {
    final encryptedBytes = base64Decode(encryptedText);
    final keyBytes = _encryptionKey;
    final decrypted = Uint8List(encryptedBytes.length);
    
    for (var i = 0; i < encryptedBytes.length; i++) {
      decrypted[i] = encryptedBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    
    return utf8.decode(decrypted);
  }
}