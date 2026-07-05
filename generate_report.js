const fs = require('fs');
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, ImageRun,
        Header, Footer, AlignmentType, LevelFormat, HeadingLevel, BorderStyle,
        WidthType, ShadingType, PageNumber, PageBreak } = require('docx');

// ── Design Tokens ──
const C = {
  primary:  "1B5E20",  // green-900
  accent:   "2E7D32",  // green-800
  light:    "E8F5E9",  // green-50
  darkGray: "374151",
  border:   "B0BEC5",
  headerBg: "1B5E20",
  altRow:   "F1F8E9",
  white:    "FFFFFF",
};

// ── Helpers ──
const bdr  = (color = C.border) => ({ style: BorderStyle.SINGLE, size: 4, color });
const borders = (c = C.border) => ({ top: bdr(c), bottom: bdr(c), left: bdr(c), right: bdr(c) });
const noBorder = { style: BorderStyle.NONE, size: 0, color: "FFFFFF" };
const noBorders = { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder };

function heading1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 240, after: 120 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: C.primary, space: 4 } },
    children: [new TextRun({ text, font: "Arial", size: 32, bold: true, color: C.primary })],
  });
}

function heading2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 180, after: 80 },
    children: [new TextRun({ text, font: "Arial", size: 28, bold: true, color: C.accent })],
  });
}

function body(text, opts = {}) {
  return new Paragraph({
    spacing: { before: 40, after: 40 },
    children: [new TextRun({ text, font: "Arial", size: 20, color: C.darkGray, ...opts })],
  });
}

function bodyMulti(runs) {
  return new Paragraph({
    spacing: { before: 40, after: 40 },
    children: runs.map(r => new TextRun({ font: "Arial", size: 20, color: C.darkGray, ...r })),
  });
}

function boldBody(label, rest) {
  return new Paragraph({
    spacing: { before: 40, after: 40 },
    children: [
      new TextRun({ text: label, font: "Arial", size: 20, color: C.darkGray, bold: true }),
      new TextRun({ text: rest, font: "Arial", size: 20, color: C.darkGray }),
    ],
  });
}

function bullet(text, ref = "bullets", level = 0) {
  return new Paragraph({
    numbering: { reference: ref, level },
    spacing: { before: 20, after: 20 },
    children: [new TextRun({ text, font: "Arial", size: 20, color: C.darkGray })],
  });
}

function numbered(text, ref = "numbers", level = 0) {
  return new Paragraph({
    numbering: { reference: ref, level },
    spacing: { before: 20, after: 20 },
    children: [new TextRun({ text, font: "Arial", size: 20, color: C.darkGray })],
  });
}

function spacer(n = 1) {
  return Array.from({ length: n }, () =>
    new Paragraph({ spacing: { before: 0, after: 0 }, children: [new TextRun({ text: "", size: 10 })] })
  );
}

function headerCell(text, width) {
  return new TableCell({
    borders: borders(C.primary),
    width: { size: width, type: WidthType.DXA },
    shading: { fill: C.headerBg, type: ShadingType.CLEAR },
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    verticalAlign: "center",
    children: [new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text, font: "Arial", size: 18, bold: true, color: C.white })],
    })],
  });
}

function dataCell(text, width, opts = {}) {
  const { fill = "FFFFFF", bold: isBold = false, align = AlignmentType.LEFT } = opts;
  return new TableCell({
    borders: borders(C.border),
    width: { size: width, type: WidthType.DXA },
    shading: { fill, type: ShadingType.CLEAR },
    margins: { top: 50, bottom: 50, left: 100, right: 100 },
    verticalAlign: "center",
    children: [new Paragraph({
      alignment: align,
      children: [new TextRun({ text, font: "Arial", size: 18, color: C.darkGray, bold: isBold })],
    })],
  });
}

function caption(text) {
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 20, after: 80 },
    children: [new TextRun({ text, font: "Arial", size: 14, italics: true, color: "666666" })],
  });
}

