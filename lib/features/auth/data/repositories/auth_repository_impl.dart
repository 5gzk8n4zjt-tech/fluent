import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl() : _ds = AuthDatasource();

  final AuthDatasource _ds;

  @override
  Future<UserEntity> signUp(String email, String password) async {
    print('DEBUG signUp: iniciando con email=$email');
    try {
      final res = await _ds.signUp(email, password);
      print('DEBUG signUp: respuesta recibida — user.id=${res.user?.id}, session=${res.session != null}');

      final user = res.user ?? (throw Exception('signUp returned null user'));

      print('DEBUG signUp: insertando en tabla users...');
      await _ds.insertUser(user.id, email);
      print('DEBUG signUp: insert OK');

      print('DEBUG signUp: leyendo usuario de tabla users...');
      final data = await _ds.fetchUser(user.id);
      print('DEBUG signUp: fetchUser resultado=${data != null ? 'OK' : 'NULL'}');

      if (data == null) throw Exception('Usuario no encontrado tras el registro');
      return UserEntity.fromMap(data);
    } catch (e, st) {
      print('DEBUG signUp ERROR: $e');
      print('DEBUG signUp STACK: $st');
      rethrow;
    }
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    print('DEBUG signIn: iniciando con email=$email');
    try {
      final res = await _ds.signIn(email, password);
      print('DEBUG signIn: respuesta — user.id=${res.user?.id}');

      final user = res.user ?? (throw Exception('signIn returned null user'));

      print('DEBUG signIn: leyendo usuario de tabla users...');
      final data = await _ds.fetchUser(user.id);
      print('DEBUG signIn: fetchUser resultado=${data != null ? 'OK' : 'NULL'}');

      if (data == null) {
        print('DEBUG signIn: usuario no existe en tabla users, creando automáticamente...');
        await _ds.insertUser(user.id, email);
        print('DEBUG signIn: usuario creado, leyendo nuevamente...');
        final newData = await _ds.fetchUser(user.id);
        if (newData == null) throw Exception('Fallo al crear usuario');
        return UserEntity.fromMap(newData);
      }

      return UserEntity.fromMap(data);
    } catch (e, st) {
      print('DEBUG signIn ERROR: $e');
      print('DEBUG signIn STACK: $st');
      rethrow;
    }
  }

  @override
  Future<void> signOut() => _ds.signOut();

  @override
  Future<UserEntity?> getCurrentUser() async {
    final session = _ds.currentSession;
    print('DEBUG getCurrentUser: session=${session != null ? session.user.id : 'null'}');
    if (session == null) return null;
    final data = await _ds.fetchUser(session.user.id);
    print('DEBUG getCurrentUser: fetchUser=${data != null ? 'OK' : 'NULL'}');
    if (data == null) return null;
    return UserEntity.fromMap(data);
  }

  @override
  Future<void> updateUserLevel(String userId, String level) =>
      _ds.updateLevel(userId, level);
}
