# Penjelasan Mendalam Setiap Library — TamuKu

> Dokumen ini menjelaskan **tiap library satu per satu** secara detail tapi mudah dipahami.
> Format tiap library:
> - **Apa ini** (analogi sederhana)
> - **Masalah yang dipecahkan** (kenapa butuh)
> - **Dipakai di mana** (file nyata di proyek)
> - **Cara kerja singkat** (API kunci)
> - **Kenapa ini, bukan alternatif**
> - **💬 Jawaban singkat kalau ditanya dosen**

Cara pakai: baca kelompok yang sesuai bagianmu dulu (State Management, Firebase, Local Storage,
Networking, Export). Yang lain buat jaga-jaga.

---

## DAFTAR KELOMPOK
1. [State Management](#1-state-management)
2. [Firebase (Backend Google)](#2-firebase-backend-google)
3. [Penyimpanan Lokal (Offline)](#3-penyimpanan-lokal-offline)
4. [Dependency Injection](#4-dependency-injection)
5. [Networking / HTTP](#5-networking--http)
6. [Kamera, QR, Gambar](#6-kamera-qr-gambar)
7. [Export & Berbagi (Share, PDF, Excel, CSV)](#7-export--berbagi)
8. [Utilitas (Format, Chart, Font)](#8-utilitas)
9. [Error Handling Fungsional (fpdart)](#9-error-handling-fungsional-fpdart)
10. [Testing (dev)](#10-testing-dev)
11. [Library Backend & Web (ringkas)](#11-library-backend--web)

---

## 1. STATE MANAGEMENT

### `flutter_bloc` (^9.1.1) — **library paling penting di app ini**

**Apa ini:** Pola & library untuk memisahkan **logika bisnis** dari **tampilan (UI)**.
Analogi: bayangkan restoran. UI = pelayan (cuma terima pesanan & antar makanan). BLoC = dapur
(masak/logika). Pelayan nggak masak, dapur nggak layani meja. Terpisah rapi.

**Masalah yang dipecahkan:** Kalau logika dicampur di dalam widget (pakai `setState`), kode jadi
berantakan, susah dites, dan state nggak bisa dibagi ke widget lain. BLoC memisahkannya.

**Cara kerja — pola Event → State:**
```
UI kirim EVENT  →  BLoC proses  →  BLoC keluarkan STATE baru  →  UI rebuild sesuai STATE
```
Contoh login (`auth_bloc.dart`):
1. UI kirim `LoginRequested(email, password)` → `context.read<AuthBloc>().add(...)`
2. BLoC: `emit(AuthLoading())` → UI tampil spinner
3. BLoC panggil repository, sukses → `emit(Authenticated(user))` → UI pindah dashboard
4. Gagal → `emit(AuthError(pesan))` → UI tampil SnackBar merah

**Dipakai di:** `AuthBloc`, `GuestBloc`, `GuestFormBloc`, `LocationBloc`, `NotificationBloc`
(pakai Bloc), dan `SettingsCubit`, `ScanCubit` (pakai Cubit).

**Bloc vs Cubit (SATU library, dua gaya):**
- **Bloc** = pakai Event. UI `add(Event)` → handler `on<Event>` → `emit`. Untuk logika kompleks.
- **Cubit** = tanpa Event, panggil method langsung → `emit`. Untuk state simpel (contoh:
  `SettingsCubit.setDarkMode(true)`). Lebih ringkas.

**Kenapa ini, bukan alternatif:**
| Alternatif | Kenapa TIDAK dipakai |
|-----------|----------------------|
| `setState` | Nyampur logika+UI dalam 1 widget, nggak bisa dites terpisah, state nggak bisa di-share |
| `Provider` | Bagus buat DI sederhana, tapi nggak maksa struktur Event→State → alur gampang berantakan |
| `Riverpod` | Modern & bagus, tapi BLoC lebih eksplisit soal transisi state & jadi standar industri (gampang dijelaskan & didokumentasikan) |

**💬 Kalau ditanya:** *"flutter_bloc memisahkan logika dari UI lewat pola Event→State. Kami pilih
ini karena logikanya bisa di-unit-test tanpa UI, alurnya satu arah & mudah dilacak. Beda dari
setState yang nyampur logika di widget dan nggak testable. Cubit kami pakai untuk state simpel
seperti dark mode, Bloc untuk yang kompleks seperti auth."*

---

### `equatable` (^2.0.5) — teman wajib BLoC

**Apa ini:** Library kecil yang bikin dua objek bisa dibandingkan **berdasarkan isinya** (by-value),
bukan berdasarkan alamat memori (by-reference).

**Masalah yang dipecahkan:** Secara default di Dart, dua objek dengan isi sama dianggap **BEDA**
(karena beda alamat memori). BLoC pakai perbandingan ini untuk memutuskan "perlu rebuild UI atau
nggak". Tanpa Equatable, BLoC akan rebuild UI **terus-terusan walau data nggak berubah** → boros.

**Cara kerja:** cukup `extends Equatable` dan override `props`:
```dart
class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
  @override
  List<Object> get props => [user];   // ← objek dibandingkan lewat field ini
}
```
Sekarang `Authenticated(userA) == Authenticated(userA)` bernilai `true`.

**Dipakai di:** semua State, Event, dan Entity (`AuthState`, `GuestEntity`, `SettingsState`, dll).

**Kenapa ini:** Alternatifnya nulis `==` dan `hashCode` manual di tiap kelas → panjang & rawan bug.
Equatable otomatis.

**💬 Kalau ditanya:** *"Equatable bikin objek dibanding by-value lewat `props`. Ini penting karena
BLoC cuma rebuild UI kalau state benar-benar beda. Tanpa ini, objek dibanding by-reference → selalu
dianggap beda → rebuild sia-sia. Equatable juga hemat kode dibanding nulis `==`/`hashCode` manual."*

---

## 2. FIREBASE (Backend Google)

Firebase = kumpulan layanan backend siap pakai dari Google. App ini pakai 4 modul-nya.

### `firebase_core` (^4.11.0)

**Apa ini:** Fondasi. Menghubungkan app Flutter ke project Firebase (`tamuku-6360f`).
Modul Firebase lain (Auth, Firestore, Messaging) butuh ini di-init duluan.

**Dipakai di:** `main.dart:20` → `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
Konfigurasinya ada di `firebase_options.dart`.

**💬 Kalau ditanya:** *"firebase_core menginisialisasi koneksi ke project Firebase. Harus dipanggil
paling awal di main() sebelum pakai Auth/Firestore."*

---

### `firebase_auth` (^6.5.4) — **bagian Hafiz**

**Apa ini:** Layanan autentikasi (login) siap pakai. Mengurus email/password, token sesi,
reset password, dll.

**Masalah yang dipecahkan:** Bikin sistem login sendiri itu SUSAH & BAHAYA — harus urus hashing
password, penyimpanan aman, token, refresh, anti-serangan. Firebase Auth kasih semua itu gratis & teruji.

**Cara kerja di app:**
```dart
// auth_remote_datasource.dart
final credential = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
```
Kalau gagal, Firebase kasih kode error (`wrong-password`, `user-not-found`, dll) → kode kita
terjemahkan ke Bahasa Indonesia lewat `_messageForCode`.
Ada juga `authStateChanges` = stream yang memberi tahu real-time kalau status login berubah.

**Dipakai di:** `auth_remote_datasource.dart`, `auth_repository_impl.dart`.

**Kenapa ini, bukan bikin backend auth sendiri:** hemat waktu, aman, teruji Google, gratis. Untuk
app skala tugas, bikin auth sendiri = buang waktu & rawan celah keamanan.

**💬 Kalau ditanya:** *"firebase_auth handle login email/password. Kami nggak bikin auth sendiri karena
harus urus hashing, token, keamanan — mahal & rawan bug. Firebase gratis dan teruji. Kode error Firebase
kami terjemahkan ke Bahasa Indonesia biar user paham."*

---

### `cloud_firestore` (^6.6.0)

**Apa ini:** Database NoSQL **realtime** di cloud. Data tersimpan sebagai dokumen (mirip JSON) dalam
koleksi (`guests`, `locations`, `hosts`).

**Masalah yang dipecahkan:** Butuh database yang (1) online, (2) update **realtime** (dashboard langsung
berubah kalau ada tamu baru), (3) bisa diakses banyak device.

**Cara kerja — kunci utamanya `.snapshots()` (stream realtime):**
```dart
// guest_remote_datasource.dart
_guests.where('locationId', isEqualTo: locationId)
       .orderBy('checkInTime', descending: true)
       .snapshots()   // ← setiap ada perubahan di DB, otomatis push data baru
       .map((snap) => snap.docs.map(GuestEntity.fromFirestore).toList());
```
`.snapshots()` = realtime (stream). `.get()` = ambil sekali saja (Future).

**Dipakai di:** semua remote datasource (guest, location), dashboard (`StreamBuilder`).

**Kenapa ini, bukan MySQL/PostgreSQL:** Firestore serverless (nggak perlu kelola server DB), realtime
bawaan, dan terintegrasi dengan Firebase Auth untuk aturan keamanan. SQL biasa butuh server + nggak realtime.

**💬 Kalau ditanya:** *"Firestore database NoSQL realtime. Pakai `.snapshots()` supaya dashboard update
otomatis tanpa refresh. Serverless jadi nggak perlu kelola server database sendiri."*

---

### `firebase_messaging` (^16.4.1) — **bagian Hafiz (FCM)**

**Apa ini:** FCM (Firebase Cloud Messaging) = layanan **push notification** gratis.

**Masalah yang dipecahkan:** Mau kirim notifikasi ke HP admin walau app lagi ketutup.

**Cara kerja — 3 langkah:**
```dart
// notification_repository_impl.dart
await _messaging.requestPermission(...);   // 1. minta izin notif ke OS
final token = await _messaging.getToken();  // 2. dapat token unik device
await _messaging.subscribeToTopic('location-loc1'); // 3. langganan topik broadcast
```
- **Token** = alamat unik device, backend pakai ini untuk nembak notif ke 1 HP tertentu.
- **Topic** = kalau device langganan topik, backend cukup kirim ke nama topik → **semua** device
  pelanggan terima (broadcast tanpa kelola daftar token satu-satu).

**Dipakai di:** `notification_repository_impl.dart`, `main.dart` (background handler).

**💬 Kalau ditanya:** *"FCM buat push notification gratis. `getToken` kasih alamat unik device,
`subscribeToTopic` buat broadcast ke banyak device sekaligus. Notif tetap masuk walau app ketutup."*
*(Catatan jujur: di web, FCM butuh setup service worker + VAPID key, jadi mungkin nggak jalan di Chrome — tapi nggak bikin app crash.)*

---

## 3. PENYIMPANAN LOKAL (Offline)

### `hive` (^2.2.3) + `hive_flutter` (^1.1.0)

**Apa ini:** Database **lokal** (di dalam HP) berbentuk key-value, super cepat, ditulis murni dengan
Dart. Analogi: lemari kecil di HP untuk simpan data biar bisa dibuka walau offline.

**Masalah yang dipecahkan:** App harus tetap jalan **tanpa internet** (offline-first). Data tamu,
lokasi, sesi login, dan antrian sync disimpan lokal.

**Cara kerja:** buka "box" (kotak), simpan/ambil data by key. Karena Hive `Box<String>` cuma bisa simpan
String, objek diubah ke JSON dulu:
```dart
// auth_local_datasource.dart
await _box.put('currentUser', jsonEncode(user));   // simpan
final raw = _box.get('currentUser');                // ambil
```

**Dipakai di:** 4 box (`injection_container.dart:43-46`): `guests`, `locations`, `sync_queue`, `auth`.
Cache tamu offline, antrian sync, cache user login.

**Kenapa ini, bukan alternatif:**
| Alternatif | Kenapa Hive lebih pas |
|-----------|----------------------|
| `SharedPreferences` | Cuma buat data kecil/primitif (flag, string). Hive buat data terstruktur/banyak |
| `sqflite` (SQLite) | Butuh definisi tabel + query SQL → ribet untuk simpan objek. Hive key-value lebih ringan & cepat |

**💬 Kalau ditanya:** *"Hive database lokal key-value cepat, buat offline-first — cache tamu, sesi
login, dan antrian sync. Dibanding SQLite nggak perlu SQL, dibanding SharedPreferences bisa untuk data
terstruktur & banyak. Objek disimpan sebagai JSON string."*

---

### `shared_preferences` (^2.3.4) — **bagian Hafiz (Settings)**

**Apa ini:** Penyimpanan lokal untuk **data kecil sederhana** (bool, string, angka). Analogi: sticky note.

**Masalah yang dipecahkan:** Simpan preferensi ringan yang perlu dibaca cepat: status dark mode,
status notifikasi, dan `locationId` admin.

**Cara kerja:**
```dart
// settings_cubit.dart
await _prefs.setBool('darkMode', true);        // simpan
final dark = _prefs.getBool('darkMode') ?? false; // baca (default false)
```

**Dipakai di:** `SettingsCubit` (dark mode), `AuthBloc` (locationId).

**Kenapa Hive DAN SharedPreferences dua-duanya?** Pembagian tugas: **objek/data terstruktur → Hive**,
**nilai kecil primitif → SharedPreferences**. Pakai Hive untuk 2 flag bool = berlebihan.

**💬 Kalau ditanya:** *"SharedPreferences buat nilai kecil: dark mode, status notif, locationId.
Ringan dan cepat. Data yang lebih besar/terstruktur pakai Hive."*

---

## 4. DEPENDENCY INJECTION

### `get_it` (^9.2.1)

**Apa ini:** "Service Locator" — gudang pusat tempat semua objek (BLoC, Repository, Service) dirakit
dan diambil. Analogi: gudang alat. Butuh alat? Ambil dari gudang, nggak usah bikin sendiri tiap kali.

**Masalah yang dipecahkan:** Tanpa DI, setiap widget harus bikin sendiri BLoC + repository +
datasource-nya → kode duplikat, susah ganti, susah dites. get_it merakitnya di **satu tempat**.

**Cara kerja — 3 jenis registrasi (`injection_container.dart`):**
```dart
getIt.registerLazySingleton(() => ApiClient());     // 1 instance, dibuat saat pertama diminta
getIt.registerFactory(() => AuthBloc(...));          // instance BARU tiap dipanggil
```
- `registerLazySingleton` = satu objek di-share (Repository, Service, DataSource).
- `registerFactory` = objek baru tiap kali → **untuk semua BLoC** (karena BLoC di-`close()` saat layar
  ditutup; kalau singleton, yang sudah close dipakai ulang → **crash**).

Mengambil: `getIt<AuthBloc>()` → get_it otomatis rakit `AuthBloc → AuthRepository → DataSource → Firebase/Hive`.

**Kenapa ini, bukan Provider / passing manual:** get_it bebas `BuildContext` (bisa dipakai di `main`,
di dalam BLoC), pusatkan pembuatan objek, dan **gampang di-mock saat test** (ganti objek asli dengan palsu).

**💬 Kalau ditanya:** *"get_it itu dependency injection — gudang pusat yang merakit objek. BLoC di-register
factory karena punya lifecycle (di-close saat layar tutup); repository di-register singleton karena
di-share. Manfaatnya: kode nggak perlu tahu cara bikin objek, dan gampang di-mock pas testing."*

---

## 5. NETWORKING / HTTP

### `http` (^1.2.2)

**Apa ini:** Library resmi tim Dart untuk kirim request HTTP (GET/POST) ke server. Dipakai untuk
komunikasi dengan **backend** (notif Telegram, export Excel, upload foto).

**Cara kerja:**
```dart
// api_client.dart
await _client.post(Uri.parse('$baseUrl/api/notifications/telegram'),
  headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
  body: jsonEncode({'chatId': chatId, 'text': text}));
```
Header `x-api-key` = "kunci masuk" biar backend tahu request-nya sah.

**Dipakai di:** `api_client.dart` (semua panggilan ke backend), upload foto ke S3.

**Kenapa ini, bukan `dio`:** `http` ringan & resmi Dart, cukup untuk kebutuhan sederhana. `dio` punya
fitur lebih (interceptor, retry) tapi lebih berat — nggak perlu di sini.

**💬 Kalau ditanya:** *"http buat panggil API backend. Ringan dan resmi Dart. Header x-api-key buat
autentikasi ke backend. dio kami nggak pakai karena fiturnya berlebihan untuk kasus ini."*

---

### `connectivity_plus` (^7.2.0)

**Apa ini:** Deteksi apakah HP lagi **online atau offline** (ada WiFi/data atau nggak).

**Masalah yang dipecahkan:** App offline-first perlu tahu status koneksi untuk memutuskan: kirim ke
Firestore (online) atau simpan ke antrian sync (offline)? Dan trigger sync saat koneksi balik.

**Cara kerja:**
```dart
// network_info.dart
final result = await Connectivity().checkConnectivity();
return !result.contains(ConnectivityResult.none);
// app.dart — dengar perubahan koneksi, kalau balik online → jalankan sync queue
Connectivity().onConnectivityChanged.listen(...)
```

**Dipakai di:** `NetworkInfo` (keputusan online/offline), `app.dart` (trigger sync).

**⚠️ Catatan jujur:** ini cuma cek ada interface jaringan, **bukan** internet beneran. WiFi tanpa
internet tetap dianggap "online". Untung antrian sync menangani kegagalan dengan retry.

**💬 Kalau ditanya:** *"connectivity_plus deteksi online/offline. Dipakai buat keputusan offline-first
dan trigger sync pas koneksi balik. Kelemahannya cuma cek ada jaringan, bukan internet asli — tapi
sync queue kami handle kalau ternyata gagal kirim."*

---

## 6. KAMERA, QR, GAMBAR

### `mobile_scanner` (^7.2.0)

**Apa ini:** Baca **QR code** pakai kamera. Berbasis engine native (Google MLKit) → cepat & akurat.

**Cara kerja:**
```dart
// scan_screen.dart
MobileScanner(onDetect: (capture) => _handleScan(context, capture));
// _handleScan ambil barcode.rawValue, parse jadi locationId + hostPhone
```

**Dipakai di:** `scan_screen.dart` (scan QR lokasi). *(Ingat: layar ini kode legacy/orphan; alur
tamu produksi lewat form web yang di-scan pakai kamera HP biasa.)*

**Kenapa ini, bukan `qr_code_scanner`:** `mobile_scanner` aktif dirawat & berbasis MLKit native.
`qr_code_scanner` sudah deprecated & bermasalah di Android/iOS baru.

**💬 Kalau ditanya:** *"mobile_scanner baca QR pakai kamera, berbasis MLKit native jadi cepat & akurat.
Library QR lama seperti qr_code_scanner sudah deprecated."*

---

### `qr_flutter` (^4.1.0)

**Apa ini:** **Membuat/generate** QR code (kebalikan dari scan). Pure-Dart.

**Cara kerja — 2 mode:**
```dart
// qr_generator_screen.dart
// Mode 1: tampil di layar (widget)
QrImageView(data: 'https://tamuku-api.chronaxis.site/guest?loc=$locationId', ...)
// Mode 2: jadi gambar/raster buat ditanam ke PDF
QrPainter.withQr(...).toImageData(300)
```
QR meng-encode **URL web** (bukan locationId telanjang) → tamu scan pakai kamera HP biasa → buka form web.

**Dipakai di:** `qr_generator_screen.dart`.

**Kenapa 2 mode?** `QrImageView` itu widget (cuma buat layar). Package `pdf` nggak nerima widget Flutter,
jadi QR di-render ulang jadi gambar (`QrPainter`) buat masuk ke PDF.

**💬 Kalau ditanya:** *"qr_flutter generate QR. `QrImageView` buat tampil di layar, `QrPainter` buat
bikin gambar QR yang ditanam ke PDF saat print. QR-nya isi URL web form tamu."*

---

### `image_picker` (^1.1.2)

**Apa ini:** Ambil foto dari **kamera atau galeri**. Plugin resmi tim Flutter.

**Cara kerja:**
```dart
// guest_form_screen.dart
final picked = await ImagePicker().pickImage(
  source: ImageSource.camera, maxWidth: 800, imageQuality: 80); // resize + kompres
```
`maxWidth`/`imageQuality` = perkecil ukuran foto sebelum upload.

**Dipakai di:** `guest_form_screen.dart` (foto tamu opsional). **Foto dokumentasi, BUKAN face recognition.**

**💬 Kalau ditanya:** *"image_picker ambil foto dari kamera/galeri, dengan resize & kompres bawaan biar
upload ringan. Fotonya dokumentasi kunjungan, bukan pengenalan wajah."*

---

### `cached_network_image` (^3.4.1)

**Apa ini:** Menampilkan gambar dari internet (foto tamu di S3) **sekaligus meng-cache-nya** biar
nggak download ulang tiap kali.

**Cara kerja:** kasih URL → tampilkan gambar, simpan di cache, ada placeholder saat loading & fallback
kalau error.

**Dipakai di:** `guest_tile.dart`, `checkout_screen.dart` (tampilkan foto tamu).

**💬 Kalau ditanya:** *"cached_network_image tampilkan foto dari S3 dan cache-nya biar hemat data &
nggak loading ulang. Ada placeholder & fallback kalau gambar gagal."*

---

## 7. EXPORT & BERBAGI

### `share_plus` (^13.2.0) — **bagian Hafiz (Export)**

**Apa ini:** Buka menu "Share" bawaan OS (kirim file/teks ke WhatsApp, Gmail, Drive, dll).

**Cara kerja:**
```dart
// csv_export_service.dart
await SharePlus.instance.share(ShareParams(files: [XFile(path, mimeType: 'text/csv')]));
```

**Dipakai di:** export CSV, export Excel, share QR.

**Kenapa ini:** Nggak perlu bikin integrasi ke tiap aplikasi tujuan — OS yang urus.

**💬 Kalau ditanya:** *"share_plus buka share sheet native OS. Jadi user bisa kirim file CSV/Excel/QR
ke app apapun tanpa kami bikin integrasi khusus."*

---

### `pdf` (^3.1.7) + `printing` (^5.12.0)

**Apa ini:** `pdf` = bikin dokumen PDF lewat kode. `printing` = buka dialog cetak/simpan PDF.
Keduanya dari penulis yang sama.

**Cara kerja:** susun halaman A4 berisi QR + instruksi pakai widget `pw.*` → `Printing.layoutPdf(...)`
buka dialog print.

**Dipakai di:** `qr_generator_screen.dart` (cetak/simpan QR lokasi ke PDF).

**💬 Kalau ditanya:** *"pdf bikin dokumen PDF programatik (QR + instruksi), printing buka dialog cetak.
Level koreksi error QR dinaikin ke H biar tetap kebaca walau hasil cetak agak rusak."*

---

### `excel` (^4.0.6) — **⚠️ TERDAFTAR TAPI TIDAK DIPAKAI di Flutter**

**Apa ini:** Library untuk bikin file Excel (`.xlsx`) di Dart.

**Status jujur:** Terdaftar di `pubspec.yaml`, TAPI generation Excel sebenarnya **dipindah ke backend**
(pakai ExcelJS) biar styling lebih kaya. Jadi library ini praktis nggak kepakai di kode Flutter.

**💬 Kalau ditanya "di mana excel dipakai?":** *"Awalnya buat generate Excel di app, tapi sekarang
Excel dibuat di backend pakai ExcelJS biar stylingnya lebih bagus (warna, border). Jadi package excel
ini sisa dari implementasi lama — sebaiknya dihapus dari pubspec."*

---

### CSV (tanpa library — dibuat manual)

**Penting:** CSV **tidak pakai library** — dibuat manual di `csv_export_service.dart` mengikuti
standar **RFC 4180**. Fungsi `_escape()` membungkus field yang ada koma/kutip/newline dengan tanda
kutip ganda. Ini yang bikin nama "Budi, S.Kom" nggak pecah jadi 2 kolom.

**💬 Kalau ditanya:** *"CSV kami buat manual ikut RFC 4180, nggak pakai library — cukup logika escape
sederhana. Field yang ada koma dibungkus tanda kutip biar nggak merusak kolom."*

---

## 8. UTILITAS

### `intl` (^0.20.3)

**Apa ini:** Format tanggal/waktu/angka sesuai lokal (Indonesia `id_ID`).

**Cara kerja:**
```dart
// main.dart
await initializeDateFormatting('id_ID', null);
// formatters.dart pakai DateFormat buat tampil "09 Jul 2026, 14:30"
```

**Dipakai di:** `Formatters` (format tanggal tamu, dipakai di CSV, list, checkout).

**💬 Kalau ditanya:** *"intl buat format tanggal locale Indonesia. Tanpa ini, format tanggal nggak
konsisten/pakai English."*

---

### `fl_chart` (^1.2.0)

**Apa ini:** Bikin grafik/chart (di app ini: bar chart kunjungan 7 hari di dashboard).

**Cara kerja:** kasih data → `BarChart` gambar batang. `StatelessWidget` yang terima data; realtime-nya
dari `StreamBuilder` dashboard yang hitung ulang data lalu chart rebuild + animasi 300ms.

**Dipakai di:** `visit_chart.dart`.

**Kenapa ini, bukan alternatif:** `fl_chart` 100% Flutter (Canvas), sangat customizable, animasi bawaan.
`charts_flutter` (Google) sudah discontinued; Syncfusion berat & berlisensi.

**💬 Kalau ditanya:** *"fl_chart bikin bar chart kunjungan. Chart-nya stateless, yang bikin realtime itu
StreamBuilder yang hitung ulang data tiap ada tamu baru. Dipilih karena customizable & animasi bawaan."*

---

### `google_fonts` (^8.1.0) — **⚠️ TERDAFTAR TAPI BELUM DIPAKAI**

**Apa ini:** Muat font dari Google Fonts tanpa bundle file `.ttf` manual.

**Status jujur:** Terdaftar di pubspec, TAPI `AppTextStyles` masih pakai font sistem (Roboto/SF Pro).
Belum ada pemanggilan `GoogleFonts` di kode.

**💬 Kalau ditanya:** *"google_fonts didaftarkan buat kesiapan branding font, tapi belum dipanggil —
teks sekarang masih pakai font sistem."*

---

## 9. ERROR HANDLING FUNGSIONAL (fpdart)

### `fpdart` (^1.1.1) — dipakai di fitur Guest & Location (bukan Auth)

**Apa ini:** Library functional programming. Yang dipakai di app ini: tipe **`Either<Failure, T>`**.

**Masalah yang dipecahkan:** Cara menangani error yang **memaksa** kita menangani kegagalan, bukan
dilempar sebagai exception yang gampang lupa di-catch.

**Cara kerja:** fungsi mengembalikan `Either` = dua kemungkinan:
- `Left(Failure)` = GAGAL (mis. `ServerFailure`, `CacheFailure`)
- `Right(data)` = SUKSES

Ditangani dengan `.fold()`:
```dart
// guest_bloc.dart
result.fold(
  (failure) => emit(GuestError(failure.message)),   // Left → error
  (guests)  => emit(GuestLoaded(guests)),            // Right → sukses
);
```

**Dua gaya error di proyek ini (SERING DITANYA):**
- **Guest & Location** → pakai `Either` (fpdart). Alasan: banyak jenis kegagalan (server vs cache
  kosong vs offline) yang harus dibedakan.
- **Auth & Notification** → pakai **throw exception** + `try/catch`. Alasan: alurnya linear, lebih ringkas.

**💬 Kalau ditanya "kenapa beda gaya error?":** *"Guest pakai Either karena banyak jenis kegagalan yang
harus dibedakan dan sering di-fold jadi state. Auth alurnya linear (berhasil/gagal login) jadi
try/catch cukup. Jujur, ini juga karena pembagian tugas antar developer, tapi keduanya sah dan tetap
di bawah satu tipe Failure yang sama."*

---

## 10. TESTING (dev)

### `flutter_test` + `bloc_test` (^10.0.0) + `mocktail` (^1.0.4)

**Apa ini:**
- `flutter_test` = framework test bawaan Flutter.
- `bloc_test` = helper khusus untuk menguji BLoC (cek urutan state yang di-emit).
- `mocktail` = bikin objek **palsu (mock)** untuk menggantikan dependency asli saat test (mis. ganti
  Firebase asli dengan Firebase palsu).

**Cara kerja:**
```dart
// auth_bloc_test.dart
blocTest<AuthBloc, AuthState>(
  'emits [Loading, Authenticated] on successful login',
  build: () => AuthBloc(authRepository: mockRepo),
  act: (bloc) => bloc.add(LoginRequested(...)),
  expect: () => [AuthLoading(), Authenticated(user)],   // ← state yang diharapkan
);
```

**Kenapa `mocktail`, bukan `mockito`:** mocktail nggak butuh code generation (build_runner),
lebih simpel disetup.

**💬 Kalau ditanya:** *"bloc_test buat cek urutan state BLoC, mocktail buat bikin dependency palsu biar
test nggak nyentuh Firebase asli. mocktail dipilih karena nggak perlu code-gen seperti mockito."*

---

## 11. LIBRARY BACKEND & WEB

### Backend (ElysiaJS + Bun)
- **elysia** — framework web TypeScript-first. Validasi request otomatis jadi tipe. Cepat.
- **bun** (runtime) — jalankan TypeScript **tanpa build step**, lebih cepat dari Node. Cocok VPS murah.
- **firebase-admin** — SDK admin: kirim FCM & buat akun Auth dengan privilege tinggi (bypass rules).
- **minio** — SDK S3-compatible untuk Contabo Object Storage (presigned URL upload/baca foto).
- **exceljs** — generate Excel bergaya (warna, border, zebra, auto-width).

**💬 Kenapa backend terpisah?** *"Untuk sembunyikan secret (bot token, S3 key), hindari Firebase Cloud
Functions berbayar, dan jalankan operasi privilege tinggi. Bun/Elysia dipilih karena cepat & jalankan
TypeScript langsung tanpa build."*

### Web Admin (React)
- **react 19** — library UI berbasis komponen.
- **vite 8** — build tool cepat (hot reload saat dev).
- **react-router-dom v7** — navigasi antar halaman (routing SPA).
- **firebase** (JS SDK) — Auth + Firestore langsung dari browser.
- **tailwindcss v4** — styling pakai class utility.
- **Catatan:** react-query/TanStack **tidak dipakai** — fetch data manual pakai `useEffect`+`useState`.

**💬 Kenapa React di web, Flutter di HP?** *"Flutter untuk app mobile admin (satu codebase Android/iOS),
React untuk panel admin di browser. Web admin baca Firestore langsung; backend cuma dipakai untuk
operasi ber-secret."*

---

## RINGKASAN SUPER SINGKAT (buat hafalan cepat)

| Library | Satu kalimat |
|---------|--------------|
| flutter_bloc | Pisah logika dari UI (Event→State) |
| equatable | Bandingkan objek by-value → hemat rebuild |
| firebase_auth | Login email/password siap pakai |
| cloud_firestore | Database realtime cloud (`.snapshots()`) |
| firebase_messaging | Push notification gratis (FCM) |
| hive | Database lokal cepat buat offline |
| shared_preferences | Simpan setting kecil (dark mode, locationId) |
| get_it | Gudang objek (dependency injection) |
| http | Panggil API backend |
| connectivity_plus | Deteksi online/offline |
| mobile_scanner | Baca/scan QR (MLKit) |
| qr_flutter | Generate QR |
| image_picker | Ambil foto kamera/galeri |
| cached_network_image | Tampil + cache foto S3 |
| share_plus | Buka share sheet native |
| pdf + printing | Bikin & cetak PDF QR |
| intl | Format tanggal Indonesia |
| fl_chart | Grafik kunjungan dashboard |
| fpdart | `Either<Failure,T>` (error handling Guest) |
| bloc_test + mocktail | Testing BLoC + mock |
| excel, google_fonts | ⚠️ terdaftar tapi belum/tidak dipakai |

---

*Pelajari kolom "💬 Kalau ditanya" — itu jawaban siap-ucap. Kalau dosen minta lebih dalam, lanjut ke
bagian "Cara kerja" di tiap library.*
