import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../features/guest/domain/entities/guest_entity.dart';
import '../../core/constants/app_constants.dart';

/// Guest list tile matching DESIGN.md Section 8.3.
///
/// Row with avatar, name/purpose, and time/status badge.
class GuestTile extends StatelessWidget {
  final GuestEntity guest;
  final VoidCallback? onTap;

  const GuestTile({super.key, required this.guest, this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = guest.name.length >= 2
        ? guest.name.substring(0, 2).toUpperCase()
        : guest.name.toUpperCase();
    final isCheckedOut = guest.status == AppConstants.statusCheckedOut;
    final time = guest.checkOutTime ?? guest.checkInTime;
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary50,
                child: Text(
                  initials,
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary700),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guest.name,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      guest.keperluan,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(timeStr, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xs),
                  _StatusBadge(isCheckedOut: isCheckedOut),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCheckedOut;

  const _StatusBadge({required this.isCheckedOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: isCheckedOut ? AppColors.primary50 : AppColors.accentAmberLight,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        isCheckedOut ? AppConstants.statusReturned : AppConstants.statusActive,
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isCheckedOut ? AppColors.primary700 : AppColors.accentAmber,
        ),
      ),
    );
  }
}
