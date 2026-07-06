# 📘 Penjelasan Lengkap Tugas Hafiz — Auth, Notifikasi, Settings & Export

> Dokumen ini menjelaskan **langkah demi langkah** pengerjaan bagian **Hafiz Nur Rizki**
> (Backend & Integrasi: Auth + Notifikasi + Settings + Export CSV) di aplikasi **TamuKu**.
> Ditulis untuk pemula: kenapa pakai library ini, fungsi tiap kode, dan alasan desainnya.
>
> Sebelum baca ini, sebaiknya pahami dulu apa yang sudah dikerjakan **Ahmad Fauzan**
> (lihat [Bagian 1](#1-apa-yang-sudah-dikerjakan-mas-fauzan-referensi-pola)) karena tugas Hafiz
> **meniru pola yang sama** persis dengan buatan Fauzan.

---

## Daftar Isi
1. [Apa yang sudah dikerjakan Mas Fauzan (referensi pola)](#1-apa-yang-sudah-dikerjakan-mas-fauzan-referensi-pola)
2. [Konsep dasar yang wajib dipahami dulu](#2-konsep-dasar-yang-wajib-dipahami-dulu)
3. [Environment & tools yang dipakai](#3-environment--tools-yang-dipakai)
4. [Fitur Auth (Login) — step by step](#4-fitur-auth-login--step-by-step)
5. [Fitur Notifikasi (FCM + Telegram) — step by step](#5-fitur-notifikasi-fcm--telegram--step-by-step)
6. [Settings Screen + Export CSV — step by step](#6-settings-screen--export-csv--step-by-step)
7. [Menyambungkan semuanya (Dependency Injection)](#7-menyambungkan-semuanya-dependency-injection)
8. [Testing — kenapa & bagaimana](#8-testing--kenapa--bagaimana)
9. [Catatan penting & PR (pekerjaan lanjutan)](#9-catatan-penting--pr-pekerjaan-lanjutan)

---

## 1. Apa yang sudah dikerjakan Mas Fauzan (referensi pola)

Mas Fauzan (Tech Lead) sudah menyelesaikan **fitur Guest (tamu)** secara lengkap. Ini menjadi
**contoh/patokan** untuk semua fitur lain, termasuk punya Hafiz. Yang beliau buat:

| Lapisan | File | Fungsinya |
|--------|------|-----------|
| **Domain** | `guest_entity.dart` | Model data tamu (nama, phone, keperluan, dll) + cara ubah ke/dari Firestore & JSON |
| **Domain** | `guest_repository.dart` | *Kontrak* (abstract class) — daftar fungsi yang harus ada, tanpa isi |
| **Data** | `guest_remote_datasource.dart` | Ngobrol langsung ke **Firestore** (online) |
| **Data** | `guest_local_datasource.dart` | Simpan data di **Hive** (offline) |
| **Data** | `guest_repository_impl.dart` | Otak "offline-first": tulis lokal dulu → sync ke server saat online |
| **Core** | `sync_queue_service.dart` | Antrian tulis yang gagal → diulang saat internet balik |
| **Presentation** | `guest_bloc.dart` + event + state | Logika bisnis (BLoC): terima *Event* → keluarkan *State* |
| **Presentation** | `guest_form_screen.dart`, dll | Tampilan (UI) |
| **Test** | 27 unit test + 27 widget test | Bukti bahwa kode benar-benar jalan |

**Pola/aturan penting yang Fauzan pakai (dan Hafiz ikuti):**
1. **Clean Architecture** → tiap fitur dibagi 3 folder: `data/`, `domain/`, `presentation/`.
2. **Offline-first** → data ditulis ke penyimpanan lokal dulu, baru ke server.
3. **BLoC** untuk semua state (TIDAK boleh `setState`).
4. **Doc comment `///`** di setiap fungsi/kelas publik.
5. Semua teks yang dilihat user **Bahasa Indonesia**; nama variabel/fungsi Bahasa Inggris.
6. **Tidak ada teks "gaib" (hardcoded)** → semua di `app_constants.dart`.
7. Maksimal **300 baris per file**.
8. **Wajib `flutter analyze` 0 error** + ada test.

> **Intinya:** tugas Hafiz = bikin fitur Auth/Notifikasi/Settings dengan struktur & kualitas
> yang **sama persis** seperti fitur Guest-nya Fauzan.

---

## 2. Konsep dasar yang wajib dipahami dulu

Kalau 4 konsep ini paham, sisanya gampang.

### a) Clean Architecture (3 lapisan)
Bayangkan restoran:
- **`domain/`** = *menu & aturan* (apa yang bisa dipesan). Tidak tahu dapurnya seperti apa.
  - `entities/` = bentuk data (contoh: `UserEntity`).
  - `repositories/` = kontrak (abstract class) — "fungsi apa saja yang tersedia".
- **`data/`** = *dapur* (cara masaknya). Implementasi asli.
  - `datasources/` = ambil bahan dari **remote** (Firebase) atau **local** (Hive).
  - `repositories/` = gabungkan remote + local jadi satu (implementasi kontrak domain).
- **`presentation/`** = *pelayan & meja* (yang dilihat pelanggan).
  - `bloc/` = logika (Event → State).
  - `screens/` = tampilan.

**Kenapa dipisah?** Kalau nanti ganti Firebase ke server lain, cukup ubah `data/`. UI & logika
tidak ikut berubah. Ini yang bikin aplikasi mudah dirawat & diuji.

### b) BLoC (Business Logic Component)
BLoC memisahkan **tampilan** dari **logika**. Alurnya:

```
[User klik tombol] → kirim EVENT → BLoC proses → keluarkan STATE → UI berubah
```

Contoh login:
```
User klik "Masuk" → LoginRequested(email, pw) → AuthBloc → AuthLoading → Authenticated / AuthError
```

- **Event** = "apa yang terjadi" (LoginRequested, LogoutRequested).
- **State** = "kondisi sekarang" (AuthLoading, Authenticated, AuthError).
- UI cukup "mendengarkan" State lalu menggambar ulang. **Tidak perlu `setState`.**

### c) Offline-first
Aplikasi harus tetap jalan walau internet mati. Caranya: simpan salinan data di HP (Hive),
lalu sinkron ke server saat online. Untuk Auth, kita **cache data user** supaya sesi login
bisa dipulihkan meski offline.

### d) Dependency Injection (get_it)
Daripada tiap kelas bikin sendiri objek yang dibutuhkan (ribet & susah dites), kita daftarkan
semua objek di **satu tempat** (`injection_container.dart`) lalu tinggal ambil pakai `getIt<...>()`.
Ibarat gudang alat: semua alat disiapkan di gudang, siapa pun tinggal ambil.

---

## 3. Environment & tools yang dipakai

| Tool | Versi | Fungsi |
|------|-------|--------|
| **Flutter SDK** | 3.x (stable) | Framework UI cross-platform (Android + iOS dari 1 kode) |
| **Dart** | 3.x | Bahasa pemrograman Flutter |
| **Firebase Auth** | `firebase_auth ^5.4.1` | Login email/password admin |
| **Firebase Messaging** | `firebase_messaging ^15.2.1` | Ambil token & izin **push notification (FCM)** — gratis |
| **Backend ElysiaJS** | di folder `backend/` | Kirim pesan **Telegram** ke host (pengganti Cloud Functions berbayar) |
| **Hive** | `hive ^2.2.3` | Database lokal (offline) berbentuk key-value |
| **shared_preferences** | `^2.3.4` | Simpan pengaturan kecil (mode gelap) |
| **share_plus** | `^10.1.4` | Buka menu "Bagikan" HP untuk file CSV |
| **path_provider** | `^2.1.5` | Cari lokasi folder sementara untuk simpan file CSV |
| **intl** | `^0.19.0` | Format tanggal ke gaya Indonesia (`6 Jul 2026, 10:00`) |
| **get_it** | `^8.0.2` | Dependency Injection |
| **flutter_bloc** | `^8.1.6` | State management (BLoC/Cubit) |
| **equatable** | `^2.0.5` | Bandingkan objek (biar UI tidak rebuild sia-sia) |
| **http** | `^1.2.2` | Panggil API backend (Telegram/FCM) |
| **mocktail + bloc_test** | dev | Bikin objek palsu untuk testing |

### 🔑 Keputusan spesifikasi penting (hindari Firebase berbayar / paket Blaze)
Firebase punya beberapa fitur yang **butuh paket berbayar (Blaze)**. Untuk MVP gratisan,
kita ganti:

| Fitur Firebase berbayar | Diganti dengan | Alasan |
|-------------------------|----------------|--------|
| **Cloud Functions** | **Backend ElysiaJS di Contabo VPS** | Trigger notifikasi jalan di server sendiri, gratis |
| **Firebase Storage** | **Contabo S3 (MinIO)** | Simpan foto tamu tanpa Blaze |
| ~~WhatsApp API~~ (berbayar/ribet) | **Telegram Bot API** | Gratis, gampang, cukup HTTP request |

Yang **tetap dipakai (gratis, Spark plan):** Firestore (database) & FCM (token push).

---

## 4. Fitur Auth (Login) — step by step

Tujuan: admin bisa **login pakai email + password** ke Firebase. (Login Google **belum**
diaktifkan di fase ini — tombolnya ada tapi menampilkan "Segera hadir". Alasannya: `google_sign_in`
butuh konfigurasi native SHA-1/plist yang belum siap, dan kita fokus yang pasti jalan dulu.)

Struktur file (mengikuti pola Fauzan):
```
features/auth/
├── domain/
│   ├── entities/user_entity.dart          ← bentuk data user
│   └── repositories/auth_repository.dart   ← kontrak
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart     ← Firebase Auth (online)
│   │   └── auth_local_datasource.dart      ← Hive cache (offline)
│   └── repositories/auth_repository_impl.dart ← gabungan online+offline
└── presentation/
    ├── bloc/ (auth_bloc, auth_event, auth_state) ← logika
    └── screens/login_screen.dart            ← tampilan
```

### Langkah 1 — Entity: `user_entity.dart` (sudah ada dari skeleton)
`UserEntity` cuma "bungkus data" user: `uid`, `email`, `name`, `photoUrl`, `role`. Pakai
`Equatable` supaya dua user dengan data sama dianggap sama (mencegah UI rebuild percuma).

### Langkah 2 — Remote DataSource: `auth_remote_datasource.dart`
Ini yang **ngobrol langsung ke Firebase Auth**.

```dart
final credential = await _auth.signInWithEmailAndPassword(
  email: email.trim(),
  password: password,
);
```
- `signInWithEmailAndPassword` → fungsi bawaan Firebase untuk login.
- `.trim()` → buang spasi tak sengaja di email.
- Hasilnya di-ubah jadi `Map` (`_mapUser`) berisi uid/email/name/dll.

**Kenapa hasilnya `Map`, bukan langsung `UserEntity`?** Aturan Clean Architecture: lapisan `data`
tidak boleh "tahu" soal entity domain terlalu dalam. DataSource kembalikan data mentah (`Map`),
lalu **Repository** yang mengubahnya jadi `UserEntity`. Ini bikin gampang dites.

**Penanganan error yang ramah:** Firebase melempar kode error teknis seperti `wrong-password`.
User awam tidak paham itu. Maka kita terjemahkan:
```dart
case 'user-not-found':      return 'Email belum terdaftar.';
case 'wrong-password':      return 'Email atau password salah.';
case 'network-request-failed': return 'Tidak ada koneksi internet.';
```
Ini dibungkus jadi `AuthException` (dari `core/errors/exceptions.dart`).

`signInWithGoogle()` sengaja `throw AuthException('Login dengan Google belum tersedia')`.

### Langkah 3 — Local DataSource: `auth_local_datasource.dart`
Menyimpan data user ke **Hive** (offline). Caranya: ubah `Map` jadi teks JSON lalu simpan.

```dart
await _box.put('currentUser', jsonEncode(user)); // simpan
final raw = _box.get('currentUser');             // ambil
return jsonDecode(raw) as Map<String, dynamic>;  // ubah balik ke Map
```
- `jsonEncode` / `jsonDecode` → ubah objek Dart ↔ teks (karena Hive di sini menyimpan `String`).
- Berguna supaya, saat internet mati, aplikasi masih "ingat" siapa yang login.

### Langkah 4 — Repository: `auth_repository_impl.dart` (otaknya)
Menggabungkan remote + local. Alur `signIn`:
```dart
final map = await _remote.signIn(...); // 1. login ke Firebase
await _local.cacheUser(map);           // 2. simpan ke Hive (offline)
return _entityFromMap(map);            // 3. ubah jadi UserEntity untuk UI
```
`signOut` → logout Firebase **dan** hapus cache lokal. `authStateChanges` → "sensor" yang
memberi tahu kapan user login/logout (berguna untuk auto-redirect).

> **Catatan pola:** Fauzan di fitur Guest pakai `Either<Failure, T>` (dari `fpdart`) untuk
> menangani error. Di Auth, skeleton yang sudah ada memakai gaya **melempar exception** dan
> `AuthBloc` sudah menangkapnya dengan `try/catch`. Untuk **dampak minimal** (tidak merombak
> BLoC yang sudah jalan), kita pertahankan gaya ini. Sama-sama benar; sekadar beda selera.

### Langkah 5 — Screen: `login_screen.dart` (tampilan)
Menampilkan form login sesuai `DESIGN.md` (warna hijau brand, font besar). Bagian penting:

- **`LoginScreen`** = `StatelessWidget` yang membungkus dengan `BlocProvider` (ambil `AuthBloc`
  dari `getIt`). Ini pola wajib: layar dibungkus `BlocProvider` di paling atas.
- **`LoginView`** = `StatefulWidget` — **hanya** untuk mengelola `TextEditingController`
  (kolom email/password) & toggle lihat-password. Ini BUKAN pelanggaran aturan "no setState
  untuk logika", karena controller memang butuh siklus hidup (dibuat & di-`dispose`), dan
  toggle password memakai `ValueNotifier` + `ValueListenableBuilder` (bukan `setState`).
- **`BlocConsumer`** = gabungan 2 hal:
  - `listener` → efek samping: kalau `AuthError` tampilkan **SnackBar** merah; kalau
    `Authenticated` pindah ke dashboard.
  - `builder` → gambar UI; kalau `AuthLoading` tombol jadi **spinner** dan dinonaktifkan.
- **Validasi form**: email wajib & format benar, password wajib & minimal 6 karakter.
- Tombol Google memunculkan SnackBar "Segera hadir".

Widget yang dipamerkan (memenuhi *Concept A — Flutter Widgets*): `Scaffold`, `SafeArea`,
`Center`, `SingleChildScrollView`, `Form`, `Column`, `TextFormField`, `ElevatedButton`,
`OutlinedButton`, `Row`, `Divider`, `Icon`, `CircularProgressIndicator`.

---

## 5. Fitur Notifikasi (FCM + Telegram) — step by step

Tujuan: saat tamu check-in, **host** dapat notifikasi. Dua jalur:
1. **FCM** (Firebase Cloud Messaging) → untuk ambil *token* HP & izin push (gratis).
2. **Telegram** → notifikasi asli dikirim lewat **backend Contabo** ke bot Telegram host.

> **Kenapa Telegram lewat backend, bukan langsung dari HP?** Karena token bot Telegram itu
> rahasia — kalau ditaruh di aplikasi, bisa dicuri. Jadi HP hanya memanggil backend kita,
> backend yang pegang token & kirim ke Telegram. Lebih aman.

File: `features/notification/data/repositories/notification_repository_impl.dart`

```dart
// FCM — cukup 3 baris inti:
await _messaging.requestPermission(...);       // minta izin notifikasi
final token = await _messaging.getToken();      // ambil token HP ini
await _messaging.subscribeToTopic('all');       // langganan broadcast

// Telegram — lewat ApiClient (yang panggil backend):
await _apiClient.sendTelegramNotification(chatId: ..., text: ...);
```

**Fungsi `buildTelegramMessage(...)`** = fungsi **murni** (tanpa efek samping) yang merangkai
teks pesan HTML Bahasa Indonesia. Dibuat terpisah supaya **gampang dites** tanpa perlu jaringan:
```
🏢 Tamu Baru — Kantor Desa Cakrawala
👤 Nama: Budi Santoso
🕐 Waktu Check-In: 6 Jul 2026, 10:00
```
Format ini meniru fungsi `sendGuestNotification` yang sudah ada di backend (`telegram.ts`).

**Catatan penamaan:** parameter interface bernama `phoneNumber`, tapi untuk Telegram artinya
**chat id**. Ini didokumentasikan jelas lewat komentar `///` supaya tidak membingungkan.

`ApiClient` (di `shared/services/api_client.dart`) sudah dibuat sebelumnya — dia memakai
`http` untuk POST ke `backend/api/notifications/telegram`. Kita tinggal pakai.

---

## 6. Settings Screen + Export CSV — step by step

### a) Settings Screen (`settings_screen.dart`)
Halaman pengaturan admin, berisi:
- **Profil Lokasi** (nama, alamat, No. Telegram host) → sementara data contoh.
- **Preferensi** → 2 `SwitchListTile`: "Mode Gelap" & "Notifikasi Telegram".
- Tombol **Export CSV**.
- Tombol **Keluar** (logout) → memunculkan `AlertDialog` konfirmasi dulu, lalu kirim
  `LogoutRequested` ke `AuthBloc`.

**Kenapa ada `SettingsCubit`?** Aturan proyek: dilarang `setState`. Toggle mode gelap butuh
menyimpan status on/off, jadi kita pakai **Cubit** (versi ringkas dari BLoC — tanpa Event,
cukup panggil method). Cubit ini juga menyimpan pilihan mode gelap ke `shared_preferences`
supaya tetap tersimpan walau aplikasi ditutup:
```dart
Future<void> setDarkMode(bool value) async {
  await _prefs.setBool(AppConstants.keyDarkMode, value);
  emit(state.copyWith(darkMode: value));
}
```

### b) Export CSV (`csv_export_service.dart`)
Mengubah daftar tamu jadi file **CSV** (bisa dibuka di Excel) lalu membagikannya.

Dipisah jadi 2 bagian (biar bisa dites tanpa file):
1. **`buildCsv(...)`** = fungsi murni → menghasilkan **teks CSV**. Ada penanganan *escape*
   sesuai standar RFC 4180: kalau nama mengandung koma/kutip, dibungkus tanda kutip.
   ```
   Nama,No. WhatsApp,Email,Keperluan,...
   Budi Santoso,+6281298765432,budi@example.com,Meeting,...
   ```
2. **`exportAndShare(...)`** = tulis teks itu ke file sementara (`path_provider`) lalu buka
   menu bagikan HP (`share_plus`).

Library yang dipakai di sini (memenuhi *Concept G — Popular Libraries*): `path_provider`,
`share_plus`, `intl` (format tanggal).

---

## 7. Menyambungkan semuanya (Dependency Injection)

Semua objek baru didaftarkan di **`lib/injection_container.dart`** supaya bisa dipakai di mana pun:

```dart
// Buka box Hive khusus auth (offline session)
final authBox = await Hive.openBox<String>(AppConstants.boxNameAuth);

// Shared
getIt.registerLazySingleton<ApiClient>(() => ApiClient());

// DataSources auth
getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
getIt.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(box: authBox));

// Repositories
getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));
getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(apiClient: getIt()));

// BLoCs
getIt.registerFactory(() => AuthBloc(authRepository: getIt()));
getIt.registerFactory(() => NotificationBloc(notificationRepository: getIt()));
```

- **`registerLazySingleton`** = objek dibuat **sekali** saat pertama dipakai, lalu dipakai ulang
  (cocok untuk repository/datasource yang cukup 1).
- **`registerFactory`** = objek **baru** tiap kali diminta (cocok untuk BLoC, karena tiap layar
  butuh BLoC segar).

Juga ditambahkan 1 konstanta baru: `AppConstants.boxNameAuth = 'auth'` (nama box Hive untuk
cache user).

---

## 8. Testing — kenapa & bagaimana

Aturan proyek: setiap repository/BLoC/screen wajib ada test. Test = "bukti kode benar" +
pengaman agar perubahan nanti tidak diam-diam merusak.

| File test | Menguji apa | Teknik |
|-----------|-------------|--------|
| `auth_repository_impl_test.dart` | signIn menyimpan cache & kembalikan entity; signOut hapus cache; error diteruskan | **mocktail** (datasource palsu) |
| `auth_bloc_test.dart` | LoginRequested → [Loading, Authenticated]/[Loading, Error]; Logout → Initial | **bloc_test** |
| `login_screen_test.dart` | Field email+password, tombol Masuk & Google muncul | **widget test** + mock BLoC |
| `settings_screen_test.dart` | 2 switch, tombol Keluar & Export muncul | **widget test** |
| `notification_repository_impl_test.dart` | format pesan Telegram benar; ApiClient dipanggil | **mocktail** |
| `csv_export_service_test.dart` | header CSV benar; escape koma/kutip benar | unit test murni |

**Istilah:**
- **Mock** = objek "boongan" yang meniru objek asli, supaya test tidak butuh Firebase/internet.
- **mocktail** = library untuk bikin mock.
- **bloc_test** = library khusus menguji urutan State yang dikeluarkan BLoC.

---

## 9. Catatan penting & PR (pekerjaan lanjutan)

1. **`google_sign_in` belum dipasang** → tombol Google baru "Segera hadir". Kalau mau
   diaktifkan: tambah package `google_sign_in`, isi konfigurasi native (SHA-1 Android +
   `GoogleService-Info.plist` iOS), lalu implementasi di `signInWithGoogle()`.

2. **⚠️ Konflik dependency di `pubspec.yaml` (BUKAN dari kode Hafiz).** Di Flutter versi baru,
   `freezed 2.5.8` + `test 1.25.8` **membuat `flutter pub get` gagal**. Padahal `freezed`,
   `json_serializable`, dan `test` (eksplisit) **tidak dipakai** di `lib/`. **Rekomendasi tim:**
   hapus 4 baris ini dari `dev_dependencies` agar `pub get` lancar di semua mesin:
   ```yaml
   test: ^1.25.8            # redundant, flutter_test sudah menyediakan
   build_runner: ^2.4.14    # hanya untuk freezed (tak terpakai)
   freezed: ^2.5.8          # tak terpakai (entity ditulis manual)
   json_serializable: ^6.9.2 # tak terpakai
   ```
   *(Selama verifikasi, keempat baris ini sempat dihapus sementara lalu dikembalikan ke asli.
   Keputusan menghapus permanen diserahkan ke tim.)*

3. **Routing belum tersambung.** `lib/app.dart` masih menampilkan placeholder. Setelah Annur
   menyelesaikan `dashboard_screen`, perlu ada `onGenerateRoute`/tabel route supaya login bisa
   berpindah ke dashboard. `login_screen` sudah aman (kalau route belum ada, ia menampilkan
   SnackBar, tidak crash).

4. **Data profil di Settings & daftar tamu untuk Export** masih contoh — nanti disambungkan
   ke `LocationBloc`/`GuestBloc` saat integrasi Sprint 1.3.

5. **`firebase_options.dart` wajib dibuat** dengan `flutterfire configure` sebelum aplikasi
   bisa dijalankan (file ini di-`.gitignore`, jadi tiap orang generate sendiri).

---

### ✅ Ringkasan file yang dibuat/diubah untuk tugas Hafiz

**Kode (`lib/`):**
- `features/auth/data/datasources/auth_remote_datasource.dart` — implementasi Firebase Auth
- `features/auth/data/datasources/auth_local_datasource.dart` — cache Hive
- `features/auth/data/repositories/auth_repository_impl.dart` — offline-aware
- `features/auth/presentation/screens/login_screen.dart` — UI login lengkap
- `features/notification/data/repositories/notification_repository_impl.dart` — FCM + Telegram
- `features/location/presentation/screens/settings_screen.dart` — UI settings
- `features/location/presentation/bloc/settings_cubit.dart` + `settings_state.dart` — toggle
- `features/location/data/services/csv_export_service.dart` — export CSV
- `core/constants/app_constants.dart` — tambah `boxNameAuth`
- `injection_container.dart` — daftarkan auth + notification + ApiClient

**Test (`test/`):**
- `unit/features/auth/auth_repository_impl_test.dart`
- `unit/features/auth/auth_bloc_test.dart`
- `unit/features/notification/notification_repository_impl_test.dart`
- `unit/features/location/csv_export_service_test.dart`
- `widget/features/auth/login_screen_test.dart`
- `widget/features/location/settings_screen_test.dart`

---

*Disusun sebagai panduan belajar untuk tim TamuKu — Universitas Cakrawala 2026.*
