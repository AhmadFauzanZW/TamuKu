abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> signIn({required String email, required String password});
  Future<Map<String, dynamic>> signInWithGoogle();
  Future<void> signOut();
}
