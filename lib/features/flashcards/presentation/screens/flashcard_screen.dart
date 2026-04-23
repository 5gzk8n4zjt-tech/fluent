import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool _revealed = false;
  final int _current = 4;
  final int _total = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
                  ),
                  const Expanded(
                    child: Text(
                      'A1 · Everyday objects',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '$_current / $_total',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _current / _total,
                  minHeight: 3,
                  backgroundColor: const Color(0xFFEFEFEC),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Flashcard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      // Image area
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.imagePlaceholder,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                          ),
                          child: const Center(
                            child: Text(
                              'image · apple',
                              style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, thickness: 1, color: AppColors.border),
                      // Word area
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Apple', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600, letterSpacing: -0.8)),
                                const SizedBox(width: 12),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(Icons.volume_up_outlined, size: 16, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text("noun · /ˈæp.əl/", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => setState(() => _revealed = !_revealed),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _revealed
                                      ? const [
                                          Text('Manzana', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        ]
                                      : const [
                                          Text('••••••', style: TextStyle(letterSpacing: 5, color: Color(0xFFC0C0BA), fontSize: 15)),
                                          SizedBox(width: 8),
                                          Text('Toca para revelar', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                        ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 18, bottom: 10),
              child: Text('¿Qué tan bien lo recordaste?', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
            // Answer buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  for (int i = 0; i < _answerButtons.length; i++) ...[
                    Expanded(child: _AnswerButton(data: _answerButtons[i])),
                    if (i < _answerButtons.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerData {
  const _AnswerData(this.label, this.sub, {this.filled = false});
  final String label;
  final String sub;
  final bool filled;
}

const _answerButtons = [
  _AnswerData('Otra vez', '<1m'),
  _AnswerData('Difícil', '6m'),
  _AnswerData('Bien', '10m'),
  _AnswerData('Fácil', '4d', filled: true),
];

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({required this.data});
  final _AnswerData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: data.filled ? AppColors.textPrimary : Colors.transparent,
          border: Border.all(color: data.filled ? AppColors.textPrimary : AppColors.border),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(data.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: data.filled ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(data.sub, style: TextStyle(fontSize: 10, color: data.filled ? Colors.white70 : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
