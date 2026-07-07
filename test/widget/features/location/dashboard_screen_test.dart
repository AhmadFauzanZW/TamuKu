import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tamuku/core/constants/app_constants.dart';
import 'package:tamuku/features/location/presentation/screens/dashboard_screen.dart';

void main() {
  group('DashboardScreen', () {
    testWidgets('renders the dashboard app bar title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
      await tester.pump();

      expect(find.text(AppConstants.dashboardTitle), findsOneWidget);
    });

    testWidgets('renders the summary title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
      await tester.pump();

      expect(
        find.text(AppConstants.dashboardSummaryTitle),
        findsOneWidget,
      );
    });

    testWidgets('renders the chart title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
      await tester.pump();

      expect(find.text(AppConstants.chartTitle), findsOneWidget);
    });

    testWidgets('renders settings icon button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('renders two stat cards', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
      await tester.pump();

      expect(
        find.text(AppConstants.statTodayGuests),
        findsOneWidget,
      );
      expect(
        find.text(AppConstants.statActiveGuests),
        findsOneWidget,
      );
    });
  });
}
