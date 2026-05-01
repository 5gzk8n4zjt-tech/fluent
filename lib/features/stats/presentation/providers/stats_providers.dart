import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/stats_datasource.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/repositories/stats_repository.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

final statsDataSourceProvider = Provider<StatsDataSource>(
  (_) => StatsDataSource(),
);

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepositoryImpl(ref.watch(statsDataSourceProvider)),
);

// ── Query providers (autoDispose → always fresh on re-entry) ───────────────

final userStatsProvider =
    FutureProvider.autoDispose.family<StatsEntity, String>((ref, userId) {
  return ref.read(statsRepositoryProvider).getUserStats(userId);
});

final weeklyActivityProvider =
    FutureProvider.autoDispose.family<List<DailyStats>, String>(
        (ref, userId) {
  return ref.read(statsRepositoryProvider).getWeeklyActivity(userId);
});

typedef _SessionParams = ({String userId, int limit});

final sessionHistoryProvider =
    FutureProvider.autoDispose.family<List<SessionSummary>, _SessionParams>(
        (ref, p) {
  return ref
      .read(statsRepositoryProvider)
      .getSessionHistory(p.userId, p.limit);
});
