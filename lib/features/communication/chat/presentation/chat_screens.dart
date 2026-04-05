/// Chat presentation layer - screens and widgets
library;

import 'package:flutter/material.dart';
import '../domain/entities.dart';

/// Main chat screen - WhatsApp-style UI
class ChatScreen extends StatefulWidget {
  final ChatContactEntity contact;
  final String currentUserId;
  
  const ChatScreen({
    super.key,
    required this.contact,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<MessageEntity> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _isSending = true;
    });
    
    final message = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.currentUserId,
      receiverId: widget.contact.id,
      content: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    
    setState(() {
      _messages.add(message);
      _messageController.clear();
      _isSending = false;
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addReaction(String messageId, String emoji) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final msg = _messages[index];
        final reactions = List<String>.from(msg.reactions)..add(emoji);
        _messages[index] = msg.copyWith(reactions: reactions);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF00D4AA),
              child: Text(
                widget.contact.displayName[0].toUpperCase(),
                style: const TextStyle(color: Color(0xFF0A0E14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        widget.contact.isOnline ? Icons.circle : null,
                        size: 8,
                        color: widget.contact.isOnline 
                            ? Colors.green 
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.contact.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.contact.isOnline 
                              ? Colors.green 
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Color(0xFF00D4AA)),
            onPressed: () {
              // Start video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF00D4AA)),
            onPressed: () {
              // Start voice call
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF00D4AA)),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clear', child: Text('Clear chat')),
              const PopupMenuItem(value: 'block', child: Text('Block')),
              const PopupMenuItem(value: 'report', child: Text('Report')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == widget.currentUserId;
                return MessageBubble(
                  message: message,
                  isMe: isMe,
                  onReaction: (emoji) => _addReaction(message.id, emoji),
                );
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF0A0E14),
              border: Border(
                top: BorderSide(color: Color(0xFF1E1E1E)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {
                    // Attach file
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00D4AA),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0A0E14),
                            ),
                          )
                        : const Icon(Icons.send, color: Color(0xFF0A0E14)),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget
class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final Function(String) onReaction;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              _showMessageOptions(context);
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF00D4AA) : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? const Color(0xFF0A0E14) : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: isMe 
                              ? const Color(0xFF0A0E14).withOpacity(0.7) 
                              : Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.read 
                              ? Icons.done_all 
                              : Icons.done,
                          size: 14,
                          color: message.status == MessageStatus.read 
                              ? const Color(0xFF0A0E14) 
                              : const Color(0xFF0A0E14).withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                  if (message.reactions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      children: message.reactions.map((r) => Text(r)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply, color: Colors.white),
              title: const Text('Reply', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.white),
              title: const Text('Copy', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.white),
              title: const Text('Delete', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['❤️', '👍', '😂', '😮', '😢', '🎉'].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    onReaction(emoji);
                    Navigator.pop(context);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Contact list screen
class ContactListScreen extends StatelessWidget {
  final List<ChatContactEntity> contacts;
  final String currentUserId;
  final Function(ChatContactEntity) onContactTap;

  const ContactListScreen({
    super.key,
    required this.contacts,
    required this.currentUserId,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF00D4AA)),
            onPressed: () {
              // Search contacts by PINC ID
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00D4AA)),
            onPressed: () {
              // Refresh contacts
            },
          ),
        ],
      ),
      body: contacts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, 
                       size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No contacts yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Search by PINC ID to start chatting',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF00D4AA),
                    child: Text(
                      contact.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF0A0E14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    contact.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        contact.pinicId,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        contact.isOnline ? Icons.circle : null,
                        size: 8,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  onTap: () => onContactTap(contact),
                );
              },
            ),
    );
  }
}