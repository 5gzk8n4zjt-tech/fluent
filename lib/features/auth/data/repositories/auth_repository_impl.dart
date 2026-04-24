import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl() : _ds = AuthDatasource();

  final AuthDatasource _ds;

  @override
  Future<UserEntity> signUp(String email, String password) async {
    final res = await _ds.signUp(email, password);
    final user = res.user ?? (throw Exception('signUp returned null user'));
    await _ds.insertUser(user.id, email);
    final data = await _ds.fetchUser(user.id);
    if (data == null) throw Exception('Usuario no encontrado tras el registro');
    return UserEntity.fromMap(data);
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final res = await _ds.signIn(email, password);
    final user = res.user ?? (throw Exception('signIn returned null user'));
    final data = await _ds.fetchUser(user.id);
    if (data == null) throw Exception('Usuario no encontrado');
    return UserEntity.fromMap(data);
  }

  @override
  Future<void> signOut() => _ds.signOut();

  @override
  Future<UserEntity?> getCurrentUser() async {
    final session = _ds.currentSession;
    if (session == null) return null;
    final data = await _ds.fetchUser(session.user.id);
    if (data == null) return null;
    return UserEntity.fromMap(data);
  }

  @override
  Future<void> updateUserLevel(String userId, String level) =>
      _ds.updateLevel(userId, level);
}
