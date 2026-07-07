import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
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

    return BlocProvider.value(
      value: BlocProvider.of<GuestBloc>(context),
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
