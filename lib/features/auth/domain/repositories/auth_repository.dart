import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn({required String email, required String password});
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;

  /// Returns the cached user from local storage, or `null` if none.
  Future<UserEntity?> getCachedSession();
}
