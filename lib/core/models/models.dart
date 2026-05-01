// lib/core/models/models.dart

import 'package:flutter/foundation.dart';

// ─── User ─────────────────────────────────────────────────────────────────────
@immutable
class ZestUser {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  const ZestUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ZestUser.fromJson(Map<String, dynamic> j) => ZestUser(
        id: j['id'] as String,
        username: j['username'] as String,
        displayName: j['display_name'] as String? ?? j['username'] as String,
        avatarUrl: j['avatar_url'] as String?,
        isOnline: j['is_online'] as bool? ?? false,
        lastSeen: j['last_seen'] != null
            ? DateTime.tryParse(j['last_seen'] as String)
            : null,
      );

  ZestUser copyWith({String? avatarUrl, bool? isOnline}) => ZestUser(
        id: id,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isOnline: isOnline ?? this.isOnline,
        lastSeen: lastSeen,
      );
}

// ─── Message ──────────────────────────────────────────────────────────────────
enum MessageType { text, voice, image }
enum MessageStatus { sending, sent, delivered, read, failed }

@immutable
class ChatMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final MessageType type;
  final String content; // text body | image url | amr url
  final DateTime timestamp;
  final MessageStatus status;
  final bool isMine;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.status,
    required this.isMine,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j, String myId) {
    final typeStr = j['type'] as String? ?? 'text';
    final type = switch (typeStr) {
      'voice' => MessageType.voice,
      'image' => MessageType.image,
      _ => MessageType.text,
    };
    final statusStr = j['status'] as String? ?? 'sent';
    final status = switch (statusStr) {
      'sending'   => MessageStatus.sending,
      'delivered' => MessageStatus.delivered,
      'read'      => MessageStatus.read,
      'failed'    => MessageStatus.failed,
      _ => MessageStatus.sent,
    };
    return ChatMessage(
      id: j['id'] as String,
      senderId: j['sender_id'] as String,
      recipientId: j['recipient_id'] as String,
      type: type,
      content: j['content'] as String,
      timestamp: DateTime.parse(j['timestamp'] as String),
      status: status,
      isMine: j['sender_id'] == myId,
    );
  }
}

// ─── Conversation ─────────────────────────────────────────────────────────────
@immutable
class Conversation {
  final String id;
  final ZestUser peer;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final MessageType lastMessageType;

  const Conversation({
    required this.id,
    required this.peer,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.lastMessageType = MessageType.text,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        id: j['id'] as String,
        peer: ZestUser.fromJson(j['peer'] as Map<String, dynamic>),
        lastMessage: j['last_message'] as String? ?? '',
        lastMessageTime: DateTime.parse(j['last_message_time'] as String),
        unreadCount: j['unread_count'] as int? ?? 0,
        lastMessageType: switch (j['last_message_type'] as String? ?? 'text') {
          'voice' => MessageType.voice,
          'image' => MessageType.image,
          _ => MessageType.text,
        },
      );
}

// ─── Status / Story ───────────────────────────────────────────────────────────
enum StatusType { image, voiceStatus }

@immutable
class UserStatus {
  final String id;
  final ZestUser author;
  final StatusType type;
  final String data; // image url or voice url
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool hasSeen;

  const UserStatus({
    required this.id,
    required this.author,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.expiresAt,
    this.hasSeen = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory UserStatus.fromJson(Map<String, dynamic> j) => UserStatus(
        id: j['id'] as String,
        author: ZestUser.fromJson(j['author'] as Map<String, dynamic>),
        type: j['content_type'] == 'voice_status'
            ? StatusType.voiceStatus
            : StatusType.image,
        data: j['data'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        expiresAt: DateTime.parse(j['expires_at'] as String),
        hasSeen: j['has_seen'] as bool? ?? false,
      );
}
