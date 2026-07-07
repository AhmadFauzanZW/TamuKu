import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:tamuku/core/constants/app_constants.dart';
import 'package:tamuku/features/location/presentation/screens/qr_generator_screen.dart';

void main() {
  group('QrGeneratorScreen', () {
    testWidgets('renders the QR generator app bar title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QrGeneratorScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text(AppConstants.qrGeneratorTitle),
        findsOneWidget,
      );
    });

    testWidgets('renders the QR instruction text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QrGeneratorScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text(AppConstants.qrInstruction),
        findsOneWidget,
      );
    });

    testWidgets('renders a QrImageView', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QrGeneratorScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('renders the share button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QrGeneratorScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text(AppConstants.qrShareButton),
        findsOneWidget,
      );
    });

    testWidgets('shows loading indicator before data loads', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QrGeneratorScreen()));
      // Only pump once — before the FutureBuilder resolves
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
