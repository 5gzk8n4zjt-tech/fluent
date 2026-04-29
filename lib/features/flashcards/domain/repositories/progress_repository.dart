import '../entities/card_progress_entity.dart';

abstract class ProgressRepository {
  Future<List<CardProgressEntity>> getDueCards(String userId, String deckId);
  Future<void> updateProgress(CardProgressEntity progress);
  Future<CardProgressEntity?> getProgressByCard(
      String userId, String flashcardId);
}
