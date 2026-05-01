import '../../../../core/constants/supabase_client.dart';
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
    print('DEBUG signIn: iniciando con email=$email');

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print(
          'DEBUG signIn: respuesta recibida — user.id=${response.user?.id}');

      final user = response.user;
      if (user == null) {
        print('DEBUG signIn: user es NULL después de auth');
        throw Exception('User is null after signin');
      }

      print('DEBUG signIn: leyendo usuario de tabla users...');
      var fetchUser = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      print('DEBUG signIn: fetchUser=$fetchUser');

      if (fetchUser == null) {
        try {
          print(
              'DEBUG signIn: usuario no en tabla, creando automáticamente...');
          await supabase.from('users').insert({
            'id': user.id,
            'email': user.email,
            'full_name': user.email!.split('@')[0],
            'role': 'user',
          });
        } catch (e) {
          // Si falla porque ya existe, ignorar y volver a leer
          print(
              'DEBUG signIn: insert falló (probable duplicate), intentando leer nuevamente...');
        }

        // Intentar leer de nuevo (puede que exista con otro ID)
        fetchUser = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        print('DEBUG signIn: usuario encontrado por email — $fetchUser');
      }

      print('DEBUG signIn: retornando UserEntity');
      return UserEntity.fromMap(fetchUser);
    } catch (e) {
      print('DEBUG signIn ERROR: $e');
      rethrow;
    }
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
