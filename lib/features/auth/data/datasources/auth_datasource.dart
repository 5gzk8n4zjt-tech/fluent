import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_client.dart';

class AuthDatasource {
  Future<AuthResponse> signUp(String email, String password) =>
      supabase.auth.signUp(email: email, password: password);

  Future<AuthResponse> signIn(String email, String password) =>
      supabase.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => supabase.auth.signOut();

  Session? get currentSession => supabase.auth.currentSession;

  Future<Map<String, dynamic>?> fetchUser(String userId) =>
      supabase.from('users').select().eq('id', userId).maybeSingle();

  Future<void> insertUser(String id, String email) =>
      supabase.from('users').insert({
        'id': id,
        'email': email,
        'role': 'user',
        'created_at': DateTime.now().toIso8601String(),
      });

  Future<void> updateLevel(String userId, String level) =>
      supabase.from('users').update({'level': level}).eq('id', userId);
}
