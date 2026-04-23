import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fluent_card.dart';
import '../../../../shared/widgets/fluent_pill.dart';

class _Deck {
  const _Deck(this.level, this.topic, this.count, this.subs);
  final String level;
  final String topic;
  final int count;
  final List<String> subs;
}

const _decks = [
  _Deck('A1', 'Everyday objects', 48, ['Home & kitchen', 'Clothes', 'Food basics']),
  _Deck('A2', 'Daily routines', 64, []),
  _Deck('B1', 'Work & travel', 96, []),
  _Deck('B2', 'Opinions & debate', 112, []),
];

class DecksTab extends StatefulWidget {
  const DecksTab({super.key});

  @override
  State<DecksTab> createState() => _DecksTabState();
}

class _DecksTabState extends State<DecksTab> {
  int _expanded = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
              children: [
                const Text('Your decks', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.6, height: 1.15)),
                const SizedBox(height: 4),
                const Text('Choose a level to study', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                const Text('PREDEFINED DECKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.6)),
                const SizedBox(height: 12),
                for (int i = 0; i < _decks.length; i++) ...[
                  GestureDetector(
                    onTap: () => setState(() => _expanded = _expanded == i ? -1 : i),
                    child: FluentCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: Row(
                        children: [
                          FluentPill(
                            variant: FluentPillVariant.dark,
                            child: Text(_decks[i].level, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_decks[i].topic, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1)),
                                const SizedBox(height: 2),
                                Text('${_decks[i].count} cards', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Icon(
                            _expanded == i ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_expanded == i && _decks[i].subs.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    for (final sub in _decks[i].subs)
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 11, 14, 11),
                        margin: const EdgeInsets.only(left: 16),
                        decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColors.border))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(sub, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                            const Text('16 cards', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                const Text('MY DECKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.6)),
                const SizedBox(height: 12),
                _DashedContainer(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.add, color: AppColors.textSecondary, size: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text('Create your first deck', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 24,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(28)),
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
