import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Abstract interface for remote authentication operations via Firebase Auth.
///
/// Each method returns a user [Map] with keys: `uid`, `email`, `name`,
/// `photoUrl`, and `role` — mirroring [UserEntity] serialization.
abstract class AuthRemoteDataSource {
  /// Signs in with [email] and [password]. Returns the user map on success.
  ///
  /// Throws [AuthException] with a Bahasa Indonesia message on failure.
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  });

  /// Google sign-in — not yet available in this phase.
  ///
  /// Always throws [AuthException] with a friendly Indonesian message.
  Future<Map<String, dynamic>> signInWithGoogle();

  /// Signs the current user out of Firebase Auth.
  Future<void> signOut();
}

/// Firebase implementation of [AuthRemoteDataSource].
///
/// Wraps [FirebaseAuth] and maps [FirebaseAuthException] codes to
/// human-friendly Bahasa Indonesia error messages.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Creates an [AuthRemoteDataSourceImpl] with an optional [FirebaseAuth]
  /// override (useful for tests).
  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Gagal masuk. Silakan coba lagi.');
      }
      return _mapUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Terjadi kesalahan tak terduga saat masuk.');
    }
  }

  @override
  Future<Map<String, dynamic>> signInWithGoogle() async {
    throw const AuthException('Login dengan Google belum tersedia');
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      throw const AuthException('Gagal keluar. Silakan coba lagi.');
    }
  }

  /// Builds the user [Map] returned to the repository layer.
  Map<String, dynamic> _mapUser(User user) {
    return <String, dynamic>{
      'uid': user.uid,
      'email': user.email ?? '',
      'name': (user.displayName == null || user.displayName!.isEmpty)
          ? (user.email ?? 'Admin')
          : user.displayName!,
      'photoUrl': user.photoURL,
      'role': AppConstants.roleAdmin,
    };
  }

  /// Maps a [FirebaseAuthException] code to a Bahasa Indonesia message.
  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'user-not-found':
        return 'Email belum terdaftar.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      default:
        return 'Gagal masuk. Silakan coba lagi.';
    }
  }
}
