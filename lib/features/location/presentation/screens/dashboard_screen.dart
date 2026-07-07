import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../widgets/visit_chart.dart';

/// Dashboard admin menampilkan ringkasan tamu, grafik kunjungan,
/// dan daftar aktivitas terbaru.
///
/// Uses [StreamBuilder] for real-time Firestore data and
/// [VisitChart] (fl_chart) for the 7-day bar chart.
class DashboardScreen extends StatelessWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Stream today's guests for real-time stats
    final todayGuestsStream = FirebaseFirestore.instance
        .collection(AppConstants.guestsCollection)
        .where(
          AppConstants.fieldCheckInTime,
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
        )
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: AppConstants.qrGeneratorTitle,
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.qrGenerator);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: todayGuestsStream,
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final totalCount = docs.length;
          final activeCount = docs.where((doc) {
            final data = doc.data();
            return data[AppConstants.fieldStatus] ==
                AppConstants.statusCheckedIn;
          }).length;

          // Build 7-day visit counts from the stream data
          final dailyCounts = _computeDailyCounts(docs, now);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.dashboardSummaryTitle,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppSpacing.md),

                // Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.people,
                        value:
                            snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : totalCount.toString(),
                        label: AppConstants.statTodayGuests,
                        iconColor: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        icon: Icons.door_sliding,
                        value:
                            snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : activeCount.toString(),
                        label: AppConstants.statActiveGuests,
                        iconColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                // QR Code Access Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.lgBorder,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.qrGenerator);
                    },
                    borderRadius: AppRadius.lgBorder,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary900.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.qr_code_2,
                              color: AppColors.primary900,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppConstants.qrGeneratorTitle,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppConstants.qrGeneratorDescription,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondaryOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
                const Text(AppConstants.chartTitle, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                // fl_chart Bar Chart
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.lgBorder,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: VisitChart(
                      visits: dailyCounts,
                      dayLabels: _dayLabels(),
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
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.guestList);
                      },
                      child: Text(
                        AppConstants.dashboardViewAll,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (docs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'Belum ada aktivitas hari ini',
                        style: AppTextStyles.body,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length > 5 ? 5 : docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final name =
                          data[AppConstants.fieldName] as String? ?? '-';
                      final keperluan =
                          data[AppConstants.fieldKeperluan] as String? ?? '-';
                      final checkInTime =
                          (data[AppConstants.fieldCheckInTime] as Timestamp?)
                              ?.toDate();
                      final timeStr = checkInTime != null
                          ? DateFormat('HH:mm', 'id_ID').format(checkInTime)
                          : '-';

                      final cs = Theme.of(context).colorScheme;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.lgBorder,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: cs.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.person, color: cs.primary),
                          ),
                          title: Text(name),
                          subtitle: Text('Keperluan: $keperluan'),
                          trailing: Text(
                            '$timeStr WIB',
                            style: TextStyle(
                              color: AppColors.textSecondaryOf(context),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Computes visit counts for each of the last 7 days from Firestore docs.
  List<double> _computeDailyCounts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime now,
  ) {
    final counts = List<double>.filled(7, 0);
    for (final doc in docs) {
      final data = doc.data();
      final checkInTime = (data[AppConstants.fieldCheckInTime] as Timestamp?)
          ?.toDate();
      if (checkInTime == null) continue;
      final diff = DateTime(now.year, now.month, now.day)
          .difference(
            DateTime(checkInTime.year, checkInTime.month, checkInTime.day),
          )
          .inDays;
      if (diff >= 0 && diff < 7) {
        counts[6 - diff]++;
      }
    }
    return counts;
  }

  /// Returns short Bahasa Indonesia day labels for the last 7 days.
  List<String> _dayLabels() {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return days[date.weekday % 7];
    });
  }
}
