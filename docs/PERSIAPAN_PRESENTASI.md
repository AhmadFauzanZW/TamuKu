# Persiapan Presentasi TamuKu — Panduan Lengkap

> Dokumen ini disusun untuk presentasi lisan ke dosen yang **banyak bertanya soal kode**:
> library apa yang dipakai & kenapa dibanding alternatif, logika fungsi, dan alasan desain.
> Ditulis dalam Bahasa Indonesia, gaya mudah dipahami. Mencakup **SEMUA bagian** proyek,
> bukan cuma bagian Hafiz.

**Aturan emas saat ditanya:** jawab dengan pola **"APA fungsinya → KENAPA dipilih → ALTERNATIFNYA apa & kenapa nggak".** Kalau nggak tahu, jujur: "bagian itu dikerjakan tim lain, tapi konsepnya begini…". Jangan mengarang.

---

## DAFTAR ISI
1. [Gambaran Proyek & Arsitektur](#1-gambaran-proyek--arsitektur)
2. [Peta Navigasi UI + Klarifikasi Scan & Foto](#2-peta-navigasi-ui--klarifikasi-scan--foto)
3. [Tech Stack & Alasan Tiap Library](#3-tech-stack--alasan-tiap-library)
4. [Konsep Kunci Lintas Fitur](#4-konsep-kunci-lintas-fitur)
5. [BAGIAN HAFIZ: Auth, Notifikasi, Settings, Export](#5-bagian-hafiz)
6. [Bagian Lain: Guest, Dashboard/QR, Web Admin, Backend](#6-bagian-lain)
7. [Bank Pertanyaan Jebakan + Jawaban](#7-bank-pertanyaan-jebakan--jawaban)
8. [Daftar "Ranjau" (Hal Jujur yang Harus Diwaspadai)](#8-daftar-ranjau)
9. [Cheat Sheet: Kalimat Pembuka & Penutup](#9-cheat-sheet)

---

## 1. Gambaran Proyek & Arsitektur

**TamuKu = aplikasi Buku Tamu Digital** (bukan aplikasi absensi, bukan pengenalan wajah).
Tamu datang ke suatu lokasi → mengisi buku tamu digital → admin memantau.

Proyek ini punya **3 komponen**:

| Komponen | Teknologi | Peran |
|----------|-----------|-------|
| **App Mobile** (`lib/`) | Flutter + Dart | App **ADMIN**: dashboard, daftar tamu, generate QR, settings, login |
| **Web Admin** (`admin-web/`) | React 19 + Vite + TypeScript | Panel admin di browser: kelola Host, Lokasi, lihat tamu |
| **Backend** (`backend/`) | ElysiaJS + Bun + TypeScript | API: notifikasi Telegram/FCM, upload foto S3, export Excel, buat akun |
| **Form Tamu Web** (`backend/web/guest/index.html`) | HTML/JS statis | Halaman yang **dibuka tamu** setelah scan QR: isi data + foto |

**Pola arsitektur (app mobile):** **Clean Architecture + BLoC**

```
UI (Screen)  →  BLoC (Event → State)  →  Repository (kontrak)  →  DataSource (Remote Firebase + Local Hive)
   presentation                              domain                            data
```

Tiap fitur (auth, guest, location, notification) dibagi jadi 3 folder: `data/`, `domain/`, `presentation/`.

**Kenapa Clean Architecture?** Supaya tiap lapisan punya satu tugas jelas, mudah dites, dan
kalau backend berganti (misal Firebase → Supabase) cuma lapisan `data/` yang berubah — UI & logika tetap.

---

## 2. Peta Navigasi UI + Klarifikasi Scan & Foto

### Alur navigasi app mobile (yang BENAR-BENAR bisa diklik)
```
LoginScreen
   └─(login sukses)→ DashboardScreen
                        ├─→ QrGeneratorScreen   (tombol "QR Code")
                        ├─→ SettingsScreen       (ikon gear)
                        └─→ GuestListScreen       (tombol "Daftar Tamu")
                                └─→ CheckoutScreen (tap salah satu tamu)
```

### ⚠️ KLARIFIKASI PENTING: di mana "scan" dan "foto opsional"?

**Fitur SCAN QR** (`scan_screen.dart`): ADA di kode & terdaftar route `/scan`, **tapi TIDAK ada tombol
yang membukanya** di app admin. Ini kode legacy/orphan dari desain lama.
- Di desain sekarang: admin generate QR (QR Generator), QR berisi **URL web**
  (`https://tamuku-api.chronaxis.site/guest?loc=<locationId>`, `qr_generator_screen.dart:233`).
  Tamu scan QR pakai **kamera HP biasa** → buka **form tamu web**.

**FOTO OPSIONAL** ada di 2 tempat:
1. `guest_form_screen.dart:244` (`PhotoPickerSection`) di app Flutter — tapi layar ini cuma reachable
   dari ScanScreen yang tak reachable → praktis tidak tampil.
2. **Form tamu WEB** (`backend/web/guest/index.html:534-657`) — **INI yang dipakai**: ada camera modal,
   tombol shutter, flip kamera. Tamu ambil foto di browser.

**Jawaban aman kalau ditanya:** *"App Flutter ini adalah app admin. Alur tamu (scan QR + isi form + foto)
dilakukan lewat form web yang dibuka dengan scan QR memakai kamera HP biasa. Layar scan di dalam app
masih ada di kode sebagai sisa desain awal, tapi alur produksinya lewat web."*

**Foto itu untuk apa?** Dokumentasi kunjungan (bukti tamu datang). **BUKAN** face recognition —
tidak ada algoritma deteksi/pencocokan wajah di mana pun.

---

## 3. Tech Stack & Alasan Tiap Library

### App Mobile (`pubspec.yaml`)

| Library | Fungsi | Kenapa ini (vs alternatif) |
|---------|--------|----------------------------|
| **flutter_bloc** `^9.1.1` | State management (Bloc & Cubit) | Memisah UI dari logika, bisa dites. vs `setState`: nggak bisa share state & nggak testable. vs Provider: BLoC memberi pola Event→State terstruktur. vs Riverpod: BLoC lebih eksplisit soal transisi state & jadi standar proyek. |
| **equatable** `^2.0.5` | Bandingkan objek by-value (`==`) | BLoC rebuild UI cuma kalau state benar-benar beda. Tanpa ini, objek dibanding by-reference → rebuild sia-sia. Hemat boilerplate `==`/`hashCode`. |
| **firebase_auth** `^6.5.4` | Login email/password | Bikin auth sendiri = urus hashing, reset password, token — mahal & rawan bug. Firebase gratis, aman, teruji. |
| **cloud_firestore** `^6.6.0` | Database realtime (tamu, lokasi) | `snapshots()` = realtime stream tanpa polling. Serverless. |
| **firebase_messaging** `^16.4.1` | Push notification (FCM) | Push gratis lintas platform. vs OneSignal: FCM native ke Firebase. |
| **hive** / **hive_flutter** | Cache lokal (offline) | NoSQL key-value cepat (pure Dart). vs SharedPreferences: Hive untuk data terstruktur/banyak. vs sqflite: nggak perlu SQL untuk key-value. |
| **shared_preferences** `^2.3.4` | Simpan setting kecil (dark mode, locationId) | Pas untuk nilai primitif ringan (bool/string). Nggak perlu buka box. |
| **get_it** `^9.2.1` | Dependency Injection (service locator) | Rakit objek di satu tempat, gampang di-mock saat test. vs Provider: get_it bebas `BuildContext`, bisa dipakai di luar widget tree. |
| **fpdart** `^1.1.1` | `Either<Failure,T>` error handling | Error jadi bagian tipe kembalian → wajib ditangani. Dipakai di fitur Guest & Location. |
| **mobile_scanner** `^7.2.0` | Baca QR pakai kamera | Berbasis MLKit native (cepat, akurat), aktif dirawat. vs `qr_code_scanner`: sudah deprecated. |
| **qr_flutter** `^4.1.0` | Generate & render QR | Pure-Dart, bisa styling + hasilkan raster untuk PDF. |
| **fl_chart** `^1.2.0` | Bar chart di dashboard | Chart 100% Flutter (Canvas), customizable, animasi bawaan. vs `charts_flutter`: discontinued. vs Syncfusion: berat & berlisensi. |
| **image_picker** `^1.1.2` | Ambil foto kamera/galeri | Plugin resmi Flutter, punya resize/kompres bawaan. |
| **cached_network_image** `^3.4.1` | Tampilkan + cache foto dari S3 | Hindari download ulang gambar. |
| **connectivity_plus** `^7.2.0` | Deteksi online/offline | Dasar keputusan offline-first + trigger sync. |
| **http** `^1.2.2` | Panggil API backend | Ringan, resmi Dart. vs `dio`: dio lebih berat, nggak perlu di sini. |
| **share_plus** `^13.2.0` | Buka share sheet (kirim CSV/Excel/QR) | Buka menu share native OS. |
| **pdf** `^3.1.7` + **printing** `^5.12.0` | Buat & cetak PDF QR | `pdf` bikin dokumen programatik, `printing` buka dialog cetak (penulis sama). |
| **intl** `^0.20.3` | Format tanggal locale `id_ID` | Format tanggal Indonesia yang benar. |
| **excel** `^4.0.6` | (Terdaftar, generation kini di backend) | Lihat "Ranjau" — Excel dibuat di backend pakai ExcelJS. |
| **google_fonts** `^8.1.0` | (Terdaftar, belum dipakai) | Lihat "Ranjau" — teks pakai font sistem. |
| **bloc_test** + **mocktail** (dev) | Testing BLoC + mocking | mocktail tanpa codegen (beda dari mockito). |

### Backend (`backend/package.json`)
- **elysia** (+ Bun runtime): framework web TypeScript-first, cepat, validasi bawaan. Bun jalankan TS
  tanpa build step. vs Express/Node: lebih cepat & footprint kecil (cocok VPS murah).
- **firebase-admin**: kirim FCM + buat akun Auth dengan privilege admin (bypass rules).
- **minio**: SDK S3-compatible untuk Contabo Object Storage (presigned URL).
- **exceljs**: generate Excel bergaya (warna, border, auto-width).

### Web Admin (`admin-web/package.json`)
- **react 19** + **vite 8**: UI + build tool cepat (HMR).
- **react-router-dom v7**: routing SPA.
- **firebase**: Auth + Firestore langsung dari browser.
- **tailwindcss v4**: styling utility-first.
- **Catatan:** TanStack/react-query **tidak dipakai** — fetch manual pakai `useEffect`+`useState`.

---

## 4. Konsep Kunci Lintas Fitur

Ini konsep yang **paling sering ditanya** dan berlaku di banyak file. Kuasai ini dulu.

### 4.1 Clean Architecture (3 lapisan)
- **domain/** = aturan bisnis murni: `Entity` (objek data) + `Repository` (kontrak abstrak/interface).
  Bebas dari Firebase/Hive. Kalau backend ganti, lapisan ini **tidak berubah**.
- **data/** = implementasi konkret: `DataSource` (Remote=Firebase, Local=Hive) + `RepositoryImpl`.
  Di sinilah Firebase & Hive "hidup".
- **presentation/** = UI (`Screen`) + state management (`BLoC`).

**Dependency Rule:** lapisan luar tahu lapisan dalam, tidak sebaliknya. BLoC hanya tahu kontrak
`Repository` (abstrak), bukan implementasinya → gampang di-mock saat test.

### 4.2 BLoC vs Cubit
- **Bloc** (Event-driven): UI `add(Event)` → handler `on<Event>` → `emit(State)`. Untuk logika kompleks,
  banyak aksi, atau butuh jejak event. Dipakai: `AuthBloc`, `GuestBloc`, `LocationBloc`, `NotificationBloc`.
- **Cubit** (versi ringkas): panggil method langsung → `emit(State)`. Tanpa kelas Event. Untuk state
  sederhana. Dipakai: `SettingsCubit` (cuma toggle bool), `ScanCubit` (cuma flag "sudah scan").
- **Kalimat jawaban:** *"Cubit adalah versi Bloc yang disederhanakan. Kalau aksinya cuma satu-dua & simpel,
  pakai Cubit biar nggak boilerplate. Kalau kompleks & butuh audit event, pakai Bloc."*

### 4.3 Dependency Injection (get_it) — `injection_container.dart`
- `registerLazySingleton` = satu instance, dibuat saat pertama diminta, lalu di-cache. Untuk Repository,
  DataSource, Service (objek yang di-share).
- `registerFactory` = instance **baru tiap kali** dipanggil. Untuk **semua BLoC** — karena BLoC di-`close()`
  saat layar ditutup; kalau singleton, BLoC yang sudah close dipakai ulang → **crash**.
- `registerSingleton` = eager (dibuat saat registrasi). Tidak dipakai (proyek pilih lazy biar startup ringan).
- **Graf dependensi:** `AuthBloc → AuthRepository → (RemoteDataSource + LocalDataSource) → Firebase/Hive`.
  get_it merakit otomatis: `getIt<AuthBloc>()` sudah lengkap dengan semua dependensinya.

### 4.4 Offline-First
- **READ:** kalau online → ambil Firestore → cache ke Hive → tampilkan. Kalau gagal/offline → baca cache.
- **WRITE:** **simpan LOKAL dulu** (UI instan) → kalau online kirim Firestore; kalau gagal/offline →
  masuk **Sync Queue** (antrian). Saat online lagi, queue di-"replay". (Detail di bagian Guest.)

### 4.5 Either vs Throw (dua gaya error handling di proyek ini)
- **Guest & Location** pakai `Either<Failure,T>` (fpdart): `Left`=gagal, `Right`=sukses, ditangani `.fold()`.
  Alasan: banyak jenis kegagalan (server vs cache kosong vs offline) yang harus dibedakan.
- **Auth & Notification** pakai **throw exception** + `try/catch`. Alasan: alurnya lebih linear
  (berhasil/gagal), lebih ringkas.
- **Kalau ditanya kenapa beda:** jujur — konsekuensi pembagian tugas antar developer, tapi keduanya
  sah dan tetap satu payung `Failure`.

---

## 5. BAGIAN HAFIZ

> Ini bagian yang HARUS kamu kuasai paling dalam. Empat fitur: Auth, Notifikasi, Settings, Export.

### 5.1 AUTH (Login email/password)

**File utama & perannya:**
- `domain/entities/user_entity.dart` — objek user immutable (`extends Equatable`).
- `domain/repositories/auth_repository.dart` — kontrak abstrak (signIn, signOut, authStateChanges).
- `data/datasources/auth_remote_datasource.dart` — komunikasi Firebase Auth + **terjemahkan error ke Bahasa Indonesia** (`_messageForCode`).
- `data/datasources/auth_local_datasource.dart` — cache user ke Hive (JSON) untuk offline.
- `data/repositories/auth_repository_impl.dart` — orkestrasi remote+local, ubah Map→Entity.
- `core/utils/user_mapper.dart` — ubah Firebase `User` → Map (satu sumber, hindari duplikasi).
- `presentation/bloc/auth_bloc.dart` — logika login/logout + restore sesi.
- `presentation/screens/login_screen.dart` — UI.

**Alur login end-to-end (hafalkan ini):**
1. User tap "Masuk" → `_onLogin()` → validasi form → tutup keyboard → kirim event `LoginRequested(email, password)`.
2. `AuthBloc._onLoginRequested` → `emit(AuthLoading())` → UI jadi spinner.
3. `repository.signIn()` → `remote.signIn()` → `FirebaseAuth.signInWithEmailAndPassword()`.
4. Sukses → `UserMapper.toMap(user)` → **cache ke Hive** → ubah ke `UserEntity`.
5. BLoC ambil & simpan `locationId` ke SharedPreferences **SEBELUM** emit (biar dashboard bisa baca).
6. `emit(Authenticated(user))` → `BlocConsumer.listener` → `Navigator.pushReplacementNamed(dashboard)`.
7. Kalau gagal → `_messageForCode` ubah kode Firebase ke pesan Indonesia → `emit(AuthError)` → SnackBar merah.

**Restore sesi (buka app lagi):** konstruktor `AuthBloc` panggil `_tryRestoreSession` → baca cache Hive →
kalau ada, langsung `Authenticated` → **user masuk tanpa login ulang, bahkan offline**.

**Poin kode yang khas:**
- `LoginScreen` = `StatelessWidget` (cuma bungkus `BlocProvider`), `LoginView` = `StatefulWidget`
  (hanya untuk lifecycle `TextEditingController` + `ValueNotifier`, **bukan** untuk logika).
- Toggle lihat password pakai `ValueNotifier<bool>` + `ValueListenableBuilder` → **cuma field password
  yang rebuild**, bukan seluruh layar (lebih efisien dari `setState`).
- Tombol **Google Sign-In di-disable** ("Segera hadir") — fitur fase berikutnya, sengaja belum aktif.

### 5.2 NOTIFIKASI (FCM + Telegram)

**File:** `notification/data/repositories/notification_repository_impl.dart` + bloc.

**FCM (push notification) — 3 langkah:**
1. `requestPermission()` — minta izin OS (wajib iOS & Android 13+).
2. `getToken()` — dapat token unik perangkat (backend pakai ini untuk nembak notif ke 1 device).
3. `subscribeToTopic(topic)` — daftar ke topik broadcast (mis. `location-loc1`); backend kirim ke nama
   topik, semua device pelanggan terima — **broadcast tanpa kelola daftar token**.

**Telegram — alur pesan:**
1. `buildTelegramMessage()` (static, pure) — susun pesan HTML (`<b>`+emoji), **escape** karakter `<`,`>`,`&` dulu.
2. `sendTelegramMessage()` → `ApiClient` POST ke backend `/api/notifications/telegram` (header `x-api-key`).
3. Backend POST ke `api.telegram.org/bot<TOKEN>/sendMessage` dengan `parse_mode:'HTML'`.

**Kenapa Telegram, bukan WhatsApp API?** Telegram Bot **gratis**, cukup token dari @BotFather,
**tanpa verifikasi bisnis Meta**. WhatsApp Business API berbayar + butuh approval template + verifikasi Meta.

**Kenapa lewat backend, bukan langsung dari app?** Bot token itu **rahasia**. Kalau app panggil Telegram
langsung, token tertanam di APK → bisa diekstrak & disalahgunakan. Backend jadi proxy, token aman di server.

**Kenapa escape HTML?** Karena `parse_mode:'HTML'` aktif. Nama tamu "Budi `<b>`" tanpa escape bisa
merusak/menyuntik tag HTML. Escape ubah jadi `&lt;` dsb → cegah **injection**.

### 5.3 SETTINGS (dark mode, notif, logout)

**File:** `location/presentation/screens/settings_screen.dart` + `shared/blocs/settings/settings_cubit.dart`.

**Isi layar:** Profil lokasi (dari Firestore via `FutureBuilder`), toggle Notifikasi, toggle Dark Mode,
tombol Export, tombol Logout (dengan dialog konfirmasi).

**Rantai Dark Mode (hafalkan — sering ditanya):**
1. Geser switch → `cubit.setDarkMode(true)`.
2. `SettingsCubit` tulis ke **SharedPreferences** (`keyDarkMode`) lalu `emit(state.copyWith(darkMode: true))`.
3. `SettingsCubit` di-provide **di root** (`app.dart:60`). `MaterialApp` dibungkus `BlocBuilder<SettingsCubit>`.
4. `emit` → `MaterialApp` rebuild → `themeMode: darkMode ? ThemeMode.dark : ThemeMode.light` → **seluruh app ganti tema**.
5. **Bertahan setelah restart:** konstruktor `SettingsCubit` baca `prefs.getBool(keyDarkMode) ?? false`.

**Kenapa Cubit (bukan Bloc)?** Cuma 2 toggle bool → bikin Event class = boilerplate berlebih.
**Kenapa SharedPreferences (bukan Hive)?** Cuma 2 nilai primitif → SharedPreferences pas; Hive untuk data terstruktur.

**Logout:** ambil `AuthBloc` **sebelum** await (hindari "context across async gap") → `AlertDialog` konfirmasi
→ kalau OK, `authBloc.add(LogoutRequested())` → hapus `locationId`, `signOut()`, `emit(AuthInitial())`.

### 5.4 EXPORT (CSV di client, Excel di backend)

**CSV** (`csv_export_service.dart`) — dibuat **100% di client**:
- `buildCsv()` (pure): susun header + baris. Tiap field lewat `_escape()`.
- `_escape()` ikut **RFC 4180**: field yang ada koma/kutip/newline dibungkus `"..."`, kutip di dalam
  digandakan (`"`→`""`). Ini yang bikin nama **"Budi, S.Kom"** nggak pecah jadi 2 kolom.
- `exportAndShare()`: tulis file UTF-8 ke temp → buka share sheet via `share_plus`.

**Excel** (`excel_export_service.dart`) — dibuat **di backend** (ExcelJS):
- Client ubah data → JSON → POST ke backend `/api/export/excel` → backend bikin `.xlsx` bergaya
  (warna hijau, border, zebra, auto-width) → kembalikan path → client share.

**Kenapa pisah buildCsv & exportAndShare?** `buildCsv` pure (bisa dites tanpa filesystem),
`exportAndShare` yang urus I/O. Separation of concerns.

**Kenapa CSV DAN Excel?** CSV = ringan, universal, offline. Excel = rapi & profesional untuk laporan.

---

## 6. Bagian Lain

> Kuasai secukupnya biar bisa jawab kalau ditanya nyerempet. Nggak sedetail bagian sendiri.

### 6.1 GUEST (buku tamu tamu) — oleh Mas Fauzan

**Alur check-in:** tamu scan QR → buka form → isi data + foto opsional → submit → upload foto ke S3 (opsional)
→ `CheckInRequested` → repository **simpan lokal dulu** → kalau online kirim Firestore, kalau gagal masuk
**Sync Queue** → halaman konfirmasi → notif Telegram ke host (fire-and-forget).

**Pembeda utama dari bagian Hafiz:**
- Pakai **`Either<Failure,T>`** (fpdart), bukan throw. BLoC handle dengan `.fold()`.
- Punya **Sync Queue** (`sync_queue_service.dart`): operasi tulis offline disimpan di Hive box `sync_queue`,
  saat online kembali (`app.dart` dengar `connectivity`) di-replay terurut `createdAt`, yang sukses dihapus,
  yang gagal di-retry.
- **Dua BLoC di form:** `GuestFormBloc` (state UI: foto+keperluan) & `GuestBloc` (submit ke repository).
- Cache Hive punya **index sekunder** `_locationIndex` (locationId→[guestId]) biar filter per lokasi cepat.

**QR scan (`scan_screen.dart`):** `mobile_scanner`, dukung 2 format QR (URL & legacy `locationId|hostPhone`).
Guard anti-dobel: `ScanCubit.hasScanned`. **(Ingat: layar ini orphan, alur nyata lewat web.)**

**Foto:** `image_picker` → resize (maxWidth 800, quality 80) → upload ke Contabo S3 via **presigned URL**.
Non-blocking (gagal upload → check-in tetap jalan). **Foto dokumentasi, bukan face recognition.**

### 6.2 DASHBOARD, DAFTAR TAMU, QR GENERATOR

**Dashboard** (`dashboard_screen.dart`): pakai **`StreamBuilder`** langsung ke Firestore (bukan BLoC —
pengecualian sadar demi simpel). Statistik: "Tamu Hari Ini" (`docs.length`), "Sedang Berkunjung"
(status `checked_in`). Query: filter `locationId` **lalu** `checkInTime >= todayStart` (urutan penting
untuk index komposit Firestore).

**Visit Chart** (`visit_chart.dart`): `BarChart` fl_chart, 7 hari terakhir. `StatelessWidget` yang terima
data; realtime-nya dari `StreamBuilder` dashboard → hitung ulang `_computeDailyCounts` → chart rebuild + animasi 300ms.

**Daftar Tamu** (`guest_list_screen.dart`): `ListView.builder` (lazy, hemat memori), pakai `GuestBloc`.
Search pakai **debounce 300ms** (`Timer`), filter status (ChoiceChip), sort (PopupMenu) — **semua lokal
di memori** (`_applyFilterAndSort`), stream Firestore cuma jalan sekali.

**QR Generator** (`qr_generator_screen.dart`): render QR pakai `QrImageView` (qr_flutter). QR encode
**URL web** `guestWebUrl?loc=<locationId>` (hostPhone TIDAK di QR — diambil dari dokumen lokasi).
Share pakai `share_plus`. Print: QR di-raster ulang via `QrPainter.toImageData()` → tanam ke PDF
(`pdf`) → `Printing.layoutPdf()`. Level koreksi error **H** untuk print (tahan rusak).

**Kenapa QR di layar & di PDF beda cara?** `QrImageView` itu widget Flutter (cuma untuk layar).
Package `pdf` punya widget-tree sendiri (`pw.*`), nggak terima widget Flutter → QR di-raster jadi gambar dulu.

### 6.3 WEB ADMIN (React) — oleh tim web

React 19 + Vite + `react-router-dom v7`. Login pakai Firebase Auth (`useAuth.ts`).
**Role-based access** (`lib/roles.ts`): `super_admin` | `admin` | `host`. `AuthGuard` (`App.tsx`) 3 lapis cek:
belum login → `/login`; login tapi bukan host terdaftar → "Akun Tidak Terdaftar"; role bukan admin → "Akses Ditolak".
Role juga batasi data (super_admin lihat semua, host cuma miliknya). Halaman: Dashboard, Locations, Hosts,
Guests (ada smart date filter harian/mingguan/bulanan), Settings (ganti password wajib re-autentikasi).
Web admin baca/tulis Firestore **langsung dari browser**; backend cuma untuk operasi ber-secret.

### 6.4 BACKEND (ElysiaJS + Bun) — oleh Ahmad

**Kenapa ada backend terpisah (bukan Firebase langsung dari client)?** 3 alasan:
1. **Sembunyikan secret** (bot token Telegram, S3 keys, service account) — nggak boleh ada di client.
2. **Hindari Firebase Cloud Functions berbayar (Blaze)** — jalankan Admin SDK sendiri di VPS murah.
3. **Operasi privilege tinggi** (buat akun host via Admin SDK yang bypass Firestore rules).

**Endpoint:** `/api/notifications/telegram` & `/send` (FCM), `/api/guests/notify` (FCM+Telegram sekaligus,
fault-tolerant), `/api/export/excel`, `/api/upload/url` & `/api/guests/upload` (presigned S3 URL),
`/api/hosts` (buat akun), `/health`.

**Middleware `apiKeyGuard`:** cek header `x-api-key` == `config.apiKey` (hook `onBeforeHandle`; kalau
return sesuatu → request di-stop). Endpoint upload tamu sengaja **di luar** guard (web tamu publik tanpa key).

**Presigned URL pattern:** client minta URL bertanda tangan ke backend → upload/baca file **langsung ke S3**.
File tidak lewat backend → hemat bandwidth.

**Kenapa Bun/Elysia (bukan Express)?** Bun jalankan TypeScript native tanpa build, lebih cepat, footprint kecil.
Elysia validasi request + type inference otomatis tanpa library tambahan.

**Kenapa Contabo S3 (bukan Firebase Storage)?** Hindari paket Blaze berbayar. Contabo S3-compatible &
flat murah; kode pakai SDK `minio` yang portable (MinIO/AWS/Contabo).

**Deploy:** Docker + docker-compose (2 container: backend port 3000, admin-web Nginx port 8080).
Backend Dockerfile jalankan `bun src/index.ts` langsung. Admin-web multi-stage (build Vite → serve Nginx).

---

## 7. Bank Pertanyaan Jebakan + Jawaban

### Umum / Arsitektur
**Q: Kenapa pakai BLoC, bukan setState?**
A: setState nyampur logika & UI dalam satu widget, nggak bisa dites terpisah, nggak scalable. BLoC pisahkan
logika ke kelas sendiri yang bisa di-unit-test tanpa UI, dan state bisa di-share antar widget.

**Q: Kenapa Clean Architecture, ribet amat?**
A: Tiap lapisan satu tugas → mudah dites & dirawat. Kalau backend ganti, cuma lapisan data yang berubah.
UI cuma tahu kontrak abstrak, bukan Firebase → bisa di-mock.

**Q: Bedanya Bloc dan Cubit, kapan pakai mana?**
A: Bloc event-driven (add Event → on<Event> → emit), untuk logika kompleks. Cubit panggil method langsung,
untuk state simpel. Contoh: AuthBloc pakai Bloc, SettingsCubit pakai Cubit (cuma toggle).

**Q: Kenapa BLoC di-register factory, bukan singleton?**
A: BLoC di-`close()` saat layar ditutup. Kalau singleton, instance yang sudah close dipakai ulang → crash
"Cannot add events after close". Factory bikin instance baru tiap kali.

**Q: Kenapa get_it, bukan Provider / passing manual?**
A: get_it bebas BuildContext (bisa dipakai di main, di dalam BLoC), pusatkan pembuatan objek,
gampang di-mock saat test. Passing manual → "prop drilling" konstruktor berlapis.

**Q: Kenapa Equatable?**
A: BLoC rebuild UI cuma kalau state berubah (`!=`). Tanpa Equatable, objek dibanding by-reference →
selalu dianggap beda → rebuild sia-sia. Equatable bandingkan by-value.

### Auth
**Q: Apa yang terjadi kalau login saat offline?**
A: Login **baru** offline → gagal (`network-request-failed` → pesan "Tidak ada koneksi"). Tapi kalau
**pernah login**, buka app offline → sesi di-restore dari cache Hive → tetap masuk.

**Q: Kenapa auth pakai throw, tapi guest pakai Either?**
A: Auth alurnya linear (berhasil/gagal login) → try/catch cukup & ringkas. Guest banyak jenis kegagalan
(server/cache/offline) yang harus dibedakan → Either lebih eksplisit. (Jujur: juga karena beda developer.)

**Q: Kenapa toggle password pakai ValueNotifier, bukan setState?**
A: setState rebuild seluruh layar cuma untuk balik ikon mata. ValueNotifier + ValueListenableBuilder
cuma rebuild field password → lebih efisien.

### Notifikasi
**Q: Kenapa Telegram, bukan WhatsApp?**
A: Telegram Bot gratis, token dari @BotFather, tanpa verifikasi Meta. WhatsApp API berbayar + butuh approval.

**Q: Kenapa notif dikirim lewat backend?**
A: Bot token rahasia. Kalau dari app langsung, token tertanam di APK → bisa dicuri. Backend jadi proxy.

**Q: Apa itu topic subscription FCM?**
A: Device daftar ke "topik", backend kirim ke nama topik, semua pelanggan terima. Broadcast tanpa kelola token.

### Export
**Q: Gimana handle nama yang ada koma di CSV?**
A: `_escape()` (RFC 4180): field dengan koma/kutip/newline dibungkus tanda kutip ganda, kutip di dalam
digandakan. Jadi "Budi, S.Kom" jadi satu sel `"Budi, S.Kom"`, nggak pecah.

**Q: Kenapa Excel dibuat di backend?**
A: Styling kaya (warna, border, zebra, auto-width) lebih matang di ExcelJS, kurangi beban di HP.

### Guest / Offline
**Q: Gimana check-in bisa jalan saat offline?**
A: Tulis ke Hive lokal dulu (UI langsung sukses), operasi masuk Sync Queue. Saat online, queue di-replay ke Firestore.

**Q: Gimana cegah check-in dobel?**
A: Guard UI: `ScanCubit.hasScanned` kunci setelah scan pertama, flag `_submitting` cegah double-tap.
(Jujur: belum ada dedup di server — ini area improvement.)

### Dashboard / QR
**Q: Kenapa ListView.builder, bukan ListView?**
A: ListView biasa bangun semua item sekaligus (boros). Builder lazy — cuma bangun yang terlihat di layar.

**Q: Gimana chart update realtime?**
A: `StreamBuilder` dengar `Firestore.snapshots()` → data baru → hitung ulang → chart rebuild + animasi.

**Q: Kenapa search pakai debounce?**
A: Tanpa debounce, tiap ketikan trigger filter. Debounce 300ms tunggu user selesai ngetik → satu filter saja.

### Backend / Web
**Q: Kenapa backend terpisah, nggak Firebase langsung?**
A: Sembunyikan secret, hindari Cloud Functions berbayar, operasi privilege tinggi (Admin SDK).

**Q: Kenapa S3 Contabo, bukan Firebase Storage?**
A: Hindari paket Blaze berbayar. Contabo S3-compatible & murah; kode pakai SDK minio yang portable.

**Q: Gimana role-based auth bekerja?**
A: Role disimpan di dokumen Firestore `hosts/{uid}`. AuthGuard blokir non-admin, query data dibatasi per role.

---

## 8. Daftar "Ranjau"

> Hal-hal yang **kalau nggak kamu tahu bisa bikin kaget**. Lebih baik kamu yang sebut duluan sebagai
> "future improvement" daripada dikuliti dosen. Kejujuran = nilai plus.

1. **Test `settings_screen_test.dart:64` GAGAL.** Test cari teks "Export CSV" tapi tombol sekarang
   "Export Excel". Kalau dosen jalanin `flutter test`, satu test ini merah.
   → *Jawaban:* "Fitur export berubah dari CSV ke Excel, test-nya belum di-update. Perbaikannya satu baris."
   (Bisa aku benerin kalau kamu mau.)

2. **`firebase_options.dart` nggak ada di repo** (di-gitignore). `flutter run`/build penuh butuh
   `flutterfire configure` dulu. → App nggak bisa langsung di-`run` di komputer baru tanpa setup Firebase.

3. **Package `excel` terdaftar tapi nggak dipakai** di kode Flutter — Excel dibuat di backend (ExcelJS).
   → *Jawaban:* "Sisa implementasi lama; Excel sekarang server-side."

4. **Package `google_fonts` terdaftar tapi belum dipakai** — teks pakai font sistem.
   → *Jawaban:* "Didaftarkan untuk kesiapan branding, belum dipanggil."

5. **Layar Scan / GuestForm / Confirmation di Flutter = orphan** (nggak reachable dari navigasi).
   Alur tamu nyata lewat form web. → Sudah dijelaskan di bagian 2.

6. **Tombol Google Sign-In di-disable** ("Segera hadir") — sengaja, fitur fase 2.

7. **Belum ada dedup check-in di server** — cuma guard UI. → Sebut sebagai future improvement
   (idempotency key / cek nama+telp+waktu).

8. **Kemungkinan orphan Auth user** (`backend hosts.ts`): kalau buat Auth user sukses tapi tulis Firestore
   gagal, user Auth "yatim" tanpa rollback. → Future improvement (transaksi).

9. **`NetworkInfo.isConnected` cuma cek ada interface jaringan, bukan internet beneran** — WiFi tanpa
   internet tetap dianggap online. Untung Sync Queue menangani kasus gagal dengan retry.

10. **`CheckInRequested.props` (Equatable) nggak lengkap** — dua check-in dengan nama+telp+keperluan+lokasi
    sama dianggap identik. Minor.

---

## 9. Cheat Sheet

### Kalimat pembuka (kalau diminta jelasin proyek)
> "TamuKu adalah aplikasi buku tamu digital. Ada 3 komponen: app mobile Flutter untuk admin, web admin
> React untuk kelola data, dan backend ElysiaJS untuk notifikasi & penyimpanan foto. App mobile pakai
> Clean Architecture + BLoC, dengan pola offline-first — data disimpan lokal dulu baru sync ke Firebase.
> Bagian saya: autentikasi, notifikasi Telegram+FCM, pengaturan, dan export data."

### Kalau ditanya fitur & nggak yakin ada di UI
> "Alur tamu — scan QR, isi form, foto — dilakukan lewat form web yang dibuka dengan scan QR pakai
> kamera HP biasa. App Flutter fokus untuk admin: dashboard, daftar tamu, generate QR, dan pengaturan."

### Rumus jawab pertanyaan library
> "[Library X] fungsinya untuk [A]. Kami pilih ini karena [alasan]. Alternatifnya [Y], tapi kami nggak
> pakai karena [kekurangan Y untuk kasus kami]."

### Kalimat penutup
> "Secara keseluruhan, arsitekturnya sengaja memisah presentation, domain, dan data supaya mudah dites
> dan dirawat. Ada beberapa hal yang kami tandai untuk perbaikan ke depan, seperti dedup check-in di
> server dan menyelaraskan test dengan fitur export terbaru."

### 3 konsep yang WAJIB lancar diucapkan
1. **Clean Architecture** — 3 lapisan, dependency rule.
2. **BLoC (Event→State) vs Cubit** — kapan pakai yang mana.
3. **Offline-first** — tulis lokal dulu, sync queue saat online.

---

*Dokumen ini dibuat untuk persiapan presentasi. Baca bagian 4 (Konsep Kunci) & 5 (Bagian Hafiz) paling
teliti, lalu bagian 7 (Bank Pertanyaan). Bagian 8 (Ranjau) dibaca terakhir biar nggak kaget.*
