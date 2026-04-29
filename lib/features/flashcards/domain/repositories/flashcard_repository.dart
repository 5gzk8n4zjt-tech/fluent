import '../entities/flashcard_entity.dart';

abstract class FlashcardRepository {
  Future<List<FlashcardEntity>> getFlashcardsByDeck(String deckId);
  Future<FlashcardEntity> addFlashcardToDeck(
    String deckId,
    String word,
    String translation, {
    String? audioUrl,
    String? imageUrl,
  });
  Future<void> deleteFlashcard(String flashcardId);
}
