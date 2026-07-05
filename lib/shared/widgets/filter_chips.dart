import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/app_constants.dart';

/// Time-period filter chips matching DESIGN.md Section 7.4 + 8.3.
///
/// Horizontal row of selectable filter chips.
class TamuFilterChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const TamuFilterChips({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const List<String> _filters = [
    AppConstants.filterToday,
    AppConstants.filterThisWeek,
    AppConstants.filterAll,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: EdgeInsets.only(
              right: index < _filters.length - 1 ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 36,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary900 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isSelected ? AppColors.primary900 : AppColors.border,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _filters[index],
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
