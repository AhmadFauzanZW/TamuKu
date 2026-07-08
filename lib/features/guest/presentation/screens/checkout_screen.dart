import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/guest_entity.dart';
import '../bloc/guest_bloc.dart';
import '../bloc/guest_event.dart';
import '../bloc/guest_state.dart';

/// Check-out screen showing guest info and check-out action.
///
/// Receives [GuestEntity] via route arguments. Uses [BlocConsumer]
/// to handle check-out state transitions and UI rendering.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guest = ModalRoute.of(context)!.settings.arguments as GuestEntity;

    return BlocProvider(
      create: (_) => getIt<GuestBloc>(),
      child: _CheckoutView(guest: guest),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  final GuestEntity guest;
  const _CheckoutView({required this.guest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.checkoutTitle),
        backgroundColor: AppColors.primary900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<GuestBloc, GuestState>(
        listener: (context, state) {
          if (state is GuestOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is GuestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GuestLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Duration Card ──
                if (guest.checkOutTime != null)
                  _DurationCard(
                    checkIn: guest.checkInTime,
                    checkOut: guest.checkOutTime!,
                  ),
                if (guest.checkOutTime != null)
                  const SizedBox(height: AppSpacing.lg),

                // ── Photos Section ──
                _PhotosSection(guest: guest),
                const SizedBox(height: AppSpacing.lg),

                // ── Guest Info Card ──
                Card(
                  elevation: 0,
                  color: AppColors.surfaceOf(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    side: BorderSide(color: AppColors.borderOf(context)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppConstants.guestDataTitle,
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _InfoRow(
                          label: AppConstants.labelName,
                          value: guest.name,
                        ),
                        _InfoRow(
                          label: AppConstants.labelKeperluan,
                          value: guest.keperluan.toValue(),
                        ),
                        if (guest.instansi != null &&
                            guest.instansi!.isNotEmpty)
                          _InfoRow(
                            label: AppConstants.labelInstansi,
                            value: guest.instansi!,
                          ),
                        _InfoRow(
                          label: AppConstants.labelCheckInTime,
                          value: _formatDateTime(guest.checkInTime),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Check-out Button ──
                if (guest.status == GuestStatus.checkedIn)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<GuestBloc>().add(
                          CheckOutRequested(guest.guestId),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        AppConstants.checkoutButton,
                        style: AppTextStyles.button,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    color: AppColors.primary50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primary700,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            AppConstants.alreadyCheckedOut,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Formats [DateTime] to Indonesian format (dd/MM/yyyy HH:mm).
  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Displays check-in and check-out photos for the guest.
///
/// Shows check-in photo at the top. If checkout has occurred,
/// shows check-out photo below it. Uses [CachedNetworkImage]
/// with a rounded border and fallback placeholder.
class _PhotosSection extends StatelessWidget {
  final GuestEntity guest;
  const _PhotosSection({required this.guest});

  @override
  Widget build(BuildContext context) {
    final checkInUrl = guest.checkInPhotoUrl ?? guest.photoUrl;
    final checkOutUrl = guest.checkOutPhotoUrl;
    final hasCheckIn = checkInUrl != null && checkInUrl.isNotEmpty;
    final hasCheckOut = checkOutUrl != null && checkOutUrl.isNotEmpty;

    if (!hasCheckIn && !hasCheckOut) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasCheckIn) ...[
          const Text('Foto Check-in', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          _PhotoCard(imageUrl: checkInUrl, label: 'Check-in'),
        ],
        if (hasCheckIn && hasCheckOut) const SizedBox(height: AppSpacing.lg),
        if (hasCheckOut) ...[
          const Text('Foto Check-out', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          _PhotoCard(imageUrl: checkOutUrl, label: 'Check-out'),
        ],
      ],
    );
  }
}

/// Single photo card with rounded border and label.
///
/// Displays a [CachedNetworkImage] inside a rounded container
/// with a green border and a small label chip at the bottom-left.
class _PhotoCard extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _PhotoCard({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary100, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.primary50,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.primary50,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.primary500,
                    size: 48,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary900.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays duration between check-in and check-out.
class _DurationCard extends StatelessWidget {
  final DateTime checkIn;
  final DateTime checkOut;

  const _DurationCard({required this.checkIn, required this.checkOut});

  @override
  Widget build(BuildContext context) {
    final diff = checkOut.difference(checkIn);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final durationStr = hours > 0
        ? '$hours jam $minutes menit'
        : '$minutes menit';

    return Card(
      elevation: 0,
      color: AppColors.successBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.primary100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: AppColors.primary700),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.visitDuration,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  durationStr,
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Row widget for label-value pairs.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
