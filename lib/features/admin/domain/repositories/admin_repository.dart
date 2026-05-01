import '../../../auth/domain/entities/user_entity.dart';
import '../../../flashcards/domain/entities/deck_entity.dart';
import '../entities/admin_entity.dart';

abstract class AdminRepository {
  Future<List<DeckEntity>> getAllDecks();
  Future<DeckEntity> createDeck(String title, String level, String topic);
  Future<DeckEntity> updateDeck(
      String deckId, String title, String level, String topic);
  Future<void> deleteDeck(String deckId);
  Future<List<UserEntity>> getAllUsers();
  Future<AdminStatsEntity> getAdminStats();
}
