import '../entities/deck_entity.dart';
import '../value_objects/level.dart';

abstract class DeckRepository {
  Future<DeckEntity> getDeckById(String deckId);
  Future<List<DeckEntity>> getAllDecks();
  Future<DeckEntity> createDeck(String title, Level level, String topic);
  Future<void> deleteDeck(String deckId);
}
