import '../../domain/entities/card_progress_entity.dart';

class CardProgressDTO {
  const CardProgressDTO({
    required this.id,
    required this.userId,
    required this.flashcardId,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.nextReview,
    this.lastReviewed,
  });

  final String id;
  final String userId;
  final String flashcardId;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final String nextReview;
  final String? lastReviewed;

  factory CardProgressDTO.fromMap(Map<String, dynamic> map) => CardProgressDTO(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        flashcardId: map['flashcard_id'] as String,
        easeFactor: (map['ease_factor'] as num).toDouble(),
        intervalDays: map['interval_days'] as int,
        repetitions: map['repetitions'] as int,
        nextReview: map['next_review'] as String,
        lastReviewed: map['last_reviewed'] as String?,
      );

  CardProgressEntity toEntity() => CardProgressEntity(
        id: id,
        userId: userId,
        flashcardId: flashcardId,
        easeFactor: easeFactor,
        intervalDays: intervalDays,
        repetitions: repetitions,
        nextReview: DateTime.parse(nextReview),
        lastReviewed:
            lastReviewed != null ? DateTime.parse(lastReviewed!) : null,
      );

  static Map<String, dynamic> fromEntity(CardProgressEntity entity) => {
        'id': entity.id,
        'user_id': entity.userId,
        'flashcard_id': entity.flashcardId,
        'ease_factor': entity.easeFactor,
        'interval_days': entity.intervalDays,
        'repetitions': entity.repetitions,
        'next_review': entity.nextReview.toUtc().toIso8601String(),
        'last_reviewed': entity.lastReviewed?.toUtc().toIso8601String(),
      };
}
