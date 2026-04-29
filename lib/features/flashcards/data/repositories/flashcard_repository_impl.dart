import '../../domain/entities/flashcard_entity.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_datasource.dart';
import '../models/flashcard_dto.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  FlashcardRepositoryImpl(this._ds);

  final FlashcardDataSource _ds;

  @override
  Future<List<FlashcardEntity>> getFlashcardsByDeck(String deckId) async {
    final list = await _ds.getFlashcardsByDeck(deckId);
    return list.map((m) => FlashcardDTO.fromJson(m).toEntity()).toList();
  }

  @override
  Future<FlashcardEntity> addFlashcardToDeck(
    String deckId,
    String word,
    String translation, {
    String? audioUrl,
    String? imageUrl,
  }) async {
    final map = await _ds.addFlashcardToDeck(deckId, word, translation,
        audioUrl: audioUrl, imageUrl: imageUrl);
    return FlashcardDTO.fromJson(map).toEntity();
  }

  @override
  Future<void> deleteFlashcard(String flashcardId) =>
      _ds.deleteFlashcard(flashcardId);
}
