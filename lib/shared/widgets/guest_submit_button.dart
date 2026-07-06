import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../features/guest/presentation/bloc/guest_bloc.dart';
import '../../features/guest/presentation/bloc/guest_state.dart';

/// Submit button for the guest registration form.
///
/// Shows a loading spinner when [GuestBloc] is in [GuestLoading]
/// state; otherwise calls [onPressed].
class GuestSubmitButton extends StatelessWidget {
  const GuestSubmitButton({super.key, required this.onPressed});

  /// Callback triggered when the button is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestBloc, GuestState>(
      builder: (context, state) {
        final submitting = state is GuestLoading;
        return SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: submitting ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary900,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: AppColors.textDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 1,
            ),
            child: submitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text(AppConstants.submitButton,
                    style: AppTextStyles.button),
          ),
        );
      },
    );
  }
}
