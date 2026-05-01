import 'chat_message_entity.dart';

class ChatSessionEntity {
  const ChatSessionEntity({
    required this.id,
    required this.userId,
    required this.topic,
    required this.startedAt,
    this.messages = const [],
  });

  final String id;
  final String userId;
  final String topic;
  final DateTime startedAt;
  final List<ChatMessageEntity> messages;

  ChatSessionEntity copyWith({
    String? id,
    String? userId,
    String? topic,
    DateTime? startedAt,
    List<ChatMessageEntity>? messages,
  }) =>
      ChatSessionEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        topic: topic ?? this.topic,
        startedAt: startedAt ?? this.startedAt,
        messages: messages ?? this.messages,
      );
}
