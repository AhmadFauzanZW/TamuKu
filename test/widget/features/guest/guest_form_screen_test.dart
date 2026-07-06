import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamuku/core/constants/app_constants.dart';
import 'package:tamuku/features/guest/presentation/bloc/guest_bloc.dart';
import 'package:tamuku/features/guest/presentation/bloc/guest_event.dart';
import 'package:tamuku/features/guest/presentation/bloc/guest_state.dart';
import 'package:tamuku/features/guest/presentation/screens/guest_form_screen.dart';

// ─── Mock ─────────────────────────────────────────────────────────

class MockGuestBloc extends MockBloc<GuestEvent, GuestState>
    implements GuestBloc {}

// ─── Tests ────────────────────────────────────────────────────────

void main() {
  late MockGuestBloc mockBloc;
  final getIt = GetIt.instance;

  setUp(() {
    mockBloc = MockGuestBloc();
    when(() => mockBloc.state).thenReturn(GuestInitial());
    getIt.registerFactory<GuestBloc>(() => mockBloc);
  });

  tearDown(() {
    getIt.unregister<GuestBloc>();
    mockBloc.close();
  });

  group('GuestFormScreen', () {
    testWidgets('renders app bar title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuestFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Formulir Tamu'), findsOneWidget);
    });

    testWidgets('renders subtitle instruction text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuestFormScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Silakan isi data kunjungan Anda'),
        findsOneWidget,
      );
    });

    testWidgets('renders all form field labels', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuestFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.nameLabel), findsOneWidget);
      expect(find.text(AppConstants.phoneLabel), findsOneWidget);
      expect(find.text(AppConstants.keperluanLabel), findsOneWidget);
      expect(find.text(AppConstants.instansiLabel), findsOneWidget);
    });

    testWidgets('renders submit button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuestFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.submitButton), findsOneWidget);
    });

    testWidgets('renders form as scrollable', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuestFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('renders Form widget', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuestFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('has multiple TextFormFields for input',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuestFormScreen()));
      await tester.pumpAndSettle();

      // Name, phone, email, instansi = 4 TextFormFields
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('shows photo placeholder', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuestFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Foto (opsional)'), findsOneWidget);
    });
  });
}
