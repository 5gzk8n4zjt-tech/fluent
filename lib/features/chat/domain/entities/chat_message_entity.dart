class ChatMessageEntity {
  const ChatMessageEntity({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String sessionId;

  /// Either "user" or "assistant".
  final String role;

  final String content;
  final DateTime createdAt;

  bool get isUser => role == 'user';

  ChatMessageEntity copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    DateTime? createdAt,
  }) =>
      ChatMessageEntity(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        role: role ?? this.role,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
}
