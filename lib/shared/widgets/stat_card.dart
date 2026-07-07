import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Reusable stat card for dashboard metrics.
///
/// Shows: icon, value (large number), label, optional trend indicator.
/// Used on dashboard for: total tamu hari ini, sedang berkunjung, sudah pulang.
/// DESIGN.md Section 7.5 (Stat Card variant).
class StatCard extends StatelessWidget {
  /// Icon displayed on the left side of the card.
  final IconData icon;

  /// Primary metric value (e.g., "42").
  final String value;

  /// Descriptive label below the value.
  final String label;

  /// Optional color override for the icon.
  final Color? iconColor;

  /// Optional color override for the value text.
  final Color? valueColor;

  /// Optional trend text (e.g., "+12%") shown to the right of the value.
  final String? trend;

  /// Optional color for the trend indicator.
  final Color? trendColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.valueColor,
    this.trend,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? AppColors.primary700;
    final resolvedValueColor = valueColor ?? AppColors.primary900;
    final resolvedTrendColor = trendColor ?? AppColors.primary700;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // ── Icon ──
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: resolvedIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, size: 24, color: resolvedIconColor),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Value + Label ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: AppTextStyles.h2.copyWith(
                            color: resolvedValueColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trend != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: resolvedTrendColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            trend!,
                            style: AppTextStyles.caption.copyWith(
                              color: resolvedTrendColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(label, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
