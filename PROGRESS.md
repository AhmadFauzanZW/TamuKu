# Progress Tracker — TamuKu

> Tracker progress pengerjaan proyek TamuKu.
> Update file ini setiap kali menyelesaikan tugas. Centang ✅ yang sudah selesai.

**Terakhir diperbarui:** 2026-07-06

---

## Ringkasan Progress

| Anggota | Sprint 1 | Sprint 2 | Total |
|---------|----------|----------|-------|
| Hafiz Nur Rizki | 0/10 | 0/5 | 0/15 |
| Ahmad Fauzan | 10/10 | 5/5 | 15/15 |
| Annur Syahrin Aisyah | 0/10 | 0/5 | 0/15 |
| TOTAL | **10/30** | **5/15** | **15/45** |

**Persentase Selesai:** 33.3%

---

## Sprint 1: Fondasi + Fitur Inti (Minggu 1-2)

### Phase 1.1: Setup Bersama (Hari 1-2) ✅

> ⚠️ Phase ini harus selesai SEBELUM Phase 1.2 dimulai. Semua anggota mengerjakan BERSAMA.

| # | Tugas | Siapa | Status | Tanggal Selesai | Catatan |
|---|-------|-------|--------|-----------------|---------|
| S1 | Inisialisasi project Flutter (`flutter create tamuku`) | Semua | ✅ | 2026-07-05 | |
| S2 | Konfigurasi Firebase (`flutterfire configure`) | Semua | ✅ | 2026-07-06 | Firebase project: tamuku-6360f |
| S3 | Setup `pubspec.yaml` + semua dependencies | Semua | ✅ | 2026-07-05 | |
| S4 | Setup folder Clean Architecture | Semua | ✅ | 2026-07-05 | |
| S5 | Setup theme system dari DESIGN.md | Semua | ✅ | 2026-07-05 | |
| S6 | Setup routing + constants + DI (get_it) | Semua | ✅ | 2026-07-05 | |

---

### Phase 1.2: Paralel per Fitur (Hari 3-10) ⬜

> Dimulai SETELAH Phase 1.1 selesai. Setiap anggota mengerjakan fitur masing-masing secara PARALEL.

#### 🔧 Hafiz Nur Rizki — Auth + Notifikasi (7.5 hari)

| # | Tugas | Concept | Status | Tanggal Selesai | Catatan |
|---|-------|---------|--------|-----------------|---------|
| H1 | Domain: `user_entity.dart`, `auth_repository.dart` | D | ⬜ | — | |
| H2 | Data: `auth_remote_datasource.dart` (Firebase Auth) | E | ⬜ | — | |
| H3 | Data: `auth_repository_impl.dart` | D | ⬜ | — | |
| H4 | BLoC: `auth_event.dart`, `auth_state.dart`, `auth_bloc.dart` | D | ⬜ | — | |
| H5 | Screen: `login_screen.dart` | A | ⬜ | — | |
| H6 | Domain: `notification_repository.dart` | D | ⬜ | — | |
| H7 | Data: `notification_repository_impl.dart` (FCM) | E | ⬜ | — | |
| H8 | BLoC: `notification_bloc.dart` | D | ⬜ | — | |
| H9 | Unit tests: auth + notification | — | ⬜ | — | |
| H10 | Offline: `auth_local_datasource.dart` (hive) | F | ⬜ | — | |

#### 📱 Ahmad Fauzan — Guest CRUD + Check-in/Out (8 hari)

| # | Tugas | Concept | Status | Tanggal Selesai | Catatan |
|---|-------|---------|--------|-----------------|---------|
| A1 | Domain: `guest_entity.dart`, `guest_repository.dart` | D | ✅ | 2026-07-06 | |
| A2 | Data: `guest_remote_datasource.dart` (Firestore) | E | ✅ | 2026-07-06 | |
| A3 | Data: `guest_repository_impl.dart` (remote+local) | D+F | ✅ | 2026-07-06 | |
| A4 | Data: `guest_local_datasource.dart` (hive/sqflite) | F | ✅ | 2026-07-06 | |
| A5 | BLoC: `guest_event.dart`, `guest_state.dart`, `guest_bloc.dart` | D | ✅ | 2026-07-06 | |
| A6 | Screen: `guest_form_screen.dart` | A | ✅ | 2026-07-06 | |
| A7 | Screen: `confirmation_screen.dart` + `checkout_screen.dart` | A | ✅ | 2026-07-06 | |
| A8 | Screen: `error_screen.dart` | A | ✅ | 2026-07-06 | |
| A9 | Widget: `guest_tile.dart` | B | ✅ | 2026-07-06 | |
| A10 | Unit tests: guest_repository + bloc | — | ✅ | 2026-07-06 | |

#### 🎨 Annur Syahrin Aisyah — Location + QR + Dashboard (8.5 hari)

| # | Tugas | Concept | Status | Tanggal Selesai | Catatan |
|---|-------|---------|--------|-----------------|---------|
| N1 | Domain: `location_entity.dart`, `location_repository.dart` | D | ⬜ | — | |
| N2 | Data: `location_remote_datasource.dart` | E | ⬜ | — | |
| N3 | Data: `location_repository_impl.dart` (remote+local) | D+F | ⬜ | — | |
| N4 | Data: `location_local_datasource.dart` | F | ⬜ | — | |
| N5 | BLoC: `location_event.dart`, `location_state.dart`, `location_bloc.dart` | D | ⬜ | — | |
| N6 | Screen: `scan_screen.dart` (mobile_scanner) | G | ⬜ | — | |
| N7 | Screen: `qr_generator_screen.dart` (qr_flutter) | G | ⬜ | — | |
| N8 | Screen: `dashboard_screen.dart` (stat cards + fl_chart) | G | ⬜ | — | |
| N9 | Screen: `guest_list_screen.dart` (search + filter) | B | ⬜ | — | |
| N10 | Unit tests: location_repository + bloc | — | ⬜ | — | |

