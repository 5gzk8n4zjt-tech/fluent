import '../../domain/entities/deck_entity.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/value_objects/level.dart';
import '../datasources/flashcard_datasource.dart';
import '../models/deck_dto.dart';

class DeckRepositoryImpl implements DeckRepository {
  DeckRepositoryImpl(this._ds);

  final FlashcardDataSource _ds;

  @override
  Future<DeckEntity> getDeckById(String deckId) async =>
      DeckDTO.fromJson(await _ds.getDeckById(deckId)).toEntity();

  @override
  Future<List<DeckEntity>> getAllDecks() async {
    final list = await _ds.getAllDecks();
    return list.map((m) => DeckDTO.fromJson(m).toEntity()).toList();
  }

  @override
  Future<DeckEntity> createDeck(String title, Level level, String topic) async =>
      DeckDTO.fromJson(await _ds.createDeck(title, level.code, topic)).toEntity();

  @override
  Future<void> deleteDeck(String deckId) => _ds.deleteDeck(deckId);
}
