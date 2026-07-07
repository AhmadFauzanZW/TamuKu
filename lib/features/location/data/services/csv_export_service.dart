import 'dart:convert';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/formatters.dart';
import '../../../guest/domain/entities/guest_entity.dart';

/// Service that converts guest records into CSV and shares the result.
///
/// Concept G (Popular Libraries): uses `dart:io` for a temp file
/// path and `share_plus` for the native share sheet, while `intl`
/// (via [Formatters]) formats the check-in/out timestamps.
///
/// The pure [buildCsv] string builder is kept separate from the
/// [exportAndShare] side effect so it can be unit-tested without I/O.
class CsvExportService {
  /// Creates a [CsvExportService].
  const CsvExportService();

  /// CSV header row in Bahasa Indonesia, matching [GuestEntity] fields.
  static const List<String> _headers = <String>[
    'Nama',
    'No. WhatsApp',
    'Email',
    'Keperluan',
    'Instansi',
    'Waktu Masuk',
    'Waktu Keluar',
    'Status',
  ];

  /// Human-readable label for each [GuestStatus] value.
  static String _statusLabel(GuestStatus status) => switch (status) {
    GuestStatus.checkedIn => 'Aktif',
    GuestStatus.checkedOut => 'Pulang',
  };

  /// Builds a CSV [String] from [guests].
  ///
  /// When [locationName] is provided, a single title line is prepended
  /// before the header row for readability. All values are escaped per
  /// RFC 4180: fields containing a comma, double quote, or newline are
  /// wrapped in double quotes and inner quotes are doubled.
  String buildCsv(List<GuestEntity> guests, {String? locationName}) {
    final buffer = StringBuffer();

    if (locationName != null && locationName.isNotEmpty) {
      buffer.writeln(_escape('Data Tamu - $locationName'));
    }

    buffer.writeln(_headers.map(_escape).join(','));

    for (final guest in guests) {
      final row = <String>[
        guest.name,
        Formatters.formatPhone(guest.phone),
        guest.email ?? '',
        guest.keperluan.toValue(),
        guest.instansi ?? '',
        Formatters.dateTime.format(guest.checkInTime),
        guest.checkOutTime != null
            ? Formatters.dateTime.format(guest.checkOutTime!)
            : '',
        _statusLabel(guest.status),
      ];
      buffer.writeln(row.map(_escape).join(','));
    }

    return buffer.toString();
  }

  /// Escapes a single CSV [field] following RFC 4180 rules.
  String _escape(String field) {
    final needsQuoting =
        field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r');
    if (!needsQuoting) return field;
    final escaped = field.replaceAll('"', '""');
    return '"$escaped"';
  }

  /// Writes the CSV built from [guests] to a temporary file and opens
  /// the native share sheet via `share_plus`.
  ///
  /// Returns the generated CSV content so callers can react to it.
  /// Throws if the file cannot be written; callers should handle errors.
  Future<String> exportAndShare(
    List<GuestEntity> guests, {
    String? locationName,
  }) async {
    final csv = buildCsv(guests, locationName: locationName);
    final dir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/tamuku_tamu_$timestamp.csv');
    await file.writeAsString(csv, encoding: utf8);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'text/csv')]),
    );

    return csv;
  }
}