---

### Phase 1.3: Integrasi + Review (Hari 11-14) ⬜

> Dimulai SETELAH Phase 1.2 selesai untuk SEMUA anggota.

| # | Tugas | Siapa | Status | Tanggal Selesai | Catatan |
|---|-------|-------|--------|-----------------|---------|
| I1 | Integration test: QR scan → form → submit → confirm | Semua | ⬜ | — | |
| I2 | Cross-feature test: Auth + Guest + Location terhubung | Semua | ⬜ | — | |
| I3 | Bug fixes dari testing | Semua | ⬜ | — | |
| I4 | `flutter analyze` — pastikan 0 issues | Semua | ⬜ | — | |
| I5 | Sprint 1 demo di device fisik/emulator | Semua | ⬜ | — | |

---

## Sprint 2: Fitur Lanjutan + Polish (Minggu 3-4)

### Phase 2.1: Paralel (Hari 1-7) ⬜

#### 🔧 Hafiz Nur Rizki — Telegram + Settings + Export (5 hari)

| # | Tugas | Concept | Status | Tanggal Selesai | Catatan |
|---|-------|---------|--------|-----------------|---------|
| H11 | Telegram Bot API service (notifikasi ke host via Telegram) | E | ✅ | 2026-07-06 | Reassigned to Ahmad |
| H12 | Screen: `settings_screen.dart` | A | ⬜ | — | |
| H13 | Export service: CSV | G | ⬜ | — | |
| H14 | Contabo Backend API: FCM push + Telegram via ElysiaJS | E | ✅ | 2026-07-06 | Reassigned to Ahmad |
| H15 | Widget tests: login_screen, settings_screen | — | ⬜ | — | |

#### 📱 Ahmad Fauzan — Offline Sync + Multi-location (5 hari)

| # | Tugas | Concept | Status | Tanggal Selesai | Catatan |
|---|-------|---------|--------|-----------------|---------|
| A11 | Offline sync queue: pending writes → sync saat online | F | ✅ | 2026-07-06 | |
| A12 | `connectivity_plus` integration | G | ✅ | 2026-07-06 | |
| A13 | Multi-location support | D | ✅ | 2026-07-06 | |
| A14 | Shared widgets: `stat_card.dart`, `search_bar.dart`, `filter_chips.dart` | A | ✅ | 2026-07-06 | |
| A15 | Widget tests: guest_form, confirmation | — | ✅ | 2026-07-06 | |

#### 🎨 Annur Syahrin Aisyah — Chart + Dark Mode + Polish (5 hari)

| # | Tugas | Concept | Status | Tanggal Selesai | Catatan |
|---|-------|---------|--------|-----------------|---------|
| N11 | fl_chart bar chart 7 hari terakhir | G | ⬜ | — | |
| N12 | StreamBuilder: real-time Firestore updates | C | ⬜ | — | |
| N13 | FutureBuilder: QR + settings + export | C | ⬜ | — | |
| N14 | Dark mode implementation | A | ⬜ | — | |
| N15 | Widget tests: dashboard, QR, scan | — | ⬜ | — | |

---

### Phase 2.2: Final Integration + UAT (Hari 8-10) ⬜

| # | Tugas | Siapa | Status | Tanggal Selesai | Catatan |
|---|-------|-------|--------|-----------------|---------|
| F1 | End-to-end flow: Login → Dashboard → Guest List → QR → Scan → Form → Submit → Confirm → Check-out | Semua | ⬜ | — | |
| F2 | Offline mode test: matikan internet → submit → nyalakan → sync | Semua | ⬜ | — | |
| F3 | Performance check: `flutter analyze` 0 issues | Semua | ⬜ | — | |
| F4 | UAT dengan physical device | Semua | ⬜ | — | |
| F5 | Bug fixes final | Semua | ⬜ | — | |
| F6 | Demo preparation | Semua | ⬜ | — | |

---

## Keterangan Status

| Simbol | Arti |
|--------|------|
| ⬜ | Belum dikerjakan |
| 🔄 | Sedang dikerjakan |
| ✅ | Selesai |
| ❌ | Blocked / ada masalah |
| ⏸️ | Ditunda |

---

## Cara Update

1. Saat mulai mengerjakan tugas: ubah ⬜ → 🔄
2. Saat selesai: ubah 🔄 → ✅ + isi tanggal selesai
3. Saat ada masalah: ubah ke ❌ + isi catatan
4. Update "Terakhir diperbarui" di atas
5. Update "Ringkasan Progress" setelah mengubah status

---

## Concept Coverage Tracker

Pastikan semua concept tertulis di AGENTS.md tercakup:

| Concept | Tercakup? | Oleh | Tugas |
|---------|-----------|------|-------|
| A. Flutter Widgets | ⬜ | HN, AF, SA | H5, H12, A6-A9, N6-N9, A14, N14 |
| B. ListView.builder | ⬜ | AF, SA | A9, N9 |
| C. FutureBuilder/StreamBuilder | ⬜ | SA | N12, N13 |
| D. BLoC | ⬜ | HN, AF, SA | H4, H8, A5, N5, A13 |
| E. API + BLoC | ⬜ | HN, AF, SA | H2, H3, H7, H11, H14, A2, A3, N2, N3 |
| F. Local Storage | ⬜ | HN, AF, SA | H10, A4, A11, N4 |
| G. Popular Libraries | ⬜ | AF, SA | A12, N6, N7, N8, H13, N11 |
