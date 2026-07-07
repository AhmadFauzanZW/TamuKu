import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/services/api_client.dart';
import '../../../guest/domain/entities/guest_entity.dart';

/// Service that exports guest data to Excel via backend API
/// and shares the result using the native share sheet.
///
/// Excel generation is now server-side (ElysiaJS + exceljs).
/// Flutter sends guest data to backend, receives file path, then shares.
class ExcelExportService {
  final ApiClient _apiClient;

  const ExcelExportService({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Human-readable label for each [GuestStatus].
  static String _statusLabel(GuestStatus status) => switch (status) {
    GuestStatus.checkedIn => 'Aktif',
    GuestStatus.checkedOut => 'Pulang',
  };

  /// Exports via backend API and shares the result.
  Future<String> exportAndShare(
    List<GuestEntity> guests, {
    String? locationName,
  }) async {
    final guestMaps = guests.map((g) => <String, dynamic>{
      'name': g.name,
      'phone': Formatters.formatPhone(g.phone),
      'email': g.email ?? '',
      'keperluan': g.keperluan.toValue(),
      'instansi': g.instansi ?? '',
      'checkInTime': Formatters.dateTime.format(g.checkInTime),
      'checkOutTime': g.checkOutTime != null
          ? Formatters.dateTime.format(g.checkOutTime!)
          : '-',
      'status': _statusLabel(g.status),
    }).toList();

    final filepath = await _apiClient.exportExcel(
      guests: guestMaps,
      locationName: locationName,
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            filepath,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
      ),
    );

    return filepath;
  }
}
