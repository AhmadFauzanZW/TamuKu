const fs = require("fs");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, LevelFormat,
  HeadingLevel, BorderStyle, WidthType, ShadingType,
  PageNumber, PageBreak
} = require("docx");

// ═══════════════════════════════════════════════════════════════
// TOKEN SYSTEM
// ═══════════════════════════════════════════════════════════════
const C = {
  green:    "1B5E20",
  greenLt:  "E8F5E9",
  darkGray: "333333",
  midGray:  "666666",
  altRow:   "F5F5F5",
  white:    "FFFFFF",
  border:   "CCCCCC",
};

const FONT = "Arial";
const PG_W = 11906; // A4
const PG_H = 16838;
const MARGIN = 1440; // 1 inch
const CONTENT_W = PG_W - MARGIN * 2; // 9026

const bdr = { style: BorderStyle.SINGLE, size: 1, color: C.border };
const borders = { top: bdr, bottom: bdr, left: bdr, right: bdr };
const noBorder = { style: BorderStyle.NONE, size: 0, color: "FFFFFF" };
const noBorders = { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder };

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════
function p(text, opts = {}) {
  const { bold = false, size = 22, color = C.darkGray, align = AlignmentType.LEFT,
    spacing = { before: 40, after: 40 }, font = FONT } = opts;
  return new Paragraph({
    alignment: align, spacing,
    children: [new TextRun({ text, font, size, bold, color })],
  });
}

function heading1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1, spacing: { before: 320, after: 120 },
    children: [new TextRun({ text, font: FONT, size: 32, bold: true, color: C.green })],
  });
}

function heading2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2, spacing: { before: 240, after: 100 },
    children: [new TextRun({ text, font: FONT, size: 26, bold: true, color: C.darkGray })],
  });
}

function heading3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3, spacing: { before: 200, after: 80 },
    children: [new TextRun({ text, font: FONT, size: 22, bold: true, color: C.midGray })],
  });
}

function bullet(text, level = 0) {
  return new Paragraph({
    numbering: { reference: "bullets", level }, spacing: { before: 30, after: 30 },
    children: [new TextRun({ text, font: FONT, size: 22 })],
  });
}

function headerCell(text, width) {
  return new TableCell({
    borders, width: { size: width, type: WidthType.DXA },
    shading: { fill: C.green, type: ShadingType.CLEAR },
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    verticalAlign: "center",
    children: [new Paragraph({ alignment: AlignmentType.CENTER,
      children: [new TextRun({ text, font: FONT, size: 18, bold: true, color: C.white })],
    })],
  });
}

function dataCell(text, width, opts = {}) {
  const { bold = false, fill = "FFFFFF", align = AlignmentType.LEFT } = opts;
  return new TableCell({
    borders: { top: bdr, bottom: bdr, left: bdr, right: bdr },
    width: { size: width, type: WidthType.DXA },
    shading: { fill, type: ShadingType.CLEAR },
    margins: { top: 50, bottom: 50, left: 100, right: 100 },
    verticalAlign: "center",
    children: [new Paragraph({ alignment: align,
      children: [new TextRun({ text, font: FONT, size: 18, bold })],
    })],
  });
}

function makeTable(headers, rows, colWidths) {
  return new Table({
    width: { size: CONTENT_W, type: WidthType.DXA },
    columnWidths: colWidths,
    rows: [
      new TableRow({ tableHeader: true, children: headers.map((h, i) => headerCell(h, colWidths[i])) }),
      ...rows.map((row, ri) => new TableRow({
        children: row.map((cell, ci) => dataCell(cell, colWidths[ci], {
          fill: ri % 2 === 1 ? C.altRow : C.white,
        })),
      })),
    ],
  });
}

function checkItem(text) {
  return new Paragraph({
    numbering: { reference: "checks", level: 0 }, spacing: { before: 30, after: 30 },
    children: [new TextRun({ text, font: FONT, size: 22 })],
  });
}

