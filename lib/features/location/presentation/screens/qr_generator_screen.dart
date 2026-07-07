import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Layar generator QR Code lokasi untuk check-in tamu.
///
/// Reads the real locationId from [SharedPreferences] (set during
/// admin login) and renders a scannable QR code.
class QrGeneratorScreen extends StatelessWidget {
  /// Creates a [QrGeneratorScreen].
  const QrGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationId =
        GetIt.instance<SharedPreferences>().getString(
          AppConstants.keyLocationId,
        ) ??
        '';

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.qrGeneratorTitle)),
      body: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        AppConstants.locationNameLabel,
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        AppConstants.qrInstruction,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      QrImageView(
                        data: '${AppConstants.guestWebUrl}?loc=$locationId',
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.primary900,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.primary900,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      ElevatedButton.icon(
                        onPressed: () async {
                          final qrUrl =
                              '${AppConstants.guestWebUrl}?loc=$locationId';
                          await SharePlus.instance.share(
                            ShareParams(
                              text: 'Scan QR TamuKu untuk check-in:\n$qrUrl',
                              subject: 'TamuKu QR Code',
                            ),
                          );
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text(
                          AppConstants.qrShareButton,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary900,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.xlBorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
