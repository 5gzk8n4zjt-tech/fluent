import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fluent_card.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 8),
            const Text('Tu progreso', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.6, height: 1.15)),
            const SizedBox(height: 4),
            const Text('Últimos 30 días', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            // Overview row
            Row(
              children: [
                for (int i = 0; i < _overviewStats.length; i++) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_overviewStats[i].$1, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.5, fontFeatures: [FontFeature.tabularFigures()])),
                          const SizedBox(height: 4),
                          Text(_overviewStats[i].$2, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
                        ],
                      ),
                    ),
                  ),
                  if (i < _overviewStats.length - 1) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Level progress
            FluentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PROGRESO POR NIVEL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 16),
                  for (int i = 0; i < _levelProgress.length; i++) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_levelProgress[i].$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()])),
                        Text('${(_levelProgress[i].$2 * 100).toInt()}%', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFeatures: [FontFeature.tabularFigures()])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _levelProgress[i].$2,
                        minHeight: 4,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                      ),
                    ),
                    if (i < _levelProgress.length - 1) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Weekly activity
            FluentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('ACTIVIDAD SEMANAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('tarjetas / día', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 110,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (int i = 0; i < _weeklyData.length; i++) ...[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: _weeklyData[i].$2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.textPrimary,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_weeklyData[i].$1, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          if (i < _weeklyData.length - 1) const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Divider(height: 1, thickness: 1, color: AppColors.border),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Recent sessions
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Text('SESIONES RECIENTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  ),
                  for (final s in _recentSessions)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEFEFEC)))),
                      child: Row(
                        children: [
                          SizedBox(width: 80, child: Text(s.$1, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                          Expanded(child: Text(s.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                          Text(s.$3, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFeatures: [FontFeature.tabularFigures()])),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

const _overviewStats = [('248', 'Palabras aprendidas'), ('34', 'Sesiones'), ('21', 'Días activos')];

const _levelProgress = [('A1', 1.0), ('A2', 0.6), ('B1', 0.2), ('B2', 0.0)];

const _weeklyData = [('L', 0.62), ('M', 0.90), ('X', 0.48), ('J', 0.28), ('V', 0.78), ('S', 1.00), ('D', 0.20)];

const _recentSessions = [
  ('Hoy', 'A2 · Daily routines', '18 tarjetas'),
  ('Ayer', 'A1 · Everyday objects', '12 tarjetas'),
  ('21 abr', 'B1 · Work & travel', '24 tarjetas'),
];
