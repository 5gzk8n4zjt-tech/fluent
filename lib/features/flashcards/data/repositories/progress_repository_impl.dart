import '../../domain/entities/card_progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/supabase_flashcard_datasource.dart';
import '../models/card_progress_dto.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl() : _ds = SupabaseFlashcardDatasource();

  final SupabaseFlashcardDatasource _ds;

  @override
  Future<List<CardProgressEntity>> getDueCards(
      String userId, String deckId) async {
    final list = await _ds.getDueCards(userId, deckId);
    return list.map((m) => CardProgressDTO.fromMap(m).toEntity()).toList();
  }

  @override
  Future<void> updateProgress(CardProgressEntity progress) async {
    await _ds.updateProgress(CardProgressDTO.fromEntity(progress));
  }

  @override
  Future<CardProgressEntity?> getProgressByCard(
      String userId, String flashcardId) async {
    final map = await _ds.getProgressByCard(userId, flashcardId);
    if (map == null) return null;
    return CardProgressDTO.fromMap(map).toEntity();
  }
}