// ── Read all images ──
const imgDir = 'c:\\Projects\\Mobile\\Project UAS - TamuKu\\UI Design';
const adminImages = [
  { file: 'Admin 1 - Login.png', label: 'Admin 1 — Login' },
  { file: 'Admin 2 - Dashboard.png', label: 'Admin 2 — Dashboard' },
  { file: 'Admin 3 - Daftar Tamu.png', label: 'Admin 3 — Daftar Tamu' },
  { file: 'Admin 4 - QR Generator.png', label: 'Admin 4 — QR Generator' },
  { file: 'Admin 5 - Settings.png', label: 'Admin 5 — Settings' },
];
const guestImages = [
  { file: 'Guest 1 - Scan QR.png', label: 'Guest 1 — Scan QR' },
  { file: 'Guest 2 - Form Isian.png', label: 'Guest 2 — Form Isian' },
  { file: 'Guest 3 - Konfirmasi.png', label: 'Guest 3 — Konfirmasi' },
  { file: 'Guest 4 - Check-Out.png', label: 'Guest 4 — Check-Out' },
  { file: 'Guest 5  - Error OR Expired.png', label: 'Guest 5 — Error/Expired' },
];

const allImages = [...adminImages, ...guestImages];
const imgBuffers = allImages.map(img => ({
  buffer: fs.readFileSync(`${imgDir}\\${img.file}`),
  label: img.label,
}));

// ── Image pair table builder ──
function imagePairTable(pair) {
  const colW = 4513; // ~half content width
  const rows = [];

  // Image row
  const imgCells = pair.map((img, i) => new TableCell({
    borders: noBorders,
    width: { size: colW, type: WidthType.DXA },
    margins: { top: 40, bottom: 20, left: 60, right: 60 },
    children: [new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new ImageRun({
        type: "png",
        data: img.buffer,
        transformation: { width: 180, height: 340 },
        altText: { title: img.label, description: img.label, name: img.label },
      })],
    })],
  }));
  // If odd, add empty cell
  if (pair.length === 1) {
    imgCells.push(new TableCell({ borders: noBorders, width: { size: colW, type: WidthType.DXA }, children: [] }));
  }
  rows.push(new TableRow({ children: imgCells }));

  // Caption row
  const capCells = pair.map((img) => new TableCell({
    borders: noBorders,
    width: { size: colW, type: WidthType.DXA },
    margins: { top: 0, bottom: 60, left: 60, right: 60 },
    children: [new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: img.label, font: "Arial", size: 14, italics: true, color: "666666" })],
    })],
  }));
  if (pair.length === 1) {
    capCells.push(new TableCell({ borders: noBorders, width: { size: colW, type: WidthType.DXA }, children: [] }));
  }
  rows.push(new TableRow({ children: capCells }));

  return new Table({
    width: { size: 9026, type: WidthType.DXA },
    columnWidths: [colW, colW],
    rows,
  });
}

