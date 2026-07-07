import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection_container.dart';
import '../../../guest/domain/entities/guest_entity.dart';
import '../../data/services/excel_export_service.dart';

/// Beautiful preview modal for Excel export.
///
/// Shows a formatted table of guests with Save and Share buttons
/// at the bottom, and a Close button at the top-right.
class ExportPreviewModal extends StatelessWidget {
  final List<GuestEntity> guests;

  const ExportPreviewModal({super.key, required this.guests});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with title + close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppConstants.previewTitle,
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppConstants.previewTotalRows.replaceAll(
                              '%d',
                              '${guests.length}',
                            ),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondaryOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Table
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.primary900.withValues(alpha: 0.1),
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'No.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Keperluan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Waktu',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: List.generate(guests.length, (i) {
                        final guest = guests[i];
                        final isCheckedIn =
                            guest.status == GuestStatus.checkedIn;
                        final timeStr = _formatTime(guest);
                        return DataRow(
                          cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(
                              Text(
                                guest.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(Text(guest.keperluan.toValue())),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isCheckedIn
                                      ? AppColors.warningBg
                                      : AppColors.successBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isCheckedIn ? 'Aktif' : 'Pulang',
                                  style: TextStyle(
                                    color: isCheckedIn
                                        ? AppColors.warning
                                        : AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                timeStr,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await getIt<ExcelExportService>().exportAndShare(
                              guests,
                            );
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(AppConstants.exportFailed),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(AppConstants.previewSave),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary900,
                          side: const BorderSide(color: AppColors.primary900),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdBorder,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await getIt<ExcelExportService>().exportAndShare(
                              guests,
                            );
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(AppConstants.exportFailed),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: const Text(AppConstants.previewShare),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdBorder,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(GuestEntity guest) {
    final checkIn = guest.checkInTime;
    final hour = checkIn.hour.toString().padLeft(2, '0');
    final minute = checkIn.minute.toString().padLeft(2, '0');
    if (guest.checkOutTime != null) {
      final checkOut = guest.checkOutTime!;
      final outHour = checkOut.hour.toString().padLeft(2, '0');
      final outMinute = checkOut.minute.toString().padLeft(2, '0');
      return '$hour:$minute - $outHour:$outMinute';
    }
    return '$hour:$minute';
  }
}
