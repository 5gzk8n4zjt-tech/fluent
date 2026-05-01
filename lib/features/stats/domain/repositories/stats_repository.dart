import '../entities/stats_entity.dart';

abstract class StatsRepository {
  Future<StatsEntity> getUserStats(String userId);

  /// Returns last 7 days of card review activity.
  Future<List<DailyStats>> getWeeklyActivity(String userId);

  /// Returns last [limit] chat sessions.
  Future<List<SessionSummary>> getSessionHistory(String userId, int limit);
}
