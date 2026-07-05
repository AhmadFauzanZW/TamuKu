import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Error state widget with icon, message, and retry button.
///
/// Matches DESIGN.md Section 8.10 error styling.
class TamuErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const TamuErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.accentAmberLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 40,
                color: AppColors.accentAmber,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