// ── Build Document ──
const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 20 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, font: "Arial", color: C.primary },
        paragraph: { spacing: { before: 240, after: 120 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 28, bold: true, font: "Arial", color: C.accent },
        paragraph: { spacing: { before: 180, after: 80 }, outlineLevel: 1 } },
    ],
  },
  numbering: {
    config: [
      { reference: "bullets", levels: [
        { level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } },
      ]},
      { reference: "numbers", levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } },
      ]},
      { reference: "numbers2", levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } },
      ]},
    ],
  },
  sections: [{
    properties: {
      page: {
        size: { width: 11906, height: 16838 }, // A4
        margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 },
      },
    },
    headers: {
      default: new Header({
        children: [new Paragraph({
          alignment: AlignmentType.CENTER,
          border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: C.primary, space: 4 } },
          children: [new TextRun({ text: "Laporan Proyek Akhir \u2014 Mobile Computing", font: "Arial", size: 16, color: C.primary, italics: true })],
        })],
      }),
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          alignment: AlignmentType.CENTER,
          border: { top: { style: BorderStyle.SINGLE, size: 4, color: C.border, space: 4 } },
          children: [
            new TextRun({ text: "Halaman ", font: "Arial", size: 16, color: "999999" }),
            new TextRun({ children: [PageNumber.CURRENT], font: "Arial", size: 16, color: "999999" }),
          ],
        })],
      }),
    },
    children: [
      // ═══════════════════════════════════════════
      // COVER / TITLE
      // ═══════════════════════════════════════════
      new Paragraph({ spacing: { before: 600, after: 0 }, alignment: AlignmentType.CENTER,
        children: [new TextRun({ text: "TAMUKU", font: "Arial", size: 52, bold: true, color: C.primary })] }),
      new Paragraph({ spacing: { before: 0, after: 60 }, alignment: AlignmentType.CENTER,
        children: [new TextRun({ text: "Buku Tamu Digital", font: "Arial", size: 28, color: C.accent })] }),
      new Paragraph({ spacing: { before: 0, after: 300 }, alignment: AlignmentType.CENTER,
        children: [new TextRun({ text: "Laporan Proyek Akhir \u2014 Mobile Computing", font: "Arial", size: 22, color: C.darkGray })] }),

      // Meta table
      new Table({
        width: { size: 6000, type: WidthType.DXA },
        columnWidths: [2200, 3800],
        rows: [
          ["Universitas", "Universitas Cakrawala"],
          ["Mata Kuliah", "Mobile Computing"],
          ["Dosen Pembimbing", "Hedy Pamungkas, S.T., M.T.I"],
          ["Tanggal", "5 Juli 2026"],
        ].map(([label, value]) => new TableRow({
          children: [
            new TableCell({ borders: noBorders, width: { size: 2200, type: WidthType.DXA },
              margins: { top: 30, bottom: 30, left: 0, right: 100 },
              children: [new Paragraph({ children: [new TextRun({ text: label, font: "Arial", size: 18, bold: true, color: C.primary })] })] }),
            new TableCell({ borders: noBorders, width: { size: 3800, type: WidthType.DXA },
              margins: { top: 30, bottom: 30, left: 100, right: 0 },
              children: [new Paragraph({ children: [new TextRun({ text: value, font: "Arial", size: 18, color: C.darkGray })] })] }),
          ],
        })),
        alignment: AlignmentType.CENTER,
      }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 200, after: 100 },
        children: [new TextRun({ text: "Tim:", font: "Arial", size: 18, bold: true, color: C.darkGray })] }),
      ...[
        "Hafiz Nur Rizki (24110300038)",
        "Ahmad Fauzan (24110500007) \u2014 Tech Lead",
        "Annur Syahrin Aisyah (24110500014)",
      ].map(name => new Paragraph({
        alignment: AlignmentType.CENTER, spacing: { before: 10, after: 10 },
        children: [new TextRun({ text: name, font: "Arial", size: 18, color: C.darkGray })],
      })),

      new Paragraph({ children: [new PageBreak()] }),

      // ═══════════════════════════════════════════
      // SECTION 1: HALAMAN APLIKASI & ALUR PENGGUNAAN
      // ═══════════════════════════════════════════
      heading1("1. Halaman Aplikasi & Alur Penggunaan"),
      body("TamuKu memiliki 10 halaman yang dibagi menjadi 2 alur pengguna:"),

      heading2("1.1 Alur Admin (5 halaman)"),
      body("Memerlukan autentikasi (Email + Password atau Google OAuth)."),
      numbered("Login \u2014 Autentikasi admin via email atau Google", "numbers"),
      numbered("Dashboard \u2014 Statistik tamu hari ini + chart kunjungan 7 hari", "numbers"),
      numbered("Daftar Tamu \u2014 List tamu dengan search bar & filter", "numbers"),
      numbered("QR Generator \u2014 Generate QR code lokasi, pilih ukuran cetak (A4/A5/Layar)", "numbers"),
      numbered("Settings \u2014 Profil lokasi, toggle WhatsApp notif & dark mode, logout", "numbers"),

      heading2("1.2 Alur Guest (5 halaman)"),
      body("Tanpa autentikasi. Diakses via scan QR code."),
      numbered("Scan QR \u2014 Kamera viewfinder dengan overlay corner brackets", "numbers2"),
      numbered("Form Isian \u2014 Registrasi: nama, WhatsApp, keperluan, instansi, foto opsional", "numbers2"),
      numbered("Konfirmasi \u2014 Check-in sukses + waktu + tombol check-out", "numbers2"),
      numbered("Check-Out \u2014 Konfirmasi kepulangan + durasi kunjungan", "numbers2"),
      numbered("Error/Expired \u2014 QR tidak valid atau kedaluwarsa", "numbers2"),

      heading2("1.3 Navigasi"),
      boldBody("Admin: ", "Star pattern (Dashboard \u2192 List/QR/Settings, semua kembali ke Dashboard)."),
      boldBody("Guest: ", "Linear (Scan \u2192 Form \u2192 Konfirmasi \u2192 Check-Out)."),

      // ── Screenshots ──
      heading2("1.4 Tampilan Aplikasi"),
      body("Berikut adalah screenshot seluruh halaman aplikasi TamuKu:"),

      ...spacer(1),
      // Admin images: 2 per row (pairs: [0,1], [2,3], [4] solo)
      imagePairTable([imgBuffers[0], imgBuffers[1]]),
      ...spacer(1),
      imagePairTable([imgBuffers[2], imgBuffers[3]]),
      ...spacer(1),
      imagePairTable([imgBuffers[4]]),

      ...spacer(1),
      // Guest images
      imagePairTable([imgBuffers[5], imgBuffers[6]]),
      ...spacer(1),
      imagePairTable([imgBuffers[7], imgBuffers[8]]),
      ...spacer(1),
      imagePairTable([imgBuffers[9]]),

      new Paragraph({ children: [new PageBreak()] }),

      // ═══════════════════════════════════════════
      // SECTION 2: ARSITEKTUR PROJECT
      // ═══════════════════════════════════════════
      heading1("2. Arsitektur Project"),
      body("TamuKu menggunakan Clean Architecture dengan pola BLoC (Business Logic Component):"),

      // Architecture diagram as code block (use table to avoid paragraph border ordering issues)
      new Table({
        width: { size: 9026, type: WidthType.DXA },
        columnWidths: [9026],
        rows: [new TableRow({ children: [new TableCell({
          borders: borders(C.border),
          width: { size: 9026, type: WidthType.DXA },
          shading: { fill: "F5F5F5", type: ShadingType.CLEAR },
          margins: { top: 80, bottom: 80, left: 160, right: 160 },
          children: [new Paragraph({
            alignment: AlignmentType.CENTER,
            children: [new TextRun({ text: "UI (Screen)  \u2192  BLoC (Event \u2192 State)  \u2192  Repository  \u2192  DataSource (Remote + Local)", font: "Courier New", size: 18, color: C.darkGray })],
          })],
        })]})],
      }),

      heading2("2.1 Feature Modules"),
      ...[
        ["auth", "Autentikasi admin (login, user entity)"],
        ["guest", "Alur tamu (scan QR, form, check-in/out)"],
        ["location", "Dashboard admin, daftar tamu, QR generator, settings"],
        ["notification", "Notifikasi FCM + WhatsApp API"],
      ].map(([mod, desc]) => bullet(`${mod} \u2014 ${desc}`)),

      heading2("2.2 Firestore Collections"),
      ...["locations", "guests", "hosts"].map(c => bullet(c)),

      heading2("2.3 Konsep Mobile Computing yang Diterapkan"),
      new Table({
        width: { size: 9026, type: WidthType.DXA },
        columnWidths: [600, 2800, 5626],
        rows: [
          new TableRow({ tableHeader: true, children: [
            headerCell("#", 600), headerCell("Konsep", 2800), headerCell("Implementasi", 5626),
          ]}),
          ...([
            ["A", "Flutter Widgets (Layout, Scrolling, Text)", "Semua screen: Scaffold, Column, Row, Stack, Expanded, ListView.builder"],
            ["B", "ListView.builder", "Daftar Tamu, dashboard recent guests"],
            ["C", "FutureBuilder & StreamBuilder", "StreamBuilder untuk real-time Firestore; FutureBuilder untuk QR generation"],
            ["D", "BLoC (Business Logic Component)", "Semua state management via BLoC/Cubit"],
            ["E", "API Integration with BLoC", "Firebase Firestore via Repository \u2192 BLoC \u2192 UI"],
            ["F", "Local Storage (Offline Fallback)", "SQLite/Hive untuk offline data, sync queue"],
            ["G", "Popular Libraries", "qr_flutter, mobile_scanner, fl_chart, image_picker, hive, equatable, intl"],
          ]).map(([num, konsep, impl], ri) => new TableRow({
            children: [
              dataCell(num, 600, { fill: ri % 2 === 0 ? C.white : C.altRow, align: AlignmentType.CENTER }),
              dataCell(konsep, 2800, { fill: ri % 2 === 0 ? C.white : C.altRow, bold: true }),
              dataCell(impl, 5626, { fill: ri % 2 === 0 ? C.white : C.altRow }),
            ],
          })),
        ],
      }),

      new Paragraph({ children: [new PageBreak()] }),

      // ═══════════════════════════════════════════
      // SECTION 3: LIBRARY YANG DIGUNAKAN
      // ═══════════════════════════════════════════
      heading1("3. Library yang Digunakan"),

      new Table({
        width: { size: 9026, type: WidthType.DXA },
        columnWidths: [1600, 3600, 3826],
        rows: [
          new TableRow({ tableHeader: true, children: [
            headerCell("Kategori", 1600), headerCell("Package", 3600), headerCell("Fungsi", 3826),
          ]}),
          ...([
            ["Framework", "flutter 3.x, dart 3.x", "UI cross-platform"],
            ["State Management", "flutter_bloc ^8.x", "BLoC/Cubit pattern"],
            ["Equality", "equatable ^2.x", "Value equality untuk states/events"],
            ["Backend", "cloud_firestore, firebase_auth, firebase_core, firebase_messaging, firebase_storage", "Firebase services"],
            ["QR Code", "qr_flutter ^4.1.0, mobile_scanner ^5.0.0", "Generate & scan QR"],
            ["Charts", "fl_chart ^0.68.0", "Dashboard bar chart"],
            ["Local Storage", "hive, sqflite, shared_preferences", "Offline data cache"],
            ["UI/UX", "cached_network_image, lottie, google_fonts", "Image caching, animations"],
            ["Utilities", "intl, image_picker, connectivity_plus, permission_handler, share_plus", "Formatting, permissions, sharing"],
          ]).map(([cat, pkg, func], ri) => new TableRow({
            children: [
              dataCell(cat, 1600, { fill: ri % 2 === 0 ? C.white : C.altRow, bold: true }),
              dataCell(pkg, 3600, { fill: ri % 2 === 0 ? C.white : C.altRow }),
              dataCell(func, 3826, { fill: ri % 2 === 0 ? C.white : C.altRow }),
            ],
          })),
        ],
      }),
    ],
  }],
});

// ── Generate ──
Packer.toBuffer(doc).then(buffer => {
  const out = 'c:\\Projects\\Mobile\\Project UAS - TamuKu\\Laporan_TamuKu.docx';
  fs.writeFileSync(out, buffer);
  console.log(`✅ Generated: ${out} (${(buffer.length / 1024).toFixed(1)} KB)`);
}).catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});
