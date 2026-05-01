import '../../domain/entities/chat_session_entity.dart';
import 'chat_message_dto.dart';

class ChatSessionDTO {
  const ChatSessionDTO({
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
  final List<ChatMessageDTO> messages;

  factory ChatSessionDTO.fromJson(Map<String, dynamic> json) => ChatSessionDTO(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        topic: json['topic'] as String,
        startedAt: DateTime.parse(json['started_at'] as String),
        messages: (json['chat_messages'] as List<dynamic>? ?? [])
            .map((m) => ChatMessageDTO.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'topic': topic,
        'started_at': startedAt.toIso8601String(),
      };

  ChatSessionEntity toEntity() => ChatSessionEntity(
        id: id,
        userId: userId,
        topic: topic,
        startedAt: startedAt,
        messages: messages.map((m) => m.toEntity()).toList(),
      );
}
