class CardProgressEntity {
  const CardProgressEntity({
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
  final DateTime nextReview;
  final DateTime? lastReviewed;

  bool isDue() => DateTime.now().isAfter(nextReview) ||
      DateTime.now().isAtSameMomentAs(nextReview);

  CardProgressEntity copyWith({
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    DateTime? nextReview,
    DateTime? lastReviewed,
  }) =>
      CardProgressEntity(
        id: id,
        userId: userId,
        flashcardId: flashcardId,
        easeFactor: easeFactor ?? this.easeFactor,
        intervalDays: intervalDays ?? this.intervalDays,
        repetitions: repetitions ?? this.repetitions,
        nextReview: nextReview ?? this.nextReview,
        lastReviewed: lastReviewed ?? this.lastReviewed,
      );

  factory CardProgressEntity.initial({
    required String id,
    required String userId,
    required String flashcardId,
  }) =>
      CardProgressEntity(
        id: id,
        userId: userId,
        flashcardId: flashcardId,
        easeFactor: 2.5,
        intervalDays: 0,
        repetitions: 0,
        nextReview: DateTime.now(),
      );

  factory CardProgressEntity.fromMap(Map<String, dynamic> map) =>
      CardProgressEntity(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        flashcardId: map['flashcard_id'] as String,
        easeFactor: (map['ease_factor'] as num).toDouble(),
        intervalDays: map['interval_days'] as int,
        repetitions: map['repetitions'] as int,
        nextReview: DateTime.parse(map['next_review'] as String),
        lastReviewed: map['last_reviewed'] != null
            ? DateTime.parse(map['last_reviewed'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'flashcard_id': flashcardId,
        'ease_factor': easeFactor,
        'interval_days': intervalDays,
        'repetitions': repetitions,
        'next_review': nextReview.toIso8601String(),
        'last_reviewed': lastReviewed?.toIso8601String(),
      };
}
