import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGeneratorScreen extends StatelessWidget {
  const QrGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ID lokasi tiruan (dummy) untuk kebutuhan testing UI awal sebelum disambungkan ke BLoC
    const String dummyLocationId = "abc123_kantor_cakrawala";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code Lokasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(
          0xff1B5E20,
        ), // Primary Color #1B5E20 dari Design System laporan
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ), // Spacing: card padding 16dp dari laporan
        child: Center(
          child: Card(
            elevation: 1, // Elevation: 1 at rest sesuai spesifikasi laporan
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                16,
              ), // Border Radius Cards: 16dp dari laporan
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kantor Utama',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silakan tunjukkan QR Code di bawah ini kepada tamu untuk dipindai saat melakukan check-in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Komponen Render QR Code Utama dari library qr_flutter
                  QrImageView(
                    data: dummyLocationId,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                    foregroundColor: const Color(
                      0xff1B5E20,
                    ), // Menggunakan warna utama agar serasi
                  ),

                  const SizedBox(height: 24),

                  // Tombol Bagikan QR Code sesuai dengan daftar test case pengujian laporan
                  ElevatedButton.icon(
                    onPressed: () {
                      // Nanti dihubungkan ke package share_plus oleh timmu untuk membagikan tautan/gambar QR
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text(
                      'Bagikan QR Code',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1B5E20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          24,
                        ), // Border Radius Buttons: 24dp dari laporan
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
