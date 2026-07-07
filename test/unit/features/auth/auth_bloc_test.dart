import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamuku/core/errors/exceptions.dart';
import 'package:tamuku/features/auth/domain/entities/user_entity.dart';
import 'package:tamuku/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamuku/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tamuku/features/auth/presentation/bloc/auth_event.dart';
import 'package:tamuku/features/auth/presentation/bloc/auth_state.dart';

// ─── Mocks ────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

// ─── Fixtures ─────────────────────────────────────────────────────

const tUser = UserEntity(
  uid: 'u1',
  email: 'admin@tamuku.app',
  name: 'Admin Utama',
);

const tEmail = 'admin@tamuku.app';
const tPassword = 'rahasia123';

void main() {
  late MockAuthRepository repository;
  late MockSharedPreferences prefs;

  setUp(() {
    repository = MockAuthRepository();
    prefs = MockSharedPreferences();
  });

  test('initial state is AuthInitial', () {
    final bloc = AuthBloc(authRepository: repository, prefs: prefs);
    expect(bloc.state, isA<AuthInitial>());
    bloc.close();
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on success',
      build: () {
        when(
          () => repository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tUser);
        return AuthBloc(authRepository: repository, prefs: prefs);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>().having((s) => s.user, 'user', tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => repository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthException('Email atau password salah.'));
        return AuthBloc(authRepository: repository, prefs: prefs);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'calls signOut and emits AuthInitial',
      build: () {
        when(() => prefs.remove(any())).thenAnswer((_) async => true);
        when(() => repository.signOut()).thenAnswer((_) async {});
        return AuthBloc(authRepository: repository, prefs: prefs);
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [isA<AuthInitial>()],
      verify: (_) {
        verify(() => prefs.remove('locationId')).called(1);
        verify(() => repository.signOut()).called(1);
      },
    );
  });
}
