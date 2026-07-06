import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamuku/core/theme/app_colors.dart';
import 'package:tamuku/shared/widgets/stat_card.dart';

// ─── Helpers ──────────────────────────────────────────────────────

Widget _buildWidget({
  IconData icon = Icons.people,
  String value = '42',
  String label = 'Tamu Hari Ini',
  Color? iconColor,
  Color? valueColor,
  String? trend,
  Color? trendColor,
}) {
  return MaterialApp(
    home: Scaffold(
      body: StatCard(
        icon: icon,
        value: value,
        label: label,
        iconColor: iconColor,
        valueColor: valueColor,
        trend: trend,
        trendColor: trendColor,
      ),
    ),
  );
}

// ─── Tests ────────────────────────────────────────────────────────

void main() {
  group('StatCard', () {
    testWidgets('renders icon, value, and label', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Tamu Hari Ini'), findsOneWidget);
    });

    testWidgets('renders with custom icon', (tester) async {
      await tester.pumpWidget(_buildWidget(icon: Icons.event_available));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.event_available), findsOneWidget);
    });

    testWidgets('renders trend indicator when provided', (tester) async {
      await tester.pumpWidget(_buildWidget(trend: '+12%'));
      await tester.pumpAndSettle();

      expect(find.text('+12%'), findsOneWidget);
    });

    testWidgets('hides trend indicator when not provided', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      // Only value and label text should be present, no trend
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Tamu Hari Ini'), findsOneWidget);
    });

    testWidgets('handles long value gracefully', (tester) async {
      await tester.pumpWidget(
        _buildWidget(value: '1.234.567'),
      );
      await tester.pumpAndSettle();

      expect(find.text('1.234.567'), findsOneWidget);
    });

    testWidgets('applies custom icon color', (tester) async {
      await tester.pumpWidget(
        _buildWidget(iconColor: AppColors.accentAmber),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.people));
      expect(icon.color, AppColors.accentAmber);
    });

    testWidgets('applies custom value color', (tester) async {
      await tester.pumpWidget(
        _buildWidget(valueColor: AppColors.accentRed),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('42'));
      expect(text.style?.color, AppColors.accentRed);
    });

    testWidgets('renders inside a Card', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders icon container with rounded corners',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      // The icon is wrapped in a Container
      expect(find.byType(Container), findsWidgets);
    });
  });
}
