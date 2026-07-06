import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tamuku/features/guest/domain/entities/guest_entity.dart';
import 'package:tamuku/features/location/data/services/csv_export_service.dart';

// ─── Fixtures ─────────────────────────────────────────────────────

final tCheckIn = DateTime(2026, 7, 6, 9, 30);
final tCheckOut = DateTime(2026, 7, 6, 11, 15);

final tGuest = GuestEntity(
  guestId: 'g1',
  name: 'Budi Santoso',
  phone: '081298765432',
  email: 'budi@example.com',
  keperluan: Keperluan.meeting,
  instansi: 'PT Maju Jaya',
  locationId: 'loc1',
  checkInTime: tCheckIn,
  checkOutTime: tCheckOut,
  status: GuestStatus.checkedOut,
);

// Guest with a comma and quote in the name to exercise CSV escaping.
final tGuestSpecial = GuestEntity(
  guestId: 'g2',
  name: 'Santoso, "Budi"',
  phone: '081234567890',
  keperluan: Keperluan.personal,
  locationId: 'loc1',
  checkInTime: tCheckIn,
);

// ─── Tests ────────────────────────────────────────────────────────

void main() {
  const service = CsvExportService();

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('buildCsv', () {
    test('first line is the Indonesian header row', () {
      final csv = service.buildCsv([tGuest]);
      final firstLine = csv.split('\n').first;

      expect(
        firstLine,
        'Nama,No. WhatsApp,Email,Keperluan,Instansi,'
        'Waktu Masuk,Waktu Keluar,Status',
      );
    });

    test('prepends a title line when locationName is given', () {
      final csv = service.buildCsv([tGuest], locationName: 'Kantor Desa');
      final lines = csv.split('\n');

      expect(lines.first, 'Data Tamu - Kantor Desa');
      expect(lines[1], startsWith('Nama,'));
    });

    test('maps guest fields into the correct row values', () {
      final csv = service.buildCsv([tGuest]);
      final row = csv.split('\n')[1];
      final cells = row.split(',');

      expect(cells[0], 'Budi Santoso');
      expect(cells[1], '+6281298765432'); // phone normalized by Formatters
      expect(cells[2], 'budi@example.com');
      expect(cells[3], 'Meeting');
      expect(cells[4], 'PT Maju Jaya');
      expect(cells.last, 'Pulang'); // checkedOut label
    });

    test('leaves optional email/instansi/checkout empty when null', () {
      final csv = service.buildCsv([tGuestSpecial]);
      final row = csv.split('\n')[1];

      // Row is quoted at the start due to the name; assert the empty
      // optional fields and the "Aktif" status are present.
      expect(row.contains(',,'), isTrue); // email + instansi empty
      expect(row.trimRight().endsWith('Aktif'), isTrue);
    });

    test('escapes commas and quotes per RFC 4180', () {
      final csv = service.buildCsv([tGuestSpecial]);
      final row = csv.split('\n')[1];

      // `Santoso, "Budi"` → wrapped in quotes, inner quotes doubled.
      expect(row, startsWith('"Santoso, ""Budi"""'));
    });

    test('produces one line per guest plus the header', () {
      final csv = service.buildCsv([tGuest, tGuestSpecial]);
      final lines = csv.trimRight().split('\n');

      expect(lines.length, 3); // header + 2 rows
    });
  });
}