// ═══════════════════════════════════════════════════════════════
// DOCUMENT
// ═══════════════════════════════════════════════════════════════
const doc = new Document({
  styles: {
    default: { document: { run: { font: FONT, size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, font: FONT, color: C.green },
        paragraph: { spacing: { before: 320, after: 120 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 26, bold: true, font: FONT, color: C.darkGray },
        paragraph: { spacing: { before: 240, after: 100 }, outlineLevel: 1 } },
      { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 22, bold: true, font: FONT, color: C.midGray },
        paragraph: { spacing: { before: 200, after: 80 }, outlineLevel: 2 } },
    ],
  },
  numbering: {
    config: [
      { reference: "bullets", levels: [
        { level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } },
        { level: 1, format: LevelFormat.BULLET, text: "\u25E6", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 1080, hanging: 360 } } } },
      ]},
      { reference: "numbers", levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } },
      ]},
      { reference: "checks", levels: [
        { level: 0, format: LevelFormat.BULLET, text: "\u2610", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } },
      ]},
    ],
  },
  sections: [
    // ═══════════════════════════════════════════════════════════
    // TITLE PAGE
    // ═══════════════════════════════════════════════════════════
    {
      properties: {
        page: {
          size: { width: PG_W, height: PG_H },
          margin: { top: MARGIN, right: MARGIN, bottom: MARGIN, left: MARGIN },
        },
      },
      children: [
        // Spacer
        ...Array(6).fill(null).map(() => p("", { size: 10, spacing: { before: 0, after: 0 } })),

        // Title
        p("DISTRIBUSI TUGAS PROYEK TAMUKU", {
          bold: true, size: 48, color: C.green,
          align: AlignmentType.CENTER, spacing: { before: 0, after: 100 },
        }),

        // Subtitle
        p("Aplikasi Buku Tamu Digital — Mobile Computing UAS", {
          bold: false, size: 26, color: C.midGray,
          align: AlignmentType.CENTER, spacing: { before: 0, after: 200 },
        }),

        // Divider line
        new Paragraph({
          alignment: AlignmentType.CENTER, spacing: { before: 100, after: 200 },
          border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: C.green, space: 1 } },
          children: [],
        }),

        // Team members
        p("Tim Pengembang:", { bold: true, size: 24, align: AlignmentType.CENTER, spacing: { before: 200, after: 80 } }),
        p("Hafiz Nur Rizki (24110300038)", { size: 22, align: AlignmentType.CENTER, spacing: { before: 30, after: 30 } }),
        p("Ahmad Fauzan (24110500007) — Tech Lead", { size: 22, align: AlignmentType.CENTER, spacing: { before: 30, after: 30 } }),
        p("Annur Syahrin Aisyah (24110500014)", { size: 22, align: AlignmentType.CENTER, spacing: { before: 30, after: 30 } }),

        // Spacer
        ...Array(3).fill(null).map(() => p("", { size: 10, spacing: { before: 0, after: 0 } })),

        // Dosen
        p("Dosen Pengampu:", { bold: true, size: 24, align: AlignmentType.CENTER, spacing: { before: 100, after: 80 } }),
        p("Hedy Pamungkas, S.T., M.T.I", { size: 22, align: AlignmentType.CENTER, spacing: { before: 30, after: 30 } }),

        // Spacer
        ...Array(3).fill(null).map(() => p("", { size: 10, spacing: { before: 0, after: 0 } })),

        // University + Year
        p("UNIVERSITAS CAKRAWALA", {
          bold: true, size: 28, color: C.green,
          align: AlignmentType.CENTER, spacing: { before: 100, after: 60 },
        }),
        p("2026", { size: 22, align: AlignmentType.CENTER, spacing: { before: 30, after: 0 } }),
      ],
    },

    // ═══════════════════════════════════════════════════════════
    // MAIN CONTENT
    // ═══════════════════════════════════════════════════════════
    {
      properties: {
        page: {
          size: { width: PG_W, height: PG_H },
          margin: { top: MARGIN, right: MARGIN, bottom: MARGIN, left: MARGIN },
        },
      },
      headers: {
        default: new Header({
          children: [new Paragraph({
            alignment: AlignmentType.RIGHT, spacing: { after: 100 },
            border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: C.green, space: 4 } },
            children: [new TextRun({ text: "TamuKu — Distribusi Tugas", font: FONT, size: 16, color: C.midGray, italics: true })],
          })],
        }),
      },
      footers: {
        default: new Footer({
          children: [new Paragraph({
            alignment: AlignmentType.CENTER, spacing: { before: 100 },
            border: { top: { style: BorderStyle.SINGLE, size: 4, color: C.green, space: 4 } },
            children: [
              new TextRun({ text: "Halaman ", font: FONT, size: 16, color: C.midGray }),
              new TextRun({ children: [PageNumber.CURRENT], font: FONT, size: 16, color: C.midGray }),
            ],
          })],
        }),
      },
      children: [
        // ─────────────────────────────────────────────────────
        // SECTION 1: GAMBARAN PROYEK
        // ─────────────────────────────────────────────────────
        heading1("1. Gambaran Proyek"),
        p("TamuKu adalah aplikasi mobile Flutter untuk mencatat kunjungan tamu secara digital. Aplikasi ini menggantikan buku tamu fisik yang biasa digunakan di kantor, RT/RW, masjid, apartemen, sekolah, dan berbagai instansi lainnya."),
        p("Alur kerja utama: Tamu memindai kode QR yang terpampang di lokasi → mengisi formulir registrasi → data kunjungan tercatat secara otomatis → admin menerima notifikasi WhatsApp saat tamu tiba."),
        p("Proyek ini dikembangkan sebagai tugas akhir (UAS) mata kuliah Mobile Computing di Universitas Cakrawala, sekaligus menjadi fondasi MVP untuk produk SaaS di masa depan."),

        // ─────────────────────────────────────────────────────
        // SECTION 2: TIM DAN PEMBAGIAN PERAN
        // ─────────────────────────────────────────────────────
        heading1("2. Tim dan Pembagian Peran"),
        p("Pembagian peran didasarkan pada keahlian dan fokus masing-masing anggota:"),
        makeTable(
          ["Nama", "NIM", "Peran", "Fokus Utama"],
          [
            ["Hafiz Nur Rizki", "24110300038", "Backend & Integrasi", "Auth, Notifikasi, WhatsApp API, Cloud Functions"],
            ["Ahmad Fauzan", "24110500007", "Tech Lead & Core Features", "Guest CRUD, Offline Sync, Multi-location"],
            ["Annur Syahrin Aisyah", "24110500014", "Frontend & UI", "QR Scanner/Generator, Dashboard, Charts, Dark Mode"],
          ],
          [2200, 1500, 2200, 3126]
        ),

        // ─────────────────────────────────────────────────────
        // SECTION 3: ARSITEKTUR & TECH STACK
        // ─────────────────────────────────────────────────────
        heading1("3. Arsitektur & Tech Stack"),
        heading2("3.1 Arsitektur Clean Architecture"),
        p("TamuKu menerapkan Clean Architecture dengan pemisahan yang jelas antara UI, Business Logic, dan Data Layer:"),
        p("UI (Screen) → BLoC (Event → State) → Repository → DataSource (Remote + Local)", { bold: true, size: 22, color: C.green, align: AlignmentType.CENTER, spacing: { before: 100, after: 100 } }),
        p("Setiap fitur diorganisir dalam struktur folder:"),
        bullet("data/ — Remote DataSource (Firebase) + Local DataSource (Hive/SQLite) + Repository implementations"),
        bullet("domain/ — Entity dan Abstract Repository interface"),
        bullet("presentation/ — BLoC (Events, States) + Screen widgets"),

        heading2("3.2 Tech Stack"),
        makeTable(
          ["Layer", "Teknologi", "Versi"],
          [
            ["Language", "Dart", "3.x"],
            ["Framework", "Flutter", "3.x (latest stable)"],
            ["State Management", "flutter_bloc", "8.x"],
            ["State Equivalence", "equatable", "2.x"],
            ["Backend", "Firebase (Firestore, Auth, FCM, Storage)", "Latest"],
            ["Local Storage", "hive + sqflite", "—"],
            ["QR Generation", "qr_flutter", "4.x"],
            ["QR Scanning", "mobile_scanner", "5.x"],
            ["Charts", "fl_chart", "—"],
            ["Network Detection", "connectivity_plus", "—"],
          ],
          [2500, 4526, 2000]
        ),

        // ─────────────────────────────────────────────────────
        // SECTION 4: METODOLOGI KERJA — AGILE
        // ─────────────────────────────────────────────────────
        heading1("4. Metodologi Kerja — Agile"),
        p("Proyek TamuKu menggunakan metodologi Agile (Scrum) dengan sprint berdurasi 2 minggu. Berikut alasan pemilihan Agile:"),

        heading2("4.1 Mengapa Agile?"),
        bullet("Pekerjaan paralel — 3 orang bisa bekerja bersamaan pada fitur berbeda tanpa saling menunggu"),
        bullet("Feedback cepat — review dan demo dilakukan setiap akhir sprint (2 minggu)"),
        bullet("Adaptif — prioritas bisa diubah tiap sprint berdasarkan temuan atau perubahan kebutuhan"),
        bullet("Testing berkelanjutan — bug dan masalah ketahuan lebih awal, mengurangi biaya perbaikan"),

        heading2("4.2 Struktur Sprint"),
        makeTable(
          ["Sprint", "Durasi", "Fokus", "Deliverables"],
          [
            ["Sprint 1", "Minggu 1-2", "Fondasi + Fitur Inti", "Project setup, Auth, Guest CRUD, QR, Dashboard, Basic offline"],
            ["Sprint 2", "Minggu 3-4", "Fitur Lanjutan + Polish", "WhatsApp, Export, Offline Sync, Charts, Dark Mode, Testing"],
          ],
          [1500, 1500, 3026, 3000]
        ),

        // ─────────────────────────────────────────────────────
        // SECTION 5: ALUR KERJA PARALEL
        // ─────────────────────────────────────────────────────
        heading1("5. Alur Kerja Paralel"),
        p("Berikut diagram alur kerja paralel selama 4 minggu pengembangan:"),
        p(""),

        // Alur kerja diagram as table
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [CONTENT_W],
          rows: [new TableRow({
            children: [new TableCell({
              borders: { top: bdr, bottom: bdr, left: bdr, right: bdr },
              width: { size: CONTENT_W, type: WidthType.DXA },
              shading: { fill: "F0F4F0", type: ShadingType.CLEAR },
              margins: { top: 120, bottom: 120, left: 200, right: 200 },
              children: [
                new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "Hari 1–2: SETUP BERSAMA (3 orang)", font: "Courier New", size: 20, bold: true, color: C.green })] }),
                new Paragraph({ spacing: { after: 30 }, children: [new TextRun({ text: "    ↓", font: "Courier New", size: 20 })] }),
                new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "Hari 3–10: PARALEL per FITUR", font: "Courier New", size: 20, bold: true })] }),
                new Paragraph({ spacing: { after: 20 }, children: [new TextRun({ text: "    ├── Hafiz:   Auth + Notifikasi", font: "Courier New", size: 20 })] }),
                new Paragraph({ spacing: { after: 20 }, children: [new TextRun({ text: "    ├── Ahmad:   Guest CRUD + Offline", font: "Courier New", size: 20 })] }),
                new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "    └── Annur:   QR + Dashboard", font: "Courier New", size: 20 })] }),
                new Paragraph({ spacing: { after: 30 }, children: [new TextRun({ text: "    ↓", font: "Courier New", size: 20 })] }),
                new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "Hari 11–14: INTEGRASI + REVIEW (3 orang)", font: "Courier New", size: 20, bold: true })] }),
                new Paragraph({ spacing: { after: 30 }, children: [new TextRun({ text: "    ↓", font: "Courier New", size: 20 })] }),
                new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "Minggu 3–4: SPRINT 2 PARALEL", font: "Courier New", size: 20, bold: true, color: C.green })] }),
                new Paragraph({ spacing: { after: 20 }, children: [new TextRun({ text: "    ├── Hafiz:   WhatsApp + Settings + Export", font: "Courier New", size: 20 })] }),
                new Paragraph({ spacing: { after: 20 }, children: [new TextRun({ text: "    ├── Ahmad:   Offline Sync + Multi-location", font: "Courier New", size: 20 })] }),
                new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "    └── Annur:   Chart + Dark Mode + Polish", font: "Courier New", size: 20 })] }),
                new Paragraph({ spacing: { after: 30 }, children: [new TextRun({ text: "    ↓", font: "Courier New", size: 20 })] }),
                new Paragraph({ children: [new TextRun({ text: "Minggu 4 Akhir: UAT + DEMO (3 orang)", font: "Courier New", size: 20, bold: true, color: C.green })] }),
              ],
            })],
          })],
        }),

        // ─────────────────────────────────────────────────────
        // SECTION 6: SPRINT 1
        // ─────────────────────────────────────────────────────
        heading1("6. Sprint 1 — Fondasi + Fitur Inti (Minggu 1–2)"),

        // Phase 1.1
        heading2("6.1 Phase 1.1: Setup Bersama (Hari 1–2)"),
        p("Seluruh tim bekerja bersama untuk menyiapkan fondasi proyek:"),
        makeTable(
          ["#", "Tugas", "Siapa", "Estimasi"],
          [
            ["1", "Inisialisasi project Flutter + pubspec.yaml", "Semua", "0.5 hari"],
            ["2", "Konfigurasi Firebase (Firestore, Auth, Storage)", "Semua", "0.5 hari"],
            ["3", "Setup dependencies (flutter_bloc, equatable, hive, dll.)", "Semua", "0.5 hari"],
            ["4", "Setup folder Clean Architecture + dependency injection", "Semua", "0.5 hari"],
            ["5", "Setup theme system sesuai DESIGN.md (warna, tipografi, spacing)", "Semua", "0.5 hari"],
            ["6", "Setup routing + constants + app_constants.dart", "Semua", "0.5 hari"],
          ],
          [600, 4426, 1500, 2500]
        ),
        p("Total estimasi Phase 1.1: 3 hari kerja (dikerjakan bersama)", { bold: true, spacing: { before: 80, after: 100 } }),

        // Phase 1.2
        heading2("6.2 Phase 1.2: Paralel per Fitur (Hari 3–10)"),

        // --- Hafiz ---
        heading3("Hafiz Nur Rizki — Auth + Notifikasi"),
        makeTable(
          ["#", "Tugas", "Konsep", "Estimasi"],
          [
            ["H1", "Domain: user_entity.dart, auth_repository.dart", "BLoC Architecture", "0.5 hari"],
            ["H2", "Data: auth_remote_datasource.dart (Firebase Auth)", "API Integration", "1 hari"],
            ["H3", "Data: auth_repository_impl.dart", "Repository Pattern", "0.5 hari"],
            ["H4", "BLoC: auth_event, auth_state, auth_bloc", "BLoC (D)", "1 hari"],
            ["H5", "Screen: login_screen.dart", "Widgets (A)", "1 hari"],
            ["H6", "Domain: notification_repository.dart", "BLoC Architecture", "0.5 hari"],
            ["H7", "Data: notification_repository_impl.dart (FCM)", "API Integration", "1 hari"],
            ["H8", "BLoC: notification_bloc", "BLoC (D)", "0.5 hari"],
            ["H9", "Unit tests: auth + notification", "Testing", "1 hari"],
            ["H10", "Offline: auth_local_datasource.dart (hive)", "Local Storage (F)", "0.5 hari"],
          ],
          [600, 4026, 2400, 2000]
        ),
        p("Subtotal Hafiz Sprint 1: 7.5 hari", { bold: true, spacing: { before: 80, after: 120 } }),

        // --- Ahmad ---
        heading3("Ahmad Fauzan — Guest CRUD + Check-in/Out"),
        makeTable(
          ["#", "Tugas", "Konsep", "Estimasi"],
          [
            ["A1", "Domain: guest_entity.dart, guest_repository.dart", "BLoC Architecture", "0.5 hari"],
            ["A2", "Data: guest_remote_datasource.dart (Firestore)", "API Integration", "1 hari"],
            ["A3", "Data: guest_repository_impl.dart (remote+local)", "Repository + Offline", "1 hari"],
            ["A4", "Data: guest_local_datasource.dart (hive/sqflite)", "Local Storage (F)", "1 hari"],
            ["A5", "BLoC: guest_event, guest_state, guest_bloc", "BLoC (D)", "1 hari"],
            ["A6", "Screen: guest_form_screen.dart", "Widgets (A)", "1 hari"],
            ["A7", "Screen: confirmation + checkout screens", "Widgets (A)", "0.5 hari"],
            ["A8", "Screen: error_screen.dart", "Widgets (A)", "0.5 hari"],
            ["A9", "Widget: guest_tile.dart (ListTile + avatar)", "ListView.builder (B)", "0.5 hari"],
            ["A10", "Unit tests: guest_repository + bloc", "Testing", "1 hari"],
          ],
          [600, 4026, 2400, 2000]
        ),
        p("Subtotal Ahmad Sprint 1: 8 hari", { bold: true, spacing: { before: 80, after: 120 } }),

        // --- Annur ---
        heading3("Annur Syahrin Aisyah — Location + QR + Dashboard"),
        makeTable(
          ["#", "Tugas", "Konsep", "Estimasi"],
          [
            ["N1", "Domain: location_entity.dart, location_repository.dart", "BLoC Architecture", "0.5 hari"],
            ["N2", "Data: location_remote_datasource.dart", "API Integration", "1 hari"],
            ["N3", "Data: location_repository_impl.dart (remote+local)", "Repository + Offline", "1 hari"],
            ["N4", "Data: location_local_datasource.dart", "Local Storage (F)", "0.5 hari"],
            ["N5", "BLoC: location_event, location_state, location_bloc", "BLoC (D)", "1 hari"],
            ["N6", "Screen: scan_screen.dart (mobile_scanner)", "Popular Libraries (G)", "1 hari"],
            ["N7", "Screen: qr_generator_screen.dart (qr_flutter)", "Popular Libraries (G)", "1 hari"],
            ["N8", "Screen: dashboard_screen.dart (stat cards + fl_chart)", "Popular Libraries (G)", "1 hari"],
            ["N9", "Screen: guest_list_screen.dart (search + filter + ListView.builder)", "ListView.builder (B)", "1 hari"],
            ["N10", "Unit tests: location_repository + bloc", "Testing", "0.5 hari"],
          ],
          [600, 4026, 2400, 2000]
        ),
        p("Subtotal Annur Sprint 1: 8.5 hari", { bold: true, spacing: { before: 80, after: 120 } }),

        // ─────────────────────────────────────────────────────
        // SECTION 7: SPRINT 2
        // ─────────────────────────────────────────────────────
        heading1("7. Sprint 2 — Fitur Lanjutan + Polish (Minggu 3–4)"),

        // --- Hafiz Sprint 2 ---
        heading3("Hafiz Nur Rizki — WhatsApp + Settings + Export"),
        makeTable(
          ["#", "Tugas", "Konsep", "Estimasi"],
          [
            ["H11", "WhatsApp API service (WA Business API)", "API Integration", "1 hari"],
            ["H12", "Screen: settings_screen.dart", "Widgets (A)", "1 hari"],
            ["H13", "Export service: CSV", "Popular Libraries (G)", "1 hari"],
            ["H14", "Cloud Functions: notifikasi trigger on check-in", "API Integration", "1 hari"],
            ["H15", "Widget tests: login, settings, notification", "Testing", "1 hari"],
          ],
          [600, 4426, 2400, 1600]
        ),
        p("Subtotal Hafiz Sprint 2: 5 hari", { bold: true, spacing: { before: 80, after: 120 } }),

        // --- Ahmad Sprint 2 ---
        heading3("Ahmad Fauzan — Offline Sync + Multi-location"),
        makeTable(
          ["#", "Tugas", "Konsep", "Estimasi"],
          [
            ["A11", "Offline sync queue (write local → sync saat online)", "Offline-first (F)", "1.5 hari"],
            ["A12", "connectivity_plus integration", "Popular Libraries (G)", "0.5 hari"],
            ["A13", "Multi-location support", "BLoC (D)", "1 hari"],
            ["A14", "Shared widgets: stat_card, search_bar, filter_chips", "Widgets (A)", "1 hari"],
            ["A15", "Widget tests: guest form, confirmation, shared widgets", "Testing", "1 hari"],
          ],
          [600, 4426, 2400, 1600]
        ),
        p("Subtotal Ahmad Sprint 2: 5 hari", { bold: true, spacing: { before: 80, after: 120 } }),

        // --- Annur Sprint 2 ---
        heading3("Annur Syahrin Aisyah — Chart + Dark Mode + Polish"),
        makeTable(
          ["#", "Tugas", "Konsep", "Estimasi"],
          [
            ["N11", "fl_chart bar chart 7 hari terakhir", "Popular Libraries (G)", "1 hari"],
            ["N12", "StreamBuilder: real-time Firestore updates", "StreamBuilder (C)", "1 hari"],
            ["N13", "FutureBuilder: QR + settings + export", "FutureBuilder (C)", "0.5 hari"],
            ["N14", "Dark mode implementation", "Widgets (A)", "1 hari"],
            ["N15", "Widget tests: dashboard, QR, scan", "Testing", "1.5 hari"],
          ],
          [600, 4426, 2400, 1600]
        ),
        p("Subtotal Annur Sprint 2: 5 hari", { bold: true, spacing: { before: 80, after: 120 } }),

        // ─────────────────────────────────────────────────────
        // SECTION 8: PETA KETERGANTUNGAN
        // ─────────────────────────────────────────────────────
        heading1("8. Peta Ketergantungan"),
        p("Tabel berikut menunjukkan dependensi antar tugas — setiap tugas tidak bisa dimulai sebelum dependensinya selesai:"),
        makeTable(
          ["Tugas", "Bergantung Pada", "Memblokir"],
          [
            ["Phase 1.2 (semua)", "Phase 1.1 selesai", "Semua fitur"],
            ["Auth BLoC (H4)", "Entity + Repository (H1–H3)", "Login screen (H5)"],
            ["Login screen (H5)", "Auth BLoC (H4)", "—"],
            ["Guest BLoC (A5)", "Entity + Repository (A1–A4)", "Guest screens (A6–A8)"],
            ["Guest screens (A6–A8)", "Guest BLoC (A5)", "—"],
            ["Location BLoC (N5)", "Entity + Repository (N1–N4)", "QR + Dashboard (N6–N9)"],
            ["QR Scanner (N6)", "Location BLoC (N5)", "—"],
            ["Dashboard (N8)", "Location BLoC (N5)", "—"],
            ["WhatsApp (H11)", "Auth + Notification (H4, H8)", "—"],
            ["Offline Sync (A11)", "Guest Local DS (A4)", "—"],
            ["Dark Mode (N14)", "Theme system (Phase 1.1)", "—"],
            ["Integration Test", "Semua fitur selesai", "UAT"],
          ],
          [2800, 3226, 3000]
        ),

        // ─────────────────────────────────────────────────────
        // SECTION 9: CONCEPT MAPPING
        // ─────────────────────────────────────────────────────
        heading1("9. Concept Mapping — Pemetaan Konsep Kuliah"),
        p("Tabel berikut menunjukkan konsep Mobile Computing yang dicakup oleh masing-masing anggota:"),

        // Concept mapping table - wide format
        makeTable(
          ["Konsep", "Hafiz", "Ahmad", "Annur"],
          [
            ["A. Flutter Widgets", "Login screen", "Guest forms, error, confirmation", "QR, dashboard, settings, guest list"],
            ["B. ListView.builder", "—", "guest_tile.dart", "guest_list_screen.dart"],
            ["C. FutureBuilder / StreamBuilder", "—", "—", "StreamBuilder (real-time), FutureBuilder (QR/settings)"],
            ["D. BLoC", "AuthBloc, NotificationBloc", "GuestBloc", "LocationBloc"],
            ["E. API + BLoC", "Auth + FCM repos", "Guest repo (Firestore)", "Location repo (Firestore)"],
            ["F. Local Storage", "Auth cache (hive)", "Guest cache (hive/sqflite) + offline sync", "Location cache (hive)"],
            ["G. Popular Libraries", "FCM, share_plus", "hive, sqflite, connectivity_plus", "qr_flutter, mobile_scanner, fl_chart"],
          ],
          [2400, 2000, 2426, 2200]
        ),

        // ─────────────────────────────────────────────────────
        // SECTION 10: DELIVERABLES PER ANGGOTA
        // ─────────────────────────────────────────────────────
        heading1("10. Deliverables per Anggota"),
        p("Checklist deliverables yang harus diselesaikan oleh masing-masing anggota:"),

        heading3("Hafiz Nur Rizki"),
        checkItem("auth_repository.dart + auth_repository_impl.dart"),
        checkItem("auth_remote_datasource.dart (Firebase Auth)"),
        checkItem("auth_local_datasource.dart (hive caching)"),
        checkItem("user_entity.dart + auth_event + auth_state + auth_bloc"),
        checkItem("login_screen.dart (BLoCProvider + BlocConsumer)"),
        checkItem("notification_repository.dart + impl (FCM)"),
        checkItem("notification_bloc.dart"),
        checkItem("WhatsApp API service integration"),
        checkItem("settings_screen.dart"),
        checkItem("CSV export service"),
        checkItem("Cloud Functions: notifikasi trigger"),
        checkItem("Unit tests: auth + notification repositories"),
        checkItem("Widget tests: login + settings screens"),
        checkItem("Doc comment di semua public API"),
        checkItem("0 issues pada flutter analyze"),

        heading3("Ahmad Fauzan"),
        checkItem("guest_repository.dart + guest_repository_impl.dart"),
        checkItem("guest_remote_datasource.dart (Firestore)"),
        checkItem("guest_local_datasource.dart (hive/sqflite)"),
        checkItem("guest_entity.dart + guest_event + guest_state + guest_bloc"),
        checkItem("guest_form_screen.dart (form + validation)"),
        checkItem("confirmation_screen.dart + checkout_screen.dart"),
        checkItem("error_screen.dart"),
        checkItem("guest_tile.dart (ListTile + CircleAvatar)"),
        checkItem("Offline sync queue implementation"),
        checkItem("connectivity_plus integration"),
        checkItem("Multi-location support"),
        checkItem("Shared widgets: stat_card, search_bar, filter_chips"),
        checkItem("Unit tests: guest_repository + bloc"),
        checkItem("Doc comment di semua public API"),
        checkItem("0 issues pada flutter analyze"),

        heading3("Annur Syahrin Aisyah"),
        checkItem("location_repository.dart + location_repository_impl.dart"),
        checkItem("location_remote_datasource.dart (Firestore)"),
        checkItem("location_local_datasource.dart (hive)"),
        checkItem("location_entity.dart + location_event + location_state + location_bloc"),
        checkItem("scan_screen.dart (mobile_scanner)"),
        checkItem("qr_generator_screen.dart (qr_flutter)"),
        checkItem("dashboard_screen.dart (stat cards + fl_chart)"),
        checkItem("guest_list_screen.dart (search + filter + ListView.builder)"),
        checkItem("fl_chart bar chart 7 hari terakhir"),
        checkItem("StreamBuilder: real-time Firestore updates"),
        checkItem("FutureBuilder: QR + settings + export"),
        checkItem("Dark mode implementation"),
        checkItem("Unit tests: location_repository + bloc"),
        checkItem("Widget tests: dashboard, QR, scan"),
        checkItem("0 issues pada flutter analyze"),

        // ─────────────────────────────────────────────────────
        // SECTION 11: QUALITY GATES
        // ─────────────────────────────────────────────────────
        heading1("11. Quality Gates"),
        p("Sebelum suatu fitur dinyatakan \"selesai\", semua kriteria berikut WAJIB terpenuhi:"),

        makeTable(
          ["#", "Kriteria", "Threshold", "Cara Verifikasi"],
          [
            ["1", "flutter analyze", "0 issues", "Jalankan flutter analyze"],
            ["2", "Semua test pass", "100% pass rate", "Jalankan flutter test"],
            ["3", "Test coverage", "≥ 80% (services layer)", "flutter test --coverage"],
            ["4", "UI sesuai DESIGN.md", "Warna, tipografi, spacing sesuai", "Review visual vs DESIGN.md"],
            ["5", "Teks user-facing", "Semua Bahasa Indonesia", "Manual review"],
            ["6", "Offline-first", "Semua fitur punya fallback lokal", "Matikan internet → test"],
            ["7", "Dokumentasi", "Doc comment di semua public API", "Cek doc comment per file"],
            ["8", "File length", "Maksimal 300 baris/file", "wc -l atau IDE check"],
            ["9", "Commit message", "[feature/auth] Deskripsi", "Format: [prefix/nama] Deskripsi"],
            ["10", "No hardcoded strings", "Semua di app_constants.dart", "grep hardcode"],
          ],
          [600, 2500, 2826, 3100]
        ),

        // ─────────────────────────────────────────────────────
        // SECTION 12: CATATAN PENTING
        // ─────────────────────────────────────────────────────
        heading1("12. Catatan Penting"),
        p("Poin-poin kritis yang WAJIB dipatuhi selama pengembangan:"),

        bullet("Setiap anggota WAJIB baca AGENTS.md dan DESIGN.md sebelum mulai coding"),
        bullet("Semua screen harus demonstrate multiple widget categories (layout, scrolling, text, input, navigation)"),
        bullet("Tidak boleh pakai setState — hanya BLoC untuk state management"),
        bullet("ListView.builder untuk semua dynamic list — tidak boleh ListView(children: [...])"),
        bullet("StreamBuilder untuk data real-time Firestore (guest list, dashboard stats)"),
        bullet("FutureBuilder untuk operasi satu kali (QR generation, settings load, CSV export)"),
        bullet("Offline-first: write ke local storage dulu, sync ke remote saat online"),
        bullet("Semua file maksimal 300 baris — split jika lebih panjang"),
        bullet("Jangan asumsikan ada koneksi internet — selalu sediakan fallback offline"),
        bullet("Gunakan flutter_lints strict mode di analysis_options.yaml"),

        p(""),
        p(""),

        // Closing
        new Paragraph({
          alignment: AlignmentType.CENTER, spacing: { before: 200, after: 100 },
          border: { top: { style: BorderStyle.SINGLE, size: 6, color: C.green, space: 8 } },
          children: [],
        }),
        p("Dokumen ini disusun oleh Tim TamuKu — Universitas Cakrawala 2026", {
          size: 20, color: C.midGray, align: AlignmentType.CENTER, spacing: { before: 100, after: 40 },
        }),
        p("Hafiz Nur Rizki • Ahmad Fauzan • Annur Syahrin Aisyah", {
          size: 20, color: C.darkGray, bold: true, align: AlignmentType.CENTER, spacing: { before: 40, after: 40 },
        }),
      ],
    },
  ],
});

// ═══════════════════════════════════════════════════════════════
// GENERATE
// ═══════════════════════════════════════════════════════════════
const OUTPUT = "Tugas_Tim_TamuKu.docx";

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(OUTPUT, buffer);
  console.log(`✅ ${OUTPUT} created (${(buffer.length / 1024).toFixed(1)} KB)`);
}).catch(err => {
  console.error("❌ Error:", err);
  process.exit(1);
});
