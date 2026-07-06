import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamuku/core/constants/app_constants.dart';
import 'package:tamuku/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tamuku/features/auth/presentation/bloc/auth_event.dart';
import 'package:tamuku/features/auth/presentation/bloc/auth_state.dart';
import 'package:tamuku/features/location/presentation/screens/settings_screen.dart';

// ─── Mock ─────────────────────────────────────────────────────────

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockBloc;
  final getIt = GetIt.instance;

  setUp(() async {
    mockBloc = MockAuthBloc();
    when(() => mockBloc.state).thenReturn(AuthInitial());

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    getIt.registerFactory<AuthBloc>(() => mockBloc);
    getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  });

  tearDown(() {
    getIt.unregister<AuthBloc>();
    getIt.unregister<SharedPreferences>();
    mockBloc.close();
  });

  group('SettingsScreen', () {
    testWidgets('renders the settings app bar title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.settingsTitle), findsOneWidget);
    });

    testWidgets('renders two preference switches', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsNWidgets(2));
    });

    testWidgets('renders the logout button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.logoutButton), findsWidgets);
    });

    testWidgets('renders the CSV export action', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.actionExportCSV), findsOneWidget);
    });
  });
}
