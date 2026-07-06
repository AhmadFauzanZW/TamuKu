import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Variabel lokal untuk status sakelar Dark Mode (sementara sebelum dihubungkan ke Bloc/Theme provider)
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff1B5E20), // Primary Color #1B5E20 dari Design System laporan
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Spacing: card padding 16dp
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Bagian Profil Singkat Admin
            Card(
              elevation: 1, // Elevation: 1 sesuai aturan rancangan
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xff1B5E20),
                      child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 35),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Utama',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'admin@tamuku.app', // Sesuai contoh data dummy di skema database laporan
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Tampilan & Fitur',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1B5E20)),
            ),
            const SizedBox(height: 8),

            // 2. Menu Pengaturan Tema (Fokus Utama: Dark Mode)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mode Gelap (Dark Mode)'),
                    subtitle: const Text('Mengubah tema aplikasi menjadi gelap'),
                    secondary: const Icon(Icons.dark_mode, color: Color(0xff1B5E20)),
                    activeColor: const Color(0xff1B5E20),
                    value: _isDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        _isDarkMode = value;
                        // Nanti di sini ditambahkan event untuk memicu perubahan tema global (Bloc/ThemeData)
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 50),
                  SwitchListTile(
                    title: const Text('Notifikasi Aplikasi'),
                    subtitle: const Text('Terima pemberitahuan push saat tamu datang'),
                    secondary: const Icon(Icons.notifications, color: Color(0xff1B5E20)),
                    activeColor: const Color(0xff1B5E20),
                    value: _isNotificationEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isNotificationEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Tentang Aplikasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1B5E20)),
            ),
            const SizedBox(height: 8),

            // 3. Informasi Versi Aplikasi
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Color(0xff1B5E20)),
                    title: Text('Versi Aplikasi'),
                    trailing: Text('v2.0', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)), // Versi sesuai laporan proyek
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Tombol Logout Akun Admin
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Nanti dihubungkan ke AuthBloc untuk memicu fungsi signOut()
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Keluar dari Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // Border Radius Buttons: 24dp sesuai laporan
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
