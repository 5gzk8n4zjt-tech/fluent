import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fluent_card.dart';
import '../../../../shared/widgets/fluent_pill.dart';
import '../../domain/entities/deck_entity.dart';
import '../../domain/value_objects/level.dart';
import '../providers/flashcard_providers.dart';

class DecksTab extends ConsumerStatefulWidget {
  const DecksTab({super.key});

  @override
  ConsumerState<DecksTab> createState() => _DecksTabState();
}

class _DecksTabState extends ConsumerState<DecksTab> {
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(allDecksProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            decksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Error al cargar mazos',
                      style: const TextStyle(color: AppColors.textSecondary))),
              data: (decks) {
                final predefined =
                    decks.where((d) => d.isPredefined).toList();
                final mine = decks.where((d) => !d.isPredefined).toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  children: [
                    const Text('Tus mazos',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.6,
                            height: 1.15)),
                    const SizedBox(height: 4),
                    const Text('Elige un nivel para estudiar',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                    const Text('MAZOS PREDEFINIDOS',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.6)),
                    const SizedBox(height: 12),
                    if (predefined.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text('No hay mazos predefinidos aún.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                      )
                    else
                      for (final deck in predefined) ...[
                        _DeckCard(
                          deck: deck,
                          isExpanded: _expandedId == deck.id,
                          onTap: () => setState(() =>
                              _expandedId =
                                  _expandedId == deck.id ? null : deck.id),
                          onStudy: () => context.go('/study/${deck.id}'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    const SizedBox(height: 8),
                    const Text('MIS MAZOS',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.6)),
                    const SizedBox(height: 12),
                    if (mine.isNotEmpty) ...[
                      for (final deck in mine) ...[
                        _DeckCard(
                          deck: deck,
                          isExpanded: _expandedId == deck.id,
                          onTap: () => setState(() =>
                              _expandedId =
                                  _expandedId == deck.id ? null : deck.id),
                          onStudy: () => context.go('/study/${deck.id}'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                    _DashedContainer(
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.add,
                                color: AppColors.textSecondary, size: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text('Crea tu primer mazo',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 20,
              right: 24,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.deck,
    required this.isExpanded,
    required this.onTap,
    required this.onStudy,
  });

  final DeckEntity deck;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onStudy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: FluentCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                FluentPill(
                  variant: FluentPillVariant.dark,
                  child: Text(deck.level.code,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(deck.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1)),
                      const SizedBox(height: 2),
                      Text(deck.topic,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
            decoration: const BoxDecoration(
                border: Border(
                    left: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                Expanded(
                  child: Text(deck.topic,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                ),
                GestureDetector(
                  onTap: onStudy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Estudiar',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DashedContainer extends StatelessWidget {
  const _DashedContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 4.0, gap = 4.0;
    final paint = Paint()
      ..color = const Color(0xFFD6D6D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    var drawn = 0.0;
    while (drawn < metric.length) {
      canvas.drawPath(metric.extractPath(drawn, drawn + dash), paint);
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
