import '../../domain/entities/flashcard_entity.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/supabase_flashcard_datasource.dart';
import '../models/flashcard_dto.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  FlashcardRepositoryImpl() : _ds = SupabaseFlashcardDatasource();

  final SupabaseFlashcardDatasource _ds;

  @override
  Future<List<FlashcardEntity>> getFlashcardsByDeck(String deckId) async {
    final list = await _ds.getFlashcardsByDeck(deckId);
    return list.map((m) => FlashcardDTO.fromMap(m).toEntity()).toList();
  }

  @override
  Future<FlashcardEntity> addFlashcardToDeck(
    String deckId,
    String word,
    String translation, {
    String? audioUrl,
    String? imageUrl,
  }) async {
    final map = await _ds.addFlashcardToDeck(
      deckId,
      word,
      translation,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
    );
    return FlashcardDTO.fromMap(map).toEntity();
  }

  @override
  Future<void> deleteFlashcard(String flashcardId) =>
      _ds.deleteFlashcard(flashcardId);
}
