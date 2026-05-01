class StatsEntity {
  const StatsEntity({
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

  /// Words learned per level. Keys: 'a1', 'a2', 'b1', 'b2'.
  final Map<String, int> cardsByLevel;

  Map<String, int> progressByLevel() => cardsByLevel;
}

class DailyStats {
  const DailyStats({required this.day, required this.count});
  final DateTime day;
  final int count;
}

class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.startedAt,
    required this.topic,
    this.messageCount = 0,
  });
  final String id;
  final DateTime startedAt;
  final String topic;
  final int messageCount;
}
