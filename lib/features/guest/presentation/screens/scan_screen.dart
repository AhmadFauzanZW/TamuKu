import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/scan_cubit.dart';

/// Scan screen using the device camera to read a QR code.
///
/// On successful scan the QR value is parsed as a location ID and the user
/// is navigated to [AppRoutes.guestForm] with `locationId` and `hostPhone`
/// extracted from the QR payload.
class ScanScreen extends StatelessWidget {
  /// Creates a [ScanScreen].
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => ScanCubit(), child: const _ScanBody());
  }
}

class _ScanBody extends StatelessWidget {
  const _ScanBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanCubit, ScanState>(
      listenWhen: (prev, curr) => !prev.hasScanned && curr.hasScanned,
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppConstants.scanTitle),
            backgroundColor: AppColors.primary900,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                onDetect: state.hasScanned
                    ? null
                    : (capture) => _handleScan(context, capture),
              ),

              CustomPaint(
                painter: _ScannerOverlayPainter(),
                size: Size.infinite,
              ),

              Positioned(
                bottom: AppSpacing.xxxl,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: const Text(
                    AppConstants.cameraInstruction,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleScan(BuildContext context, BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final raw = barcode.rawValue!;
    context.read<ScanCubit>().markScanned();

    // QR format: "locationId|hostPhone" or just "locationId"
    final parts = raw.split('|');
    final locationId = parts.first.trim();
    final hostPhone = parts.length > 1 ? parts[1].trim() : null;

    if (locationId.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.guestForm,
        arguments: <String, dynamic>{
          'locationId': locationId,
          'hostPhone': hostPhone,
        },
      );
    } else {
      _showErrorDialog(context);
    }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppConstants.qrNotFoundTitle),
        content: const Text(AppConstants.qrNotFoundMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ScanCubit>().reset();
            },
            child: const Text(AppConstants.scanAgainButton),
          ),
        ],
      ),
    );
  }
}

/// Painter that draws a semi-transparent overlay with a transparent
/// center rectangle (scanner cutout).
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutoutWidth = size.width * 0.7;
    final cutoutHeight = cutoutWidth;
    final left = (size.width - cutoutWidth) / 2;
    final top = (size.height - cutoutHeight) / 2 - 40;
    final cutout = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, cutoutWidth, cutoutHeight),
      const Radius.circular(16),
    );

    // Dark overlay
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutout)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.4));

    // Corner borders
    final borderPaint = Paint()
      ..color = AppColors.primary700
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerLength = cutoutWidth * 0.2;

    // Top-left
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      borderPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(left + cutoutWidth - cornerLength, top),
      Offset(left + cutoutWidth, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + cutoutWidth, top),
      Offset(left + cutoutWidth, top + cornerLength),
      borderPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, top + cutoutHeight - cornerLength),
      Offset(left, top + cutoutHeight),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top + cutoutHeight),
      Offset(left + cornerLength, top + cutoutHeight),
      borderPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(left + cutoutWidth - cornerLength, top + cutoutHeight),
      Offset(left + cutoutWidth, top + cutoutHeight),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + cutoutWidth, top + cutoutHeight - cornerLength),
      Offset(left + cutoutWidth, top + cutoutHeight),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
