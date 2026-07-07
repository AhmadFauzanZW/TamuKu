import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dashboard admin menampilkan ringkasan tamu, grafik kunjungan,
/// dan daftar aktivitas terbaru.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.dashboardTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary900,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Jalur navigasi ke settings_screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppConstants.dashboardSummaryTitle,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.md),

            // Grid Ringkasan Stat Cards
            Row(
              children: [
                _buildStatCard(
                  AppConstants.statTodayGuests,
                  '24',
                  Icons.people,
                  AppColors.accentBlue,
                ),
                const SizedBox(width: AppSpacing.md),
                _buildStatCard(
                  AppConstants.statActiveGuests,
                  '5',
                  Icons.door_sliding,
                  AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            const Text(
              AppConstants.chartTitle,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.md),

            // Placeholder Area Grafik Batang fl_chart
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgBorder,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  height: 180,
                  alignment: Alignment.center,
                  child: const Text(
                    AppConstants.dashboardChartPlaceholder,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppConstants.dashboardRecentTitle,
                  style: AppTextStyles.h3,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    AppConstants.dashboardViewAll,
                    style: TextStyle(color: AppColors.primary900),
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
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.lgBorder,
                  ),
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary900,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('Nama Tamu'),
                    subtitle: Text('Keperluan: Pertemuan / Kunjungan'),
                    trailing: Text(
                      '10:05 WIB',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
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
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withValues(alpha: 0.1),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppTextStyles.h2,
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
