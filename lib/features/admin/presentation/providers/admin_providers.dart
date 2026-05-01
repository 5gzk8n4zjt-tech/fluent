import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../flashcards/domain/entities/deck_entity.dart';
import '../../data/datasources/admin_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admin_repository.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

final adminDataSourceProvider = Provider<AdminDataSource>(
  (_) => AdminDataSource(),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepositoryImpl(ref.watch(adminDataSourceProvider)),
);

// ── Query providers ────────────────────────────────────────────────────────

final allDecksAdminProvider = FutureProvider<List<DeckEntity>>((ref) {
  return ref.read(adminRepositoryProvider).getAllDecks();
});

final allUsersProvider = FutureProvider<List<UserEntity>>((ref) {
  return ref.read(adminRepositoryProvider).getAllUsers();
});

final adminStatsProvider = FutureProvider<AdminStatsEntity>((ref) {
  return ref.read(adminRepositoryProvider).getAdminStats();
});

// ── Mutation state ─────────────────────────────────────────────────────────

class AdminActionsState {
  const AdminActionsState({this.isLoading = false, this.error});
  final bool isLoading;
  final String? error;
}

class AdminActionsNotifier extends StateNotifier<AdminActionsState> {
  AdminActionsNotifier(this._repo, this._ref)
      : super(const AdminActionsState());

  final AdminRepository _repo;
  final Ref _ref;

  Future<bool> createDeck(String title, String level, String topic) =>
      _run(() => _repo.createDeck(title, level, topic));

  Future<bool> updateDeck(
          String id, String title, String level, String topic) =>
      _run(() => _repo.updateDeck(id, title, level, topic));

  Future<bool> deleteDeck(String id) => _run(() => _repo.deleteDeck(id));

  Future<bool> _run(Future<dynamic> Function() action) async {
    state = const AdminActionsState(isLoading: true);
    try {
      await action();
      _ref.invalidate(allDecksAdminProvider);
      _ref.invalidate(adminStatsProvider);
      state = const AdminActionsState();
      return true;
    } catch (e) {
      state = AdminActionsState(error: e.toString());
      return false;
    }
  }

  void clearError() => state = const AdminActionsState();
}

final adminActionsProvider =
    StateNotifierProvider<AdminActionsNotifier, AdminActionsState>(
  (ref) => AdminActionsNotifier(
    ref.watch(adminRepositoryProvider),
    ref,
  ),
);
