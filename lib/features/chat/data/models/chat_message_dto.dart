import '../../domain/entities/chat_message_entity.dart';

class ChatMessageDTO {
  const ChatMessageDTO({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String role;
  final String content;
  final DateTime createdAt;

  factory ChatMessageDTO.fromJson(Map<String, dynamic> json) => ChatMessageDTO(
        id: json['id'] as String,
        sessionId: json['session_id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'role': role,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  ChatMessageEntity toEntity() => ChatMessageEntity(
        id: id,
        sessionId: sessionId,
        role: role,
        content: content,
        createdAt: createdAt,
      );
}
