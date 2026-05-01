import '../../../auth/domain/entities/user_entity.dart';
import '../../../flashcards/domain/entities/deck_entity.dart';
import '../../../flashcards/domain/value_objects/level.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_datasource.dart';
import '../models/admin_stats_dto.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._ds);

  final AdminDataSource _ds;

  @override
  Future<List<DeckEntity>> getAllDecks() async {
    final list = await _ds.getAllDecks();
    return list.map(_deckFromJson).toList();
  }

  @override
  Future<DeckEntity> createDeck(
      String title, String level, String topic) async {
    final json = await _ds.createDeck(title, level, topic);
    return _deckFromJson(json);
  }

  @override
  Future<DeckEntity> updateDeck(
      String deckId, String title, String level, String topic) async {
    final json = await _ds.updateDeck(deckId, title, level, topic);
    return _deckFromJson(json);
  }

  @override
  Future<void> deleteDeck(String deckId) => _ds.deleteDeck(deckId);

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final list = await _ds.getAllUsers();
    return list.map((j) => UserEntity.fromMap(j)).toList();
  }

  @override
  Future<AdminStatsEntity> getAdminStats() async {
    final json = await _ds.getAdminStats();
    return AdminStatsDTO.fromJson(json).toEntity();
  }

  // ── Mapping helper (avoids modifying shared DeckDTO) ───────────────────
  DeckEntity _deckFromJson(Map<String, dynamic> j) => DeckEntity(
        id: j['id'] as String,
        title: j['title'] as String,
        level: LevelExtension.fromString(j['level'] as String),
        topic: j['topic'] as String,
        isPredefined: j['is_predefined'] as bool? ?? true,
        createdBy: j['created_by'] as String? ?? 'system',
        createdAt: DateTime.parse(j['created_at'] as String),
        flashcardCount: j['flashcard_count'] as int? ?? 0,
      );
}
