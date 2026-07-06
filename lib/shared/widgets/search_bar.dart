import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/app_constants.dart';

/// Pill-shaped search bar matching DESIGN.md Section 7.11.
///
/// Used on Guest List screen for filtering by name.
/// Debounces input by 300ms to avoid excessive filtering.
class TamuSearchBar extends StatefulWidget {
  /// Callback fired after debounce delay with the trimmed query.
  final ValueChanged<String>? onChanged;

  /// Optional external controller.
  final TextEditingController? controller;

  /// Creates a [TamuSearchBar].
  const TamuSearchBar({super.key, this.onChanged, this.controller});

  @override
  State<TamuSearchBar> createState() => _TamuSearchBarState();
}

class _TamuSearchBarState extends State<TamuSearchBar> {
  Timer? _debounce;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged?.call(value.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: widget.controller,
          onChanged: _onChanged,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: AppConstants.searchHint,
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textDisabled,
            ),
            prefixIcon: const Icon(
              Icons.search,
              size: 24,
              color: AppColors.textDisabled,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              borderSide: const BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              borderSide: const BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              borderSide: const BorderSide(
                color: AppColors.primary900,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
