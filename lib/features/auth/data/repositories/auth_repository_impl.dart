import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/user_mapper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Offline-aware implementation of [AuthRepository].
///
/// **Sign-in**: authenticate remotely → cache user locally → return entity.
/// **Sign-out**: sign out remotely → clear local cache.
  /// **Stream**: maps [FirebaseAuth] auth-state changes to [UserEntity] and
  /// caches the latest user map to local storage.
/// Errors are propagated as thrown exceptions (the [AuthBloc] catches them),
/// matching the existing throw-based [AuthRepository] contract.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl].
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    FirebaseAuth? firebaseAuth,
  }) : _remote = remoteDataSource,
       _local = localDataSource,
       _auth = firebaseAuth ?? FirebaseAuth.instance;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final FirebaseAuth _auth;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final map = await _remote.signIn(email: email, password: password);
    await _local.cacheUser(map);
    return _entityFromMap(map);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    // Delegates to the remote source which throws a friendly Indonesian error.
    final map = await _remote.signInWithGoogle();
    await _local.cacheUser(map);
    return _entityFromMap(map);
  }

  @override
  Future<void> signOut() async {
    await _remote.signOut();
    await _local.clearCache();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final map = UserMapper.toMap(user);
      await _local.cacheUser(map);
      return _entityFromMap(map);
    });
  }

  @override
  Future<UserEntity?> getCachedSession() async {
    final map = await _local.getCachedUser();
    if (map == null) return null;
    return _entityFromMap(map);
  }

  /// Builds a [UserEntity] from a serialized user [map].
  UserEntity _entityFromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      role: map['role'] as String? ?? AppConstants.roleAdmin,
    );
  }
}
