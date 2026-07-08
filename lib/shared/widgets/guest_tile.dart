import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../features/guest/domain/entities/guest_entity.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/services/photo_service.dart';

/// Guest list tile matching DESIGN.md Section 8.3.
///
/// Row with avatar, name/instansi/keperluan, and time/status badge.
/// Tap navigates to checkout screen.
class GuestTile extends StatelessWidget {
  final GuestEntity guest;
  final VoidCallback? onTap;

  const GuestTile({super.key, required this.guest, this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = guest.name.length >= 2
        ? guest.name.substring(0, 2).toUpperCase()
        : guest.name.toUpperCase();
    final isCheckedOut = guest.status == GuestStatus.checkedOut;
    final time = guest.checkOutTime ?? guest.checkInTime;
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              _GuestAvatar(
                photoUrl: guest.photoUrl ?? guest.checkInPhotoUrl,
                initials: initials,
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
                    if (guest.instansi != null && guest.instansi!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          guest.instansi!,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    _KeperluanBadge(keperluan: guest.keperluan),
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

/// Compact chip showing the visit purpose (keperluan).
class _KeperluanBadge extends StatelessWidget {
  final Keperluan keperluan;
  const _KeperluanBadge({required this.keperluan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        keperluan.toValue(),
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.primary700,
        ),
      ),
    );
  }
}

/// Displays guest photo with fallback to initials avatar.
///
/// Fetches a presigned S3 URL via [PhotoService] before loading.
/// Shows initials [CircleAvatar] when [photoUrl] is null or fails to load.
class _GuestAvatar extends StatelessWidget {
  final String? photoUrl;
  final String initials;

  const _GuestAvatar({required this.photoUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return _InitialsAvatar(initials: initials);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary100, width: 3),
      ),
      child: ClipOval(
        child: FutureBuilder<String>(
          future: PhotoService.getSignedUrl(photoUrl!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _InitialsAvatar(initials: initials);
            }
            final url = snapshot.data ?? photoUrl!;
            return CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              placeholder: (_, __) => _InitialsAvatar(initials: initials),
              errorWidget: (_, __, ___) => _InitialsAvatar(initials: initials),
            );
          },
        ),
      ),
    );
  }
}

/// CircleAvatar showing guest initials as photo fallback.
class _InitialsAvatar extends StatelessWidget {
  final String initials;
  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primary50,
      child: Text(
        initials,
        style: AppTextStyles.h3.copyWith(color: AppColors.primary700),
      ),
    );
  }
}
