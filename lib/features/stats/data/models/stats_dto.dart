import '../../domain/entities/stats_entity.dart';

class StatsDTO {
  const StatsDTO({
    required this.userId,
    required this.totalCardsReviewed,
    required this.totalSessions,
    required this.cardsLearned,
    this.lastActive,
    this.cardsByLevel = const {},
  });

  final String userId;
  final int totalCardsReviewed;
  final int totalSessions;
  final int cardsLearned;
  final DateTime? lastActive;
  final Map<String, int> cardsByLevel;

  factory StatsDTO.fromJson(
    Map<String, dynamic> json, {
    Map<String, int> cardsByLevel = const {},
  }) =>
      StatsDTO(
        userId: json['user_id'] as String? ?? '',
        totalCardsReviewed: json['total_cards_reviewed'] as int? ?? 0,
        totalSessions: json['total_sessions'] as int? ?? 0,
        cardsLearned: json['cards_learned'] as int? ?? 0,
        lastActive: json['last_active'] != null
            ? DateTime.parse(json['last_active'] as String)
            : null,
        cardsByLevel: cardsByLevel,
      );

  StatsEntity toEntity() => StatsEntity(
        userId: userId,
        totalCardsReviewed: totalCardsReviewed,
        totalSessions: totalSessions,
        cardsLearned: cardsLearned,
        lastActive: lastActive,
        cardsByLevel: cardsByLevel,
      );
}
