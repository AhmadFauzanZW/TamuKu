import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Layar generator QR Code lokasi untuk check-in tamu.
///
/// Uses [FutureBuilder] to load the location data before rendering
/// the QR code. Falls back to a demo location ID if no data is available.
class QrGeneratorScreen extends StatelessWidget {
  /// Creates a [QrGeneratorScreen].
  const QrGeneratorScreen({super.key});

  static const _demoLocationId = 'abc123_kantor_cakrawala';

  /// Simulates loading location data from the repository.
  /// In production this would call [LocationRepository.getLocation].
  Future<String> _loadLocationId() async {
    // TODO: Replace with actual LocationBloc state or repository call.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _demoLocationId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.qrGeneratorTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<String>(
        future: _loadLocationId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final locationId = snapshot.data ?? _demoLocationId;

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
                        data: locationId,
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
                        onPressed: () {
                          // TODO: hubungkan ke share_plus
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
