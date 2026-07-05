import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Custom header banner matching DESIGN.md Section 7.10.
///
/// Green background banner with title and optional subtitle.
/// Used on Dashboard, Guest List, QR Generator, Settings, and Guest Form screens.
class TamuHeaderBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? child;

  const TamuHeaderBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: MediaQuery.of(context).padding.top + AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(color: AppColors.primary900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h1.copyWith(color: Colors.white)),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: AppSpacing.sm), child!],
        ],
      ),
    );
  }
}
