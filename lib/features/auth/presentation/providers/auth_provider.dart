import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/constants/supabase_client.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

final supabaseAuthStreamProvider = StreamProvider<supa.AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  ref.watch(supabaseAuthStreamProvider);
  return ref.read(authRepositoryProvider).getCurrentUser();
});

abstract class AuthOperationState {
  const AuthOperationState();
}

class AuthIdle extends AuthOperationState {
  const AuthIdle();
}

class AuthLoading extends AuthOperationState {
  const AuthLoading();
}

class AuthSuccess extends AuthOperationState {
  const AuthSuccess(this.user);
  final UserEntity user;
}

class AuthError extends AuthOperationState {
  const AuthError(this.message);
  final String message;
}

class AuthNotifier extends StateNotifier<AuthOperationState> {
  AuthNotifier(this._repo) : super(const AuthIdle());

  final AuthRepository _repo;

  Future<bool> signUp(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _repo.signUp(email, password);
      state = AuthSuccess(user);
      return true;
    } catch (e) {
      state = AuthError(_friendlyError(e));
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _repo.signIn(email, password);
      state = AuthSuccess(user);
      return true;
    } catch (e) {
      state = AuthError(_friendlyError(e));
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthIdle();
  }

  void reset() => state = const AuthIdle();

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'Este correo ya está registrado.';
    }
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirma tu correo electrónico antes de continuar.';
    }
    if (msg.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return 'Ocurrió un error. Inténtalo de nuevo.';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthOperationState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);
