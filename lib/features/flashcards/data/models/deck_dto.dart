import '../../domain/entities/deck_entity.dart';
import '../../domain/value_objects/level.dart';

class DeckDTO {
  const DeckDTO({
    required this.id,
    required this.title,
    required this.level,
    required this.topic,
    required this.isPredefined,
    required this.createdBy,
    required this.createdAt,
    this.flashcardCount = 0,
  });

  final String id;
  final String title;
  final String level;
  final String topic;
  final bool isPredefined;
  final String createdBy;
  final String createdAt;
  final int flashcardCount;

  factory DeckDTO.fromMap(Map<String, dynamic> map) => DeckDTO(
        id: map['id'] as String,
        title: map['title'] as String,
        level: map['level'] as String,
        topic: map['topic'] as String,
        isPredefined: map['is_predefined'] as bool? ?? false,
        createdBy: map['created_by'] as String,
        createdAt: map['created_at'] as String,
        flashcardCount: map['flashcard_count'] as int? ?? 0,
      );

  DeckEntity toEntity() => DeckEntity(
        id: id,
        title: title,
        level: LevelExtension.fromString(level),
        topic: topic,
        isPredefined: isPredefined,
        createdBy: createdBy,
        createdAt: DateTime.parse(createdAt),
        flashcardCount: flashcardCount,
      );
}
