import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamuku/core/errors/exceptions.dart';
import 'package:tamuku/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:tamuku/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tamuku/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tamuku/features/auth/domain/entities/user_entity.dart';

// ─── Mocks ────────────────────────────────────────────────────────

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// ─── Fixtures ─────────────────────────────────────────────────────

const tUserMap = <String, dynamic>{
  'uid': 'u1',
  'email': 'admin@tamuku.app',
  'name': 'Admin Utama',
  'photoUrl': null,
  'role': 'admin',
};

const tEmail = 'admin@tamuku.app';
const tPassword = 'rahasia123';

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late MockFirebaseAuth firebaseAuth;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    firebaseAuth = MockFirebaseAuth();
    repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      firebaseAuth: firebaseAuth,
    );
  });

  group('signIn', () {
    test('returns UserEntity and caches the user on success', () async {
      when(
        () => remote.signIn(email: tEmail, password: tPassword),
      ).thenAnswer((_) async => tUserMap);
      when(() => local.cacheUser(any())).thenAnswer((_) async {});

      final result = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      expect(result, isA<UserEntity>());
      expect(result.uid, 'u1');
      expect(result.email, tEmail);
      verify(() => local.cacheUser(tUserMap)).called(1);
    });

    test('propagates AuthException from the remote source', () async {
      when(
        () => remote.signIn(email: tEmail, password: tPassword),
      ).thenThrow(const AuthException('Email atau password salah.'));

      expect(
        () => repository.signIn(email: tEmail, password: tPassword),
        throwsA(isA<AuthException>()),
      );
      verifyNever(() => local.cacheUser(any()));
    });
  });

  group('signInWithGoogle', () {
    test('throws AuthException (not available in this phase)', () async {
      when(
        () => remote.signInWithGoogle(),
      ).thenThrow(const AuthException('Login dengan Google belum tersedia'));

      expect(
        () => repository.signInWithGoogle(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signOut', () {
    test('signs out remotely and clears the local cache', () async {
      when(() => remote.signOut()).thenAnswer((_) async {});
      when(() => local.clearCache()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => remote.signOut()).called(1);
      verify(() => local.clearCache()).called(1);
    });
  });
}
