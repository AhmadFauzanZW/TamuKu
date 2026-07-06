import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(
          0xff1B5E20,
        ), // Primary Color #1B5E20 dari laporan
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Jalur navigasi ke settings_screen nanti
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Spacing: card padding 16dp
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Grid Ringkasan Stat Cards (Menggunakan Row & Expanded)
            Row(
              children: [
                _buildStatCard('Total Tamu', '24', Icons.people, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Sedang Check-In',
                  '5',
                  Icons.door_sliding,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Statistik Kunjungan (7 Hari Terakhir)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Placeholder Area Grafik Batang fl_chart
            Card(
              elevation: 1, // Elevation: 1 sesuai laporan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  16,
                ), // Border Radius Cards: 16dp
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 180,
                  alignment: Alignment.center,
                  child: Text(
                    'Area Grafik Batang fl_chart\n(Akan disinkronkan dengan variabel grafik di Figma)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Tamu Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(color: Color(0xff1B5E20)),
                  ),
                ),
              ],
            ),

            // ListView untuk mock data daftar tamu terbaru
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xff1B5E20),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('Nama Tamu'),
                    subtitle: Text('Keperluan: Pertemuan / Kunjungan'),
                    trailing: Text(
                      '10:05 WIB',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ), // Format WIB
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk membuat Stat Card secara modular
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Card(
        elevation: 1, // Elevation: 1 sesuai aturan rancangan
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Radius 16dp
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
