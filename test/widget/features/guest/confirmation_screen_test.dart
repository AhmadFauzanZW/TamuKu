import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamuku/core/constants/app_constants.dart';
import 'package:tamuku/features/guest/domain/entities/guest_entity.dart';
import 'package:tamuku/features/guest/presentation/screens/confirmation_screen.dart';

// ─── Fixtures ─────────────────────────────────────────────────────

final tGuest = GuestEntity(
  guestId: 'g1',
  name: 'Budi Santoso',
  phone: '081298765432',
  email: 'budi@example.com',
  keperluan: Keperluan.meeting,
  instansi: 'PT Maju Jaya',
  locationId: 'loc1',
  checkInTime: DateTime(2026, 7, 6, 10, 0),
);

// ─── Helpers ──────────────────────────────────────────────────────

Widget _buildWidget({GuestEntity? guest}) {
  return MaterialApp(
    onGenerateRoute: (settings) {
      return MaterialPageRoute<ConfirmationScreen>(
        settings: RouteSettings(arguments: guest ?? tGuest),
        builder: (_) => const ConfirmationScreen(),
      );
    },
  );
}

// ─── Tests ────────────────────────────────────────────────────────

void main() {
  group('ConfirmationScreen', () {
    testWidgets('renders success icon', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders thank you title and message', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.thankYouTitle), findsOneWidget);
      expect(find.text(AppConstants.thankYouMessage), findsOneWidget);
    });

    testWidgets('renders guest name', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
    });

    testWidgets('renders guest keperluan', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Meeting'), findsOneWidget);
    });

    testWidgets('renders guest instansi', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('PT Maju Jaya'), findsOneWidget);
    });

    testWidgets('renders Kembali button', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Kembali'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('renders info row labels', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Nama'), findsOneWidget);
      expect(find.text('Keperluan'), findsOneWidget);
      expect(find.text('Instansi'), findsOneWidget);
      expect(find.text('Waktu Check-in'), findsOneWidget);
    });

    testWidgets('renders without instansi when not provided',
        (tester) async {
      final guestNoInstansi = GuestEntity(
        guestId: 'g2',
        name: 'Andi',
        phone: '081234567890',
        keperluan: Keperluan.personal,
        locationId: 'loc1',
        checkInTime: DateTime(2026, 7, 6, 11, 30),
      );

      await tester.pumpWidget(_buildWidget(guest: guestNoInstansi));
      await tester.pumpAndSettle();

      expect(find.text('Instansi'), findsNothing);
    });

    testWidgets('renders info card with border', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
