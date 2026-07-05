import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Green circular progress indicator.
///
/// Used as loading state across all screens. DESIGN.md Section 10.3.
class TamuLoadingIndicator extends StatelessWidget {
  final double size;

  const TamuLoadingIndicator({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          color: AppColors.primary900,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
