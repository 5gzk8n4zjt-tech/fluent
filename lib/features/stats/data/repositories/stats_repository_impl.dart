import '../../domain/entities/stats_entity.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_datasource.dart';
import '../models/daily_activity_dto.dart';
import '../models/session_summary_dto.dart';
import '../models/stats_dto.dart';

class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl(this._ds);

  final StatsDataSource _ds;

  @override
  Future<StatsEntity> getUserStats(String userId) async {
    final statsJson = await _ds.getUserStats(userId);
    final cardsByLevel = await _ds.getProgressByLevel(userId);
    return StatsDTO.fromJson(
      {...statsJson, 'user_id': userId},
      cardsByLevel: cardsByLevel,
    ).toEntity();
  }

  @override
  Future<List<DailyStats>> getWeeklyActivity(String userId) async {
    final list = await _ds.getWeeklyActivity(userId);
    return list.map((j) => DailyActivityDTO.fromJson(j).toEntity()).toList();
  }

  @override
  Future<List<SessionSummary>> getSessionHistory(
      String userId, int limit) async {
    final list = await _ds.getSessionHistory(userId, limit);
    return list.map((j) => SessionSummaryDTO.fromJson(j).toEntity()).toList();
  }
}
