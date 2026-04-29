import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/deck_repository_impl.dart';
import '../../data/repositories/flashcard_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/card_progress_entity.dart';
import '../../domain/entities/deck_entity.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../../domain/repositories/progress_repository.dart';

final deckRepositoryProvider = Provider<DeckRepository>(
  (_) => DeckRepositoryImpl(),
);

final flashcardRepositoryProvider = Provider<FlashcardRepository>(
  (_) => FlashcardRepositoryImpl(),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (_) => ProgressRepositoryImpl(),
);

final currentDeckProvider =
    FutureProvider.family<DeckEntity, String>((ref, deckId) {
  return ref.read(deckRepositoryProvider).getDeckById(deckId);
});

typedef StudyCard = ({FlashcardEntity flashcard, CardProgressEntity progress});

typedef _DeckUser = ({String userId, String deckId});

final dueCardsProvider =
    FutureProvider.family<List<StudyCard>, _DeckUser>((ref, params) async {
  final progressList = await ref
      .read(progressRepositoryProvider)
      .getDueCards(params.userId, params.deckId);

  if (progressList.isEmpty) return [];

  final flashcards = await ref
      .read(flashcardRepositoryProvider)
      .getFlashcardsByDeck(params.deckId);

  final flashcardMap = {for (final f in flashcards) f.id: f};

  return [
    for (final p in progressList)
      if (flashcardMap.containsKey(p.flashcardId))
        (flashcard: flashcardMap[p.flashcardId]!, progress: p),
  ];
});
