import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/flashcard_datasource.dart';
import '../../data/repositories/deck_repository_impl.dart';
import '../../data/repositories/flashcard_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/card_progress_entity.dart';
import '../../domain/entities/deck_entity.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/srs_algorithm.dart';
import '../../domain/value_objects/level.dart';

// ── Shared datasource ──────────────────────────────────────────────────────
final _datasourceProvider = Provider<FlashcardDataSource>(
  (_) => FlashcardDataSource(),
);

// ── Repositories ───────────────────────────────────────────────────────────
final deckRepositoryProvider = Provider<DeckRepository>(
  (ref) => DeckRepositoryImpl(ref.watch(_datasourceProvider)),
);

final flashcardRepositoryProvider = Provider<FlashcardRepository>(
  (ref) => FlashcardRepositoryImpl(ref.watch(_datasourceProvider)),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepositoryImpl(ref.watch(_datasourceProvider)),
);

// ── Deck providers ─────────────────────────────────────────────────────────
final allDecksProvider = FutureProvider<List<DeckEntity>>((ref) {
  return ref.read(deckRepositoryProvider).getAllDecks();
});

final decksProvider = FutureProvider.family<List<DeckEntity>, Level?>((ref, level) async {
  final all = await ref.read(deckRepositoryProvider).getAllDecks();
  if (level == null) return all;
  return all.where((d) => d.level == level).toList();
});

final currentDeckProvider = FutureProvider.family<DeckEntity, String>((ref, deckId) {
  return ref.read(deckRepositoryProvider).getDeckById(deckId);
});

// ── Study session types ────────────────────────────────────────────────────
typedef StudyCard = ({FlashcardEntity flashcard, CardProgressEntity progress});
typedef _DeckUser = ({String userId, String deckId});

final dueCardsProvider = FutureProvider.family<List<StudyCard>, _DeckUser>((ref, p) async {
  final progressList = await ref.read(progressRepositoryProvider).getDueCards(p.userId, p.deckId);
  if (progressList.isEmpty) return [];
  final flashcards = await ref.read(flashcardRepositoryProvider).getFlashcardsByDeck(p.deckId);
  final byId = {for (final f in flashcards) f.id: f};
  return [
    for (final prog in progressList)
      if (byId.containsKey(prog.flashcardId))
        (flashcard: byId[prog.flashcardId]!, progress: prog),
  ];
});

// ── Study session state ────────────────────────────────────────────────────
class StudySessionState {
  const StudySessionState({
    this.cards = const [],
    this.currentIndex = 0,
    this.isRevealed = false,
    this.isComplete = false,
    this.isSaving = false,
  });

  final List<StudyCard> cards;
  final int currentIndex;
  final bool isRevealed;
  final bool isComplete;
  final bool isSaving;

  StudyCard? get currentCard =>
      cards.isEmpty || isComplete ? null : cards[currentIndex];

  int get reviewedCount => isComplete ? cards.length : currentIndex;

  StudySessionState copyWith({
    List<StudyCard>? cards,
    int? currentIndex,
    bool? isRevealed,
    bool? isComplete,
    bool? isSaving,
  }) =>
      StudySessionState(
        cards: cards ?? this.cards,
        currentIndex: currentIndex ?? this.currentIndex,
        isRevealed: isRevealed ?? this.isRevealed,
        isComplete: isComplete ?? this.isComplete,
        isSaving: isSaving ?? this.isSaving,
      );
}

class CardProgressNotifier extends StateNotifier<StudySessionState> {
  CardProgressNotifier(this._progressRepo) : super(const StudySessionState());

  final ProgressRepository _progressRepo;
  final _srs = SRSAlgorithm();

  void loadSession(List<StudyCard> cards) {
    state = StudySessionState(cards: cards);
  }

  void reveal() {
    if (!state.isRevealed) state = state.copyWith(isRevealed: true);
  }

  Future<void> grade(int grade) async {
    final card = state.currentCard;
    if (card == null || state.isSaving) return;

    state = state.copyWith(isSaving: true);
    final updated = _srs.calculateNextReview(card.progress, grade);
    await _progressRepo.updateProgress(updated);

    final isLast = state.currentIndex >= state.cards.length - 1;
    state = state.copyWith(
      isSaving: false,
      isComplete: isLast,
      currentIndex: isLast ? state.currentIndex : state.currentIndex + 1,
      isRevealed: false,
    );
  }

  void reset() => state = const StudySessionState();
}

final cardProgressNotifier =
    StateNotifierProvider<CardProgressNotifier, StudySessionState>(
  (ref) => CardProgressNotifier(ref.watch(progressRepositoryProvider)),
);
