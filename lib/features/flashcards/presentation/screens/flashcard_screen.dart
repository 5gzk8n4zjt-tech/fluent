import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/supabase_client.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../../domain/value_objects/level.dart';
import '../providers/flashcard_providers.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key, required this.deckId});
  final String deckId;

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  bool _sessionLoaded = false;

  @override
  void initState() {
    super.initState();
    // Reset session state on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardProgressNotifier.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    final deckAsync = ref.watch(currentDeckProvider(widget.deckId));
    final dueAsync = ref.watch(
        dueCardsProvider((userId: userId, deckId: widget.deckId)));
    final session = ref.watch(cardProgressNotifier);

    // Load session once due cards arrive
    if (!_sessionLoaded && dueAsync.valueOrNull != null) {
      _sessionLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(cardProgressNotifier.notifier)
            .loadSession(dueAsync.valueOrNull!);
      });
    }

    if (dueAsync.isLoading || deckAsync.isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (dueAsync.hasError) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${dueAsync.error}',
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final deck = deckAsync.valueOrNull;
    final cards = session.cards;

    // No cards or session complete
    if (cards.isEmpty || session.isComplete) {
      return _CompletionScreen(
        deckTitle: deck?.title ?? widget.deckId,
        reviewedCount: session.reviewedCount,
        onBack: () {
          ref.read(cardProgressNotifier.notifier).reset();
          context.pop();
        },
      );
    }

    final card = session.currentCard!;
    final total = cards.length;

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
                    onTap: () {
                      ref.read(cardProgressNotifier.notifier).reset();
                      context.pop();
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        size: 20, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      deck != null
                          ? '${deck.level.code} · ${deck.title}'
                          : widget.deckId,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '${session.currentIndex + 1} / $total',
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
                  value: (session.currentIndex + 1) / total,
                  minHeight: 3,
                  backgroundColor: const Color(0xFFEFEFEC),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Card face
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FlashcardFace(
                  flashcard: card.flashcard,
                  revealed: session.isRevealed,
                  onReveal: () =>
                      ref.read(cardProgressNotifier.notifier).reveal(),
                ),
              ),
            ),
            // Grade buttons (only when revealed)
            if (session.isRevealed) ...[
              const Padding(
                padding: EdgeInsets.only(top: 18, bottom: 10),
                child: Text('¿Qué tan bien lo recordaste?',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    for (int i = 0; i < _gradeOptions.length; i++) ...[
                      Expanded(
                        child: _GradeButton(
                          data: _gradeOptions[i],
                          disabled: session.isSaving,
                          onTap: () => ref
                              .read(cardProgressNotifier.notifier)
                              .grade(_gradeOptions[i].grade),
                        ),
                      ),
                      if (i < _gradeOptions.length - 1)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ] else
              const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// ── Card face widget ────────────────────────────────────────────────────────
class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace({
    required this.flashcard,
    required this.revealed,
    required this.onReveal,
  });

  final FlashcardEntity flashcard;
  final bool revealed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Image / placeholder
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.imagePlaceholder,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: flashcard.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(11)),
                      child: Image.network(flashcard.imageUrl!,
                          fit: BoxFit.cover, width: double.infinity),
                    )
                  : Center(
                      child: Text(
                        flashcard.word.toLowerCase(),
                        style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5),
                      ),
                    ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          // Word + reveal
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                Text(
                  flashcard.word,
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.8),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: revealed ? null : onReveal,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: revealed
                          ? [
                              Text(flashcard.translation,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary))
                            ]
                          : const [
                              Text('••••••',
                                  style: TextStyle(
                                      letterSpacing: 5,
                                      color: Color(0xFFC0C0BA),
                                      fontSize: 15)),
                              SizedBox(width: 8),
                              Text('Toca para revelar',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                            ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completion screen ───────────────────────────────────────────────────────
class _CompletionScreen extends StatelessWidget {
  const _CompletionScreen({
    required this.deckTitle,
    required this.reviewedCount,
    required this.onBack,
  });

  final String deckTitle;
  final int reviewedCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final hasCards = reviewedCount > 0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(hasCards ? '✅' : '🎉',
                  style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 24),
              Text(
                hasCards ? 'Sesión completada' : '¡Al día!',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.6),
              ),
              const SizedBox(height: 10),
              Text(
                hasCards
                    ? 'Revisaste $reviewedCount tarjeta${reviewedCount != 1 ? 's' : ''} de "$deckTitle".'
                    : 'No hay tarjetas pendientes en "$deckTitle" por ahora.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Volver',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Grade options ───────────────────────────────────────────────────────────
class _GradeData {
  const _GradeData(this.label, this.sub, this.grade, {this.filled = false});
  final String label;
  final String sub;
  final int grade;
  final bool filled;
}

const _gradeOptions = [
  _GradeData('Otra vez', '<1m', 0),
  _GradeData('Difícil', '~6m', 1),
  _GradeData('Bien', '~1d', 3),
  _GradeData('Fácil', '~4d', 4, filled: true),
];

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.data,
    required this.onTap,
    this.disabled = false,
  });
  final _GradeData data;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: data.filled ? AppColors.textPrimary : Colors.transparent,
            border: Border.all(
                color: data.filled ? AppColors.textPrimary : AppColors.border),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(data.label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: data.filled ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(data.sub,
                  style: TextStyle(
                      fontSize: 10,
                      color: data.filled ? Colors.white70 : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
