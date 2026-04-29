import '../../domain/entities/card_progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/flashcard_datasource.dart';
import '../models/card_progress_dto.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._ds);

  final FlashcardDataSource _ds;

  @override
  Future<List<CardProgressEntity>> getDueCards(
      String userId, String deckId) async {
    final list = await _ds.getDueCards(userId, deckId);
    return list.map((m) => CardProgressDTO.fromJson(m).toEntity()).toList();
  }

  @override
  Future<void> updateProgress(CardProgressEntity progress) =>
      _ds.updateProgress(progress.id, CardProgressDTO.fromEntity(progress));

  @override
  Future<CardProgressEntity?> getProgressByCard(
      String userId, String flashcardId) async {
    final map = await _ds.getProgressByCard(userId, flashcardId);
    return map != null ? CardProgressDTO.fromJson(map).toEntity() : null;
  }
}
