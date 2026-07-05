import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Stream<UserEntity?> get authStateChanges => const Stream.empty();
}
