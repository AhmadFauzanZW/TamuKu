import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tamuku/core/constants/app_constants.dart';
import 'package:tamuku/features/guest/presentation/bloc/scan_cubit.dart';
import 'package:tamuku/features/guest/presentation/screens/scan_screen.dart';

void main() {
  group('ScanScreen', () {
    testWidgets('renders the scan app bar title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScanScreen()));
      await tester.pump();

      expect(find.text(AppConstants.scanTitle), findsOneWidget);
    });

    testWidgets('renders the camera instruction text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScanScreen()));
      await tester.pump();

      expect(
        find.text(AppConstants.cameraInstruction),
        findsOneWidget,
      );
    });

    testWidgets('provides a ScanCubit', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScanScreen()));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (w) => w is BlocProvider<ScanCubit>,
        ),
        findsOneWidget,
      );
    });

    testWidgets('ScanCubit starts with hasScanned = false', (tester) async {
      final cubit = ScanCubit();
      expect(cubit.state.hasScanned, isFalse);
      await cubit.close();
    });
  });
}
