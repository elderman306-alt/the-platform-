/// Chat domain layer - entities and repositories
library;

/// Message type enum
enum MessageType {
  text,
  image,
  file,
  voice,
  video,
  system,
}

/// Message entity
class MessageEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? replyToId;
  final List<String> reactions;
  final MessageStatus status;

  MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.replyToId,
    this.reactions = const [],
    this.status = MessageStatus.sent,
  });

  MessageEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    String? replyToId,
    List<String>? reactions,
    MessageStatus? status,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
      status: status ?? this.status,
    );
  }
}

/// Message status enum
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Chat contact entity
class ChatContactEntity {
  final String id;
  final String pinicId;
  final String displayName;
  final String? avatarUrl;
  final DateTime lastSeen;
  final bool isOnline;
  final String? publicKey;

  ChatContactEntity({
    required this.id,
    required this.pinicId,
    required this.displayName,
    this.avatarUrl,
    required this.lastSeen,
    this.isOnline = false,
    this.publicKey,
  });

  ChatContactEntity copyWith({
    String? id,
    String? pinicId,
    String? displayName,
    String? avatarUrl,
    DateTime? lastSeen,
    bool? isOnline,
    String? publicKey,
  }) {
    return ChatContactEntity(
      id: id ?? this.id,
      pinicId: pinicId ?? this.pinicId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      publicKey: publicKey ?? this.publicKey,
    );
  }
}

/// Chat repository interface
abstract class ChatRepository {
  Future<List<MessageEntity>> getMessages(String userId, String contactId);
  Future<void> sendMessage(MessageEntity message);
  Future<void> deleteMessage(String messageId, String userId);
  Future<void> markAsRead(String messageId, String userId);
}