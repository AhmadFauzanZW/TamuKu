# Changelog — TamuKu

Catatan perubahan proyek TamuKu. Format berdasarkan [Keep a Changelog](https://keepachangelog.com/).

Semua perubahan tercatat di sini, diurutkan dari yang terbaru. Setiap entri harus mencakup:
- Tanggal perubahan
- Siapa yang melakukan (inisial nama)
- Apa yang berubah
- Concept Flutter yang terkait

---

## [Unreleased] - 2026-07-07

### Added
- Excel export with formatted .xlsx (green headers, alternating rows, borders, auto-width)
- Export preview modal with DataTable, Save + Share buttons
- Guest list filter by status (Semua/Check-In/Selesai)
- Guest list sort by date (newest/oldest) and name (A-Z)
- Guest list search with 300ms debounce
- Theme-aware color helpers in AppColors (backgroundOf, surfaceOf, textPrimaryOf, etc.)
- Dark semantic colors (success, warning, info) for dark mode

### Fixed
- Dashboard stat card overflow on small screens (replaced private _StatCard with shared StatCard)
- Dark mode not applying across screens (removed hardcoded AppColors, added dark ThemeData)
- GlobalKey error when toggling dark mode (app.dart builder: Column → Stack)
- Guest list showing hardcoded dummy data (now connected to GuestBloc + Firestore)
- Export sending empty data (now loads real guests from Firestore)
- Settings screen exporting CSV (now exports formatted Excel)

### Changed
- Replaced CSV export with Excel (.xlsx) format
- AppTextStyles now color-agnostic (colors injected by ThemeData)
- All screens use theme-aware colors instead of hardcoded AppColors

---

## [0.2.0] — 2026-07-06

### Ditambahkan
- **[Domain]** GuestEntity + GuestStatus + Keperluan enums — Concept: D — Oleh: AF
- **[Domain]** GuestRepository abstract interface — Concept: D — Oleh: AF
- **[Data]** GuestRemoteDataSource (Firestore CRUD) — Concept: E — Oleh: AF
- **[Data]** GuestLocalDataSource (Hive offline cache) — Concept: F — Oleh: AF
- **[Data]** GuestRepositoryImpl (offline-first strategy) — Concept: D+F — Oleh: AF
- **[Data]** SyncQueueService + SyncOperation (pending writes queue) — Concept: F — Oleh: AF
- **[Data]** NetworkInfo (connectivity_plus) — Concept: G — Oleh: AF
- **[BLoC]** GuestBloc (LoadGuests, CheckIn, CheckOut, Delete, Search) — Concept: D — Oleh: AF
- **[BLoC]** GuestFormBloc (photo, keperluan, submit state) — Concept: D — Oleh: AF
- **[Screen]** GuestFormScreen (registration form with validation) — Concept: A — Oleh: AF
- **[Screen]** ConfirmationScreen (check-in success) — Concept: A — Oleh: AF
- **[Screen]** CheckoutScreen (check-out with duration) — Concept: A — Oleh: AF
- **[Screen]** ErrorScreen (generic error display) — Concept: A — Oleh: AF
- **[Widget]** GuestTile (guest list item with badges) — Concept: B — Oleh: AF
- **[Widget]** StatCard (dashboard metric card) — Concept: A — Oleh: AF
- **[Widget]** GuestSearchBar (debounced search) — Concept: A — Oleh: AF
- **[Widget]** GuestFilterChips (status filter) — Concept: A — Oleh: AF
- **[Widget]** ConnectivityBanner (offline indicator) — Concept: G — Oleh: AF
- **[Widget]** PhotoPickerSection (camera/gallery picker) — Concept: A — Oleh: AF
- **[Widget]** GuestSubmitButton (loading-aware submit) — Concept: A — Oleh: AF
- **[Backend]** Telegram Bot API service (H11) — Concept: E — Oleh: AF
- **[Backend]** Contabo Backend API enhanced (H14) — FCM + Telegram dual notify — Concept: E — Oleh: AF
- **[Backend]** Guest notification endpoint — Concept: E — Oleh: AF
- **[Testing]** 27 unit tests (repository + bloc) — Oleh: AF
- **[Testing]** 27 widget tests (screens + widgets) — Oleh: AF

---

## [0.1.0] — 2026-07-05

### Ditambahkan
- **[Setup]** Inisialisasi repository project — Oleh: Semua
- **[Dokumentasi]** `AGENTS.md` — Governance file untuk AI agent (arsitektur, schema, coding rules, sprint plan) — Oleh: AF
- **[Dokumentasi]** `DESIGN.md` — Design system lengkap (750+ baris: 30+ color tokens, typography, spacing, 10 screen layouts, dark mode, Flutter theme code) — Oleh: SA
- **[Dokumentasi]** `README.md` — Project README (overview, fitur, tech stack, setup guide, struktur) — Oleh: AF
- **[Dokumentasi]** `CONTRIBUTING.md` — Panduan kontribusi (branch strategy, commit format, PR process, testing) — Oleh: AF
- **[Dokumentasi]** `.github/copilot-instructions.md` — Instruksi GitHub Copilot (BLoC patterns, templates, file structure) — Oleh: AF
- **[Tooling]** `.vscode/settings.json` — Workspace settings (formatter, line length, analysis) — Oleh: AF
- **[Tooling]** `.vscode/launch.json` — Debug/Profile/Release configurations — Oleh: AF
- **[Tooling]** `.vscode/extensions.json` — Recommended extensions — Oleh: AF
- **[Agent]** `.vscode/agents/flutter-coder.md` — Flutter/Dart specialist agent — Oleh: AF
- **[Agent]** `.vscode/agents/firebase-backend.md` — Firebase backend specialist agent — Oleh: AF
- **[Agent]** `.vscode/agents/ui-reviewer.md` — UI/UX reviewer agent — Oleh: AF
- **[Config]** `.gitignore` — Flutter + Firebase gitignore — Oleh: AF
- **[Arsitektur]** Arsitektur Clean Architecture + BLoC (fitur/data|domain|presentation) — Oleh: AF
- **[Arsitektur]** 7 concept mapping (Widgets, ListView.builder, FutureBuilder/StreamBuilder, BLoC, API+BLoC, Local Storage, Popular Libraries) — Oleh: AF
- **[Planning]** `Tugas_Tim_TamuKu.docx` — Distribusi tugas tim (Agile, 2 sprint, 15 tugas/orang) — Oleh: AF
- **[Planning]** Sprint 1 & 2 plan dengan dependency map — Oleh: AF
- **[Memory]** Connected ke ObsidianVault + Copilot Memory — Oleh: AF

### Keputusan
- Menggunakan **flutter_bloc 8.x** (bukan Riverpod) — sesuai course requirement + SaaS-ready
- Menggunakan **Clean Architecture** — features/data|domain|presentation per fitur
- **Offline-first** dengan hive + sqflite — write local dulu, sync remote saat online
- **Equatable** untuk semua BLoC states/events — prevent unnecessary rebuilds
- **get_it** untuk dependency injection

---

## Format Entri Changelog

Gunakan format ini untuk setiap entri baru:

```markdown
## [versi] — YYYY-MM-DD

### Ditambahkan
- **[Nama Fitur]** Deskripsi perubahan — Concept: [A-G] — Oleh: [Nama]

### Diubah
- **[Nama Fitur]** Deskripsi perubahan — Oleh: [Nama]

### Diperbaiki
- **[Nama Bug]** Deskripsi fix — Oleh: [Nama]

### Dihapus
- **[Nama Fitur]** Deskripsi penghapusan — Oleh: [Nama]

### Keputusan
- Deskripsi keputusan teknis yang diambil
```

### Kode Concept (untuk referensi cepat)
| Kode | Concept |
|------|---------|
| A | Flutter Widgets (Basics, Layout, Scrolling, Text) |
| B | ListView.builder |
| C | FutureBuilder & StreamBuilder |
| D | BLoC (Business Logic Component) |
| E | API Integration with BLoC |
| F | Local Storage (Offline Fallback) |
| G | Popular Libraries |

### Inisial Anggota
| Inisial | Nama |
|---------|------|
| HN | Hafiz Nur Rizki |
| AF | Ahmad Fauzan |
| SA | Annur Syahrin Aisyah |

### Versi
- `0.x.x` — Development / pre-release
- `1.0.0` — MVP release (demo day)
