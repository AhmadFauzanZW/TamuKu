import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Stat card displaying a number and label.
///
/// Used on Dashboard screen for "Tamu Hari Ini" and "Tamu Aktif".
/// DESIGN.md Section 7.5 (Stat Card variant).
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.valueColor = AppColors.primary700,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.display.copyWith(color: valueColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
