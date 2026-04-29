import '../value_objects/level.dart';

class DeckEntity {
  const DeckEntity({
    required this.id,
    required this.title,
    required this.level,
    required this.topic,
    required this.isPredefined,
    required this.createdBy,
    required this.createdAt,
    required this.flashcardCount,
  });

  final String id;
  final String title;
  final Level level;
  final String topic;
  final bool isPredefined;
  final String createdBy;
  final DateTime createdAt;
  final int flashcardCount;

  int cardCount() => flashcardCount;

  factory DeckEntity.fromMap(Map<String, dynamic> map) => DeckEntity(
        id: map['id'] as String,
        title: map['title'] as String,
        level: LevelExtension.fromString(map['level'] as String),
        topic: map['topic'] as String,
        isPredefined: map['is_predefined'] as bool? ?? false,
        createdBy: map['created_by'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        flashcardCount: map['flashcard_count'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'level': level.code,
        'topic': topic,
        'is_predefined': isPredefined,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}
