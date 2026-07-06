import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Generic error screen for displaying error messages.
///
/// Receives an error message via route arguments.
/// Shows a red error icon, message, and "Coba Lagi" button to pop.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});
  static const String _defaultTitle = 'Terjadi Kesalahan';
  static const String _defaultMessage = 'Silakan coba lagi.';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final message = (args is String) ? args : _defaultMessage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Error Icon ──
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.errorBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Title ──
                const Text(
                  _defaultTitle,
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Message ──
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Coba Lagi Button ──
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary700,
                      side: const BorderSide(color: AppColors.primary700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
