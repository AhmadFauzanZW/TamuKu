import ExcelJS from 'exceljs';
import { join } from 'path';
import { tmpdir } from 'os';
import { writeFile } from 'fs/promises';

export interface GuestRow {
  name: string;
  phone: string;
  email: string;
  keperluan: string;
  instansi: string;
  checkInTime: string;
  checkOutTime: string;
  status: string;
}

export interface ExportOptions {
  locationName?: string;
}

const HEADERS = [
  'No.',
  'Nama',
  'No. WhatsApp',
  'Email',
  'Keperluan',
  'Instansi',
  'Waktu Masuk',
  'Waktu Keluar',
  'Status',
];

export async function generateExcel(
  guests: GuestRow[],
  options: ExportOptions = {}
): Promise<string> {
  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'TamuKu';
  workbook.created = new Date();

  const sheet = workbook.addWorksheet('Data Tamu', {
    properties: { defaultRowHeight: 22 },
  });

  let rowIndex = 1;

  // ── Title row (optional) ──
  if (options.locationName) {
    sheet.mergeCells(rowIndex, 1, rowIndex, HEADERS.length);
    const titleCell = sheet.getCell(rowIndex, 1);
    titleCell.value = `Data Tamu - ${options.locationName}`;
    titleCell.font = { bold: true, size: 14, color: { argb: 'FF1B5E20' } };
    titleCell.alignment = { vertical: 'middle', horizontal: 'left' };
    rowIndex += 2;
  }

  // ── Header row ──
  const headerRow = sheet.getRow(rowIndex);
  HEADERS.forEach((h, i) => {
    const cell = headerRow.getCell(i + 1);
    cell.value = h;
    cell.font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 11 };
    cell.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF1B5E20' },
    };
    cell.alignment = { vertical: 'middle', horizontal: 'center' };
    cell.border = {
      top: { style: 'thin', color: { argb: 'FF1B5E20' } },
      bottom: { style: 'thin', color: { argb: 'FF1B5E20' } },
      left: { style: 'thin', color: { argb: 'FF1B5E20' } },
      right: { style: 'thin', color: { argb: 'FF1B5E20' } },
    };
  });
  rowIndex++;

  // ── Data rows ──
  guests.forEach((guest, i) => {
    const row = sheet.getRow(rowIndex);
    const isEven = i % 2 === 0;
    const bgColor = isEven ? 'FFF5F5F5' : 'FFFFFFFF';

    const values = [
      i + 1,
      guest.name,
      guest.phone,
      guest.email,
      guest.keperluan,
      guest.instansi,
      guest.checkInTime,
      guest.checkOutTime || '-',
      guest.status,
    ];

    values.forEach((val, col) => {
      const cell = row.getCell(col + 1);
      cell.value = val;
      cell.font = { size: 10 };
      cell.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: bgColor },
      };
      cell.border = {
        top: { style: 'thin', color: { argb: 'FFE0E0E0' } },
        bottom: { style: 'thin', color: { argb: 'FFE0E0E0' } },
        left: { style: 'thin', color: { argb: 'FFE0E0E0' } },
        right: { style: 'thin', color: { argb: 'FFE0E0E0' } },
      };
    });
    rowIndex++;
  });

  // ── Auto-width columns ──
  sheet.columns.forEach((col, i) => {
    let maxLen = HEADERS[i]?.length || 10;
    col.eachCell({ includeEmpty: false }, (cell) => {
      const len = String(cell.value || '').length;
      if (len > maxLen) maxLen = len;
    });
    col.width = maxLen + 4;
  });

  // ── Save to temp file ──
  const filename = `tamuku_tamu_${Date.now()}.xlsx`;
  const filepath = join(tmpdir(), filename);
  const buffer = await workbook.xlsx.writeBuffer();
  await writeFile(filepath, Buffer.from(buffer));

  return filepath;
}
