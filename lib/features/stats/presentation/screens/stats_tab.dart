import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/supabase_client.dart';
import '../../../../shared/widgets/fluent_card.dart';
import '../../domain/entities/stats_entity.dart';
import '../providers/stats_providers.dart';

class StatsTab extends ConsumerWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    final statsAsync = ref.watch(userStatsProvider(userId));
    final weeklyAsync = ref.watch(weeklyActivityProvider(userId));
    final historyAsync =
        ref.watch(sessionHistoryProvider((userId: userId, limit: 5)));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 8),
            const Text('Tu progreso',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.6,
                    height: 1.15)),
            const SizedBox(height: 4),
            const Text('Últimos 30 días',
                style:
                    TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            // ── Card 1: Métricas principales ──────────────────────────
            statsAsync.when(
              loading: () => const _MetricRowSkeleton(),
              error: (e, _) =>
                  const _ErrorChip(label: 'Error al cargar estadísticas'),
              data: (stats) => _MetricRow(stats: stats),
            ),
            const SizedBox(height: 16),

            // ── Card 2: Progreso por nivel ─────────────────────────────
            statsAsync.when(
              loading: () => const _CardSkeleton(height: 140),
              error: (e, st) => const SizedBox.shrink(),
              data: (stats) => _LevelProgressCard(stats: stats),
            ),
            const SizedBox(height: 16),

            // ── Card 3: Actividad semanal ──────────────────────────────
            weeklyAsync.when(
              loading: () => const _CardSkeleton(height: 180),
              error: (e, st) => const SizedBox.shrink(),
              data: (days) => _WeeklyActivityCard(days: days),
            ),
            const SizedBox(height: 16),

            // ── Card 4: Historial de sesiones ──────────────────────────
            historyAsync.when(
              loading: () => const _CardSkeleton(height: 160),
              error: (e, st) => const SizedBox.shrink(),
              data: (sessions) => _SessionHistoryCard(sessions: sessions),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Card 1: Métricas principales ───────────────────────────────────────────

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.stats});
  final StatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      (value: '${stats.cardsLearned}', label: 'Palabras\naprendidas'),
      (value: '${stats.totalSessions}', label: 'Sesiones\nde chat'),
      (
        value: stats.lastActive != null
            ? _lastActiveLabel(stats.lastActive!)
            : '–',
        label: 'Última\nsesión'
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(items[i].value,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          fontFeatures: [FontFeature.tabularFigures()])),
                  const SizedBox(height: 4),
                  Text(items[i].label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.3)),
                ],
              ),
            ),
          ),
          if (i < items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  String _lastActiveLabel(DateTime lastActive) {
    final diff = DateTime.now().difference(lastActive).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return 'Hace $diff d';
  }
}

// ── Card 2: Progreso por nivel ─────────────────────────────────────────────

class _LevelProgressCard extends StatelessWidget {
  const _LevelProgressCard({required this.stats});
  final StatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final byLevel = stats.progressByLevel();
    final maxCount =
        byLevel.values.fold(0, (m, v) => v > m ? v : m);

    const levels = ['a1', 'a2', 'b1', 'b2'];

    return FluentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PROGRESO POR NIVEL',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 16),
          for (int i = 0; i < levels.length; i++) ...[
            _LevelBar(
              label: levels[i].toUpperCase(),
              count: byLevel[levels[i]] ?? 0,
              maxCount: maxCount,
            ),
            if (i < levels.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _LevelBar extends StatelessWidget {
  const _LevelBar(
      {required this.label,
      required this.count,
      required this.maxCount});
  final String label;
  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final fraction =
        maxCount > 0 ? (count / maxCount).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()])),
            Text('$count palabras',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFeatures: [FontFeature.tabularFigures()])),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 4,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ── Card 3: Actividad semanal (fl_chart BarChart) ──────────────────────────

class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard({required this.days});
  final List<DailyStats> days;

  static const _weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final last7 = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i)),
    );

    // Build lookup map keyed by 'YYYY-MM-DD'
    final activityMap = <String, int>{};
    for (final d in days) {
      final key =
          '${d.day.year}-${d.day.month.toString().padLeft(2, '0')}-${d.day.day.toString().padLeft(2, '0')}';
      activityMap[key] = d.count;
    }

    final counts = last7.map((d) {
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return activityMap[key] ?? 0;
    }).toList();

    final maxVal =
        counts.fold(0, (m, v) => v > m ? v : m).toDouble();
    final chartMaxY = maxVal < 1 ? 5.0 : (maxVal * 1.35).ceilToDouble();

    final barGroups = List.generate(
      7,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: counts[i].toDouble(),
            width: 16,
            color: AppColors.textPrimary,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ],
      ),
    );

    return FluentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('ACTIVIDAD SEMANAL',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5)),
              Text('tarjetas / día',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartMaxY,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= 7) return const SizedBox();
                        final label =
                            _weekdayLabels[last7[idx].weekday - 1];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(label,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 4: Historial de sesiones ──────────────────────────────────────────

class _SessionHistoryCard extends StatelessWidget {
  const _SessionHistoryCard({required this.sessions});
  final List<SessionSummary> sessions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Text('SESIONES RECIENTES',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5)),
          ),
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text('No hay sesiones aún.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            )
          else
            for (final s in sessions)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xFFEFEFEC)))),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text(
                        _formatDate(s.startedAt),
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: Text(s.topic,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Hoy';
    if (d == today.subtract(const Duration(days: 1))) return 'Ayer';
    return DateFormat('d MMM', 'es').format(dt);
  }
}

// ── Skeleton / error helpers ───────────────────────────────────────────────

class _MetricRowSkeleton extends StatelessWidget {
  const _MetricRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 3; i++) ...[
          Expanded(
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (i < 2) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
    );
  }
}

class _ErrorChip extends StatelessWidget {
  const _ErrorChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary)),
    );
  }
}
