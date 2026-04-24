import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUp(String email, String password);
  Future<UserEntity> signIn(String email, String password);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateUserLevel(String userId, String level);
}
