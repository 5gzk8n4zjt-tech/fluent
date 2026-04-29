import '../../domain/entities/deck_entity.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/value_objects/level.dart';
import '../datasources/supabase_flashcard_datasource.dart';
import '../models/deck_dto.dart';

class DeckRepositoryImpl implements DeckRepository {
  DeckRepositoryImpl() : _ds = SupabaseFlashcardDatasource();

  final SupabaseFlashcardDatasource _ds;

  @override
  Future<DeckEntity> getDeckById(String deckId) async {
    final map = await _ds.getDeckById(deckId);
    return DeckDTO.fromMap(map).toEntity();
  }

  @override
  Future<List<DeckEntity>> getAllDecks() async {
    final list = await _ds.getAllDecks();
    return list.map((m) => DeckDTO.fromMap(m).toEntity()).toList();
  }

  @override
  Future<DeckEntity> createDeck(
      String title, Level level, String topic) async {
    final map = await _ds.createDeck(title, level.code, topic);
    return DeckDTO.fromMap(map).toEntity();
  }

  @override
  Future<void> deleteDeck(String deckId) => _ds.deleteDeck(deckId);
}
