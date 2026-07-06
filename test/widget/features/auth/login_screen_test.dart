import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamuku/core/constants/app_constants.dart';
import 'package:tamuku/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tamuku/features/auth/presentation/bloc/auth_event.dart';
import 'package:tamuku/features/auth/presentation/bloc/auth_state.dart';
import 'package:tamuku/features/auth/presentation/screens/login_screen.dart';

// ─── Mock ─────────────────────────────────────────────────────────

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockBloc;
  final getIt = GetIt.instance;

  setUp(() {
    mockBloc = MockAuthBloc();
    when(() => mockBloc.state).thenReturn(AuthInitial());
    getIt.registerFactory<AuthBloc>(() => mockBloc);
  });

  tearDown(() {
    getIt.unregister<AuthBloc>();
    mockBloc.close();
  });

  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('renders the login title and button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.loginTitle), findsOneWidget);
      expect(find.text(AppConstants.loginButton), findsOneWidget);
    });

    testWidgets('renders the Google sign-in button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.loginWithGoogle), findsOneWidget);
    });

    testWidgets('login is scrollable', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
