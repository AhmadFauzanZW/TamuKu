import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
/// admin login) and renders a scannable QR code. Supports sharing
/// via link and printing to PDF.
class QrGeneratorScreen extends StatefulWidget {
  /// Creates a [QrGeneratorScreen].
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String _locationName = 'Lokasi';
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _loadLocationName();
  }

  Future<void> _loadLocationName() async {
    final locationId =
        GetIt.instance<SharedPreferences>().getString(
          AppConstants.keyLocationId,
        ) ??
        '';
    if (locationId.isEmpty) {
      if (mounted) setState(() => _isLoadingName = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection(AppConstants.locationsCollection)
          .doc(locationId)
          .get();
      if (mounted) {
        setState(() {
          _locationName = doc.data()?['name'] as String? ?? 'Lokasi';
          _isLoadingName = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingName = false);
    }
  }

  Future<void> _printQrCode(String locationId) async {
    final pdf = pw.Document();
    final qrUrl = '${AppConstants.guestWebUrl}?loc=$locationId';

    final qrValidationResult = QrValidator.validate(
      data: qrUrl,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );

    if (qrValidationResult.status != QrValidationStatus.valid) return;

    final qrPainter = QrPainter.withQr(
      qr: qrValidationResult.qrCode!,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF1B5E20),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF1B5E20),
      ),
    );

    final qrImageBytes = await qrPainter.toImageData(300);
    if (qrImageBytes == null) return;

    final green = PdfColor.fromHex('#1B5E20');
    final lightGreen = PdfColor.fromHex('#E8F5E9');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 30,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Green accent bar
                pw.Container(
                  height: 6,
                  decoration: pw.BoxDecoration(
                    color: green,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                ),
                pw.SizedBox(height: 40),

                // Title
                pw.Text(
                  'TamuKu',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: green,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Buku Tamu Digital',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),

                // Location name
                pw.Text(
                  _locationName,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 30),

                // QR code — centered with light green border
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: lightGreen,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: green, width: 1),
                    ),
                    child: pw.Image(
                      pw.MemoryImage(
                        Uint8List.fromList(qrImageBytes.buffer.asUint8List()),
                      ),
                      width: 180,
                      height: 180,
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),

                // Instructions
                pw.Text(
                  'Scan QR Code ini untuk check-in',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Buka kamera ponsel, arahkan ke QR Code',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Tidak perlu login, langsung isi formulir tamu',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey500),
                  textAlign: pw.TextAlign.center,
                ),

                // Spacer pushes footer to bottom
                pw.Spacer(),

                // Divider
                pw.Container(height: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 10),

                // Footer URL
                pw.Text(
                  qrUrl,
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey400),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'TamuKu - Buku Tamu Digital',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    if (!mounted) return;
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'TamuKu_QR_${_locationName.replaceAll(' ', '_')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationId =
        GetIt.instance<SharedPreferences>().getString(
          AppConstants.keyLocationId,
        ) ??
        '';

    final qrUrl = '${AppConstants.guestWebUrl}?loc=$locationId';

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.qrGeneratorTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: locationId.isEmpty
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Tidak ada lokasi yang dipilih',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Silakan hubungi admin untuk membuat lokasi.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.lgBorder,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLoadingName
                              ? AppConstants.locationNameLabel
                              : _locationName,
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
                          data: qrUrl,
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
                            final url =
                                '${AppConstants.guestWebUrl}?loc=$locationId';
                            await SharePlus.instance.share(
                              ShareParams(
                                text: 'Scan QR TamuKu untuk check-in:\n$url',
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
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _printQrCode(locationId),
                            icon: const Icon(Icons.print),
                            label: const Text('Cetak QR'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary900,
                              side: const BorderSide(
                                color: AppColors.primary900,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.xlBorder,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
