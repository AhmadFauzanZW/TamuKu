import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/guest/presentation/bloc/guest_form_bloc.dart';
import '../../features/guest/presentation/bloc/guest_form_event.dart';
import '../../features/guest/presentation/bloc/guest_form_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Photo picker section for the guest registration form.
///
/// Displays either a placeholder to pick a photo or a preview
/// with a remove button. Dispatches [PhotoSelected] / [PhotoRemoved]
/// to [GuestFormBloc].
class PhotoPickerSection extends StatelessWidget {
  const PhotoPickerSection({super.key, this.onPickImage});

  /// Called when the user taps the placeholder to pick an image.
  final VoidCallback? onPickImage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestFormBloc, GuestFormState>(
      buildWhen: (p, c) => p.photo != c.photo,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto (opsional)',
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            if (state.photo != null)
              _PhotoPreview(
                photo: state.photo!,
                onRemove: () =>
                    context.read<GuestFormBloc>().add(const PhotoRemoved()),
              )
            else
              GestureDetector(
                onTap: onPickImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          size: 36, color: AppColors.textDisabled),
                      SizedBox(height: 8),
                      Text('Ketuk untuk tambah foto',
                          style: TextStyle(color: AppColors.textDisabled)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.photo, required this.onRemove});
  final File photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(photo,
              height: 160, width: double.infinity, fit: BoxFit.cover),
        ),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
