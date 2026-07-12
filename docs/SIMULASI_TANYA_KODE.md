# Simulasi Tanya Kode — Panduan Bertahan Saat Dosen Tunjuk Kode

> Format ujianmu: **duduk, dosen buka file, tunjuk baris kode, tanya "ini apa? kenapa gini?"**
> Dokumen ini melatihmu menjawab SPONTAN. Isinya:
> 1. Protokol darurat (kalau ditunjuk kode yang nggak kamu kenal)
> 2. Pengenalan pola (cara "membaca" kode apa pun dalam 5 detik)
> 3. Anotasi blok-per-blok file bagianmu (yang paling mungkin dibuka)
>
> **Cara latihan:** buka file aslinya di VS Code sebelah dokumen ini. Baca blok kode, tutup dokumen,
> coba jelasin sendiri, baru cocokkan.

---

## BAGIAN A — PROTOKOL DARURAT (baca ini paling dulu)

Kalau dosen tunjuk kode dan kamu blank, JANGAN panik. Pakai langkah ini:

### Langkah 1 — Ulur waktu sambil baca (WAJAR, bukan bodoh)
> *"Oke, ini di file [nama file], bagian [layer/fitur]. Sebentar saya baca dulu..."*

Sambil ngomong itu, otakmu punya 3 detik untuk mengenali pola (Bagian B).

### Langkah 2 — Identifikasi "ini kode jenis apa"
Hampir semua kode di app ini masuk salah satu dari 6 kategori (lihat Bagian B). Sebut kategorinya dulu:
> *"Ini handler event di BLoC..."* / *"Ini widget UI..."* / *"Ini fungsi di repository..."*

### Langkah 3 — Jelaskan dari NAMA & ALUR, bukan hafalan
Nama fungsi/variabel di proyek ini deskriptif. Baca namanya:
- `_onLoginRequested` → "fungsi yang jalan saat user minta login"
- `buildCsv` → "fungsi yang menyusun teks CSV"
- `_fetchAndStoreLocationId` → "ambil lalu simpan locationId"

Lalu jelaskan alur baris demi baris pakai bahasa manusia.

### Langkah 4 — Kalau benar-benar nggak tahu, JUJUR + arahkan
> *"Bagian spesifik ini saya kurang hapal detailnya, tapi konsepnya [X]. Yang saya kerjakan detail
> adalah bagian [auth/notifikasi/settings/export]."*

Kejujuran + tahu batas = lebih baik daripada ngarang dan ketahuan. Dosen menghargai ini.

### Kalimat penyelamat universal
- *"Ini mengikuti pola Clean Architecture, jadi tugasnya cuma [satu hal]."*
- *"Ini bagian dari pola BLoC — Event masuk, State keluar."*
- *"Ini di-inject lewat get_it, jadi bisa di-mock saat testing."*

---

## BAGIAN B — PENGENALAN POLA (baca kode apa pun dalam 5 detik)

Kenali 6 pola ini. Begitu lihat cirinya, kamu tahu itu ngapain.

### Pola 1: Handler Event BLoC
**Ciri:** fungsi `Future<void> _onXxx(XxxEvent event, Emitter<State> emit)` isinya ada `emit(...)`.
**Artinya:** "logika yang jalan saat event Xxx dikirim UI. Dia proses lalu `emit` state baru."
**Contoh jawaban:** *"Ini handler event. Pas UI kirim event ini, dia emit Loading, panggil repository,
kalau sukses emit state sukses, kalau gagal emit error."*

### Pola 2: Widget UI (build)
**Ciri:** `Widget build(BuildContext context)` return `Scaffold`/`Column`/`Card`/dll.
**Artinya:** "ini yang digambar ke layar."
**Contoh jawaban:** *"Ini method build yang menggambar UI. `BlocBuilder`/`BlocConsumer` di sini
dengerin state dari BLoC, jadi UI berubah sesuai state."*

### Pola 3: Repository / DataSource
**Ciri:** class `XxxRepositoryImpl` / `XxxDataSourceImpl`, method-nya panggil Firebase/Hive/http.
**Artinya:** "jembatan ke sumber data. Repository orkestrasi, DataSource yang colok Firebase/Hive."
**Contoh jawaban:** *"Ini lapisan data. Repository memutuskan ambil dari remote (Firebase) atau lokal
(Hive), lalu ubah ke Entity buat dipakai app."*

### Pola 4: Entity / Model
**Ciri:** class `extends Equatable`, banyak `final`, ada `props`, `fromMap`/`toMap`.
**Artinya:** "objek data. `props` buat perbandingan by-value. `fromMap/toMap` buat konversi ke/dari database."

### Pola 5: Registrasi DI (get_it)
**Ciri:** `getIt.registerLazySingleton(...)` / `registerFactory(...)`.
**Artinya:** "daftarin objek ke gudang DI. Singleton = 1 di-share, Factory = baru tiap dipanggil (buat BLoC)."

### Pola 6: Konfigurasi / Konstanta
**Ciri:** `abstract final class AppConstants` isinya `static const`.
**Artinya:** "kumpulan konstanta biar nggak ada string/angka ajaib bertebaran."

---

## BAGIAN C — ANOTASI BLOK-PER-BLOK (file bagianmu)

> Urutan = paling mungkin dibuka dosen. Untuk tiap blok: **[Kalau ditunjuk ini → jawab begini]**

### 📁 FILE 1: `auth_bloc.dart` (SANGAT mungkin dibuka)

**Blok: konstruktor (baris 16-27)**
```dart
AuthBloc({required AuthRepository authRepository, required SharedPreferences prefs})
  : _authRepository = authRepository, _prefs = prefs, super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    ...
    _tryRestoreSession();
}
```
→ *"Ini konstruktor BLoC. `super(AuthInitial())` = state awal 'belum login'. Baris `on<...>`
mendaftarkan handler untuk tiap event. `_tryRestoreSession()` dipanggil sekali saat BLoC dibuat,
buat cek apakah ada sesi tersimpan (biar user nggak login ulang). `authRepository` & `prefs`
di-inject dari luar lewat get_it — bukan dibuat di sini — supaya bisa di-mock saat test."*

**Blok: `_onLoginRequested` (baris 48-67) — INTI, hafalkan**
```dart
emit(AuthLoading());
try {
  final user = await _authRepository.signIn(email: event.email, password: event.password);
  await _fetchAndStoreLocationId(user.uid);
  emit(Authenticated(user));
} on AuthException catch (e) {
  emit(AuthError(e.message));
} catch (_) {
  emit(const AuthError('Terjadi kesalahan tak terduga.'));
}
```
→ *"Ini yang jalan saat user login. (1) `emit(AuthLoading())` bikin UI tampil spinner.
(2) panggil `repository.signIn` — ke Firebase. (3) ambil & simpan locationId DULUAN. (4) kalau sukses
`emit(Authenticated)` → UI pindah dashboard. Kalau gagal, `AuthException` ditangkap → `emit(AuthError)`
dengan pesan Indonesia yang sudah diterjemahkan di datasource. `catch(_)` terakhir buat error tak terduga."*

**Kalau ditanya "kenapa `_fetchAndStoreLocationId` SEBELUM emit?"** (baris 58-60, ada komentar CRITICAL)
→ *"Karena begitu emit Authenticated, UI langsung navigasi ke dashboard yang butuh baca locationId dari
SharedPreferences. Kalau locationId belum tersimpan, dashboard tampil kosong. Jadi harus disimpan dulu
baru emit — menghindari race condition."*

**Kalau ditanya "kenapa dua catch (`on AuthException` dan `catch(_)`)?"**
→ *"`on AuthException` nangkap error yang sudah kita terjemahkan ke Bahasa Indonesia (email/password salah,
dll). `catch(_)` jaring pengaman buat error lain yang tak terduga, ditampilkan pesan generik."*

**Blok: `_fetchAndStoreLocationId` (baris 98-140)**
→ *"Fungsi ini cari lokasi milik admin di Firestore berdasarkan adminId. Kalau nggak ketemu, ambil
lokasi mana saja. Kalau tetap kosong (admin pertama kali), bikin lokasi default. Hasilnya (locationId)
disimpan ke SharedPreferences. `catch(_)` di akhir sengaja diam — kalau gagal, layar cuma tampil kosong,
login nggak dibatalkan."*

**Kalau ditanya "kenapa `catch(_)` dibiarkan kosong? bukannya bad practice?"**
→ *"Ini keputusan sengaja. Ambil locationId itu langkah sekunder — kalau gagal, login yang sudah sukses
nggak boleh dibatalkan. Jadi errornya ditelan supaya app tetap jalan, layar tinggal tampil empty state.
Untuk error login utama, kami TIDAK menelan — di situ error diterjemahkan dan ditampilkan."*

**Blok: `_CachedSessionLoaded` (baris 144-149) — event privat**
→ *"Ini event internal (privat, ada underscore) buat mengantar hasil restore sesi ke dalam BLoC. Prinsip
BLoC: semua perubahan state harus lewat event. `_tryRestoreSession` jalan async di konstruktor, hasilnya
dikirim sebagai event ini biar penanganannya konsisten lewat handler. `if (!isClosed)` cegah nambah event
ke BLoC yang sudah ditutup."*

---

### 📁 FILE 2: `login_screen.dart` (mungkin dibuka)

**Blok: `LoginScreen` StatelessWidget + BlocProvider**
→ *"`LoginScreen` cuma bungkus `BlocProvider` yang nyediain `AuthBloc` dari get_it. Stateless karena
nggak punya state berubah. UI-nya ada di `LoginView`."*

**Kalau ditanya "kenapa `LoginScreen` Stateless tapi `LoginView` Stateful?"**
→ *"`LoginScreen` cuma provider, nggak butuh state. `LoginView` Stateful HANYA untuk lifecycle
`TextEditingController` dan `ValueNotifier` — dibuang di `dispose`. Bukan buat logika bisnis; logika
tetap di BLoC."*

**Blok: `BlocConsumer` (listener + builder)**
→ *"`BlocConsumer` gabungan dua fungsi. `listener` buat efek samping sekali jalan: kalau state `AuthError`
tampil SnackBar merah, kalau `Authenticated` navigasi ke dashboard. `builder` buat gambar UI: kalau
`AuthLoading` tombol jadi spinner. Beda listener & builder: listener buat aksi (navigasi/snackbar),
builder buat gambar."*

**Blok: toggle password (`ValueListenableBuilder` + `_obscurePassword`)**
→ *"Ini toggle lihat/sembunyi password. Pakai `ValueNotifier<bool>` + `ValueListenableBuilder` supaya
CUMA field password yang rebuild pas ikon mata ditekan, bukan seluruh layar. Lebih efisien daripada
`setState` yang rebuild semuanya."*

**Blok: tombol Google (disabled)**
→ *"Tombol Google sengaja di-disable, tampil 'Segera hadir'. Login Google fitur fase berikutnya; sekarang
fokus email/password."*

---

### 📁 FILE 3: `notification_repository_impl.dart` (mungkin dibuka)

**Blok: konstruktor (baris 19-23)**
```dart
NotificationRepositoryImpl({ApiClient? apiClient, FirebaseMessaging? messaging})
  : _apiClient = apiClient ?? ApiClient(),
    _messaging = messaging ?? FirebaseMessaging.instance;
```
→ *"Dependency injection dengan default. Kalau nggak dikasih apiClient/messaging, pakai yang asli.
Kalau dikasih (saat test), pakai yang palsu (mock). Pola ini bikin kelas bisa dites tanpa Firebase asli."*

**Blok: `initialize()` (baris 32-44) — FCM**
→ *"Inisialisasi notifikasi. `requestPermission` minta izin notif ke OS. `onMessage.listen` nangani pesan
saat app terbuka (foreground). Dibungkus try-catch, kalau gagal lempar Exception Bahasa Indonesia."*

**Blok: `getToken()` + `subscribeToTopic()` (baris 47-64)**
→ *"`getToken` ambil token unik device — backend pakai ini buat nembak notif ke 1 HP. `subscribeToTopic`
daftarin device ke topik broadcast — backend kirim ke nama topik, semua device pelanggan terima."*

**Blok: `sendTelegramMessage` (baris 75-95)**
→ *"Kirim notif ke host lewat Telegram. Susun pesan pakai `buildTelegramMessage`, lalu kirim ke backend
lewat `ApiClient`. Perhatikan komentar: param `phoneNumber` sebenarnya diisi Telegram chat id — namanya
tetap `phoneNumber` biar cocok sama kontrak interface."*

**Kalau ditanya "kenapa lewat backend, bukan langsung ke Telegram dari app?"**
→ *"Karena bot token itu rahasia. Kalau app panggil Telegram langsung, token harus ditanam di APK dan bisa
dicuri. Backend jadi proxy — token aman di server, app cuma kirim chatId + text."*

**Blok: `buildTelegramMessage` + `escapeHtml` (baris 101-122) — SERING ditanya**
```dart
String escapeHtml(String value) => value
    .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
```
→ *"Fungsi ini menyusun pesan HTML buat Telegram. `escapeHtml` mengubah karakter `&`, `<`, `>` jadi
kode aman. Kenapa? Karena backend kirim dengan mode HTML. Kalau nama tamu ada karakter `<`, tanpa escape
bisa dianggap tag HTML dan merusak/menyuntik format pesan. Ini pencegahan injection."*

**Kalau ditanya "kenapa `buildTelegramMessage` static?"**
→ *"Karena dia pure function — nggak butuh data instance (apiClient/messaging). Static bikin bisa dipanggil
tanpa buat objek, dan gampang dites terisolasi."*

---

### 📁 FILE 4: `csv_export_service.dart` (mungkin dibuka)

**Blok: `buildCsv` (baris 45-71)**
→ *"Fungsi yang menyusun teks CSV. Kalau ada nama lokasi, tulis baris judul dulu. Lalu tulis header
(8 kolom), terus loop tiap tamu jadi satu baris. Telepon & waktu diformat lewat `Formatters` (pakai intl).
Tiap field lewat `_escape` sebelum digabung dengan koma."*

**Blok: `_escape` (baris 74-83) — INTI, sering ditanya**
```dart
final needsQuoting = field.contains(',') || field.contains('"') ||
    field.contains('\n') || field.contains('\r');
if (!needsQuoting) return field;
final escaped = field.replaceAll('"', '""');
return '"$escaped"';
```
→ *"Ini escape CSV mengikuti standar RFC 4180. Kalau field ada koma, tanda kutip, atau newline — dibungkus
tanda kutip ganda, dan kutip di dalamnya digandakan. Ini yang bikin nama seperti 'Budi, S.Kom' tetap jadi
SATU kolom, nggak pecah gara-gara komanya."*

**Kalau ditanya "kenapa `buildCsv` dipisah dari `exportAndShare`?"**
→ *"Separation of concerns. `buildCsv` itu pure (cuma olah string, nggak nyentuh file) jadi bisa dites
tanpa filesystem. `exportAndShare` yang urus tulis file + buka share sheet. Dipisah biar isi CSV mudah diuji."*

**Blok: `exportAndShare` (baris 90-105)**
→ *"Bangun CSV, tulis ke file temp dengan encoding UTF-8 (biar karakter Indonesia nggak rusak), nama file
pakai timestamp biar unik, lalu buka share sheet native lewat `share_plus` dengan tipe `text/csv`."*

---

### 📁 FILE 5: `settings_cubit.dart` (mungkin dibuka — kecil, gampang)

**Blok: konstruktor (baris 15-23)**
```dart
SettingsCubit({required SharedPreferences prefs}) : _prefs = prefs,
  super(SettingsState(
    darkMode: prefs.getBool(AppConstants.keyDarkMode) ?? false,
    notificationsEnabled: prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true,
  ));
```
→ *"Konstruktor Cubit. State awalnya dibaca (hidrasi) dari SharedPreferences — jadi kalau user pernah
nyalain dark mode, pas app dibuka lagi langsung gelap. `?? false` = default kalau belum pernah diset."*

**Blok: `setDarkMode` (baris 26-29)**
```dart
Future<void> setDarkMode(bool value) async {
  await _prefs.setBool(AppConstants.keyDarkMode, value);
  emit(state.copyWith(darkMode: value));
}
```
→ *"Pas user geser switch: simpan nilai ke SharedPreferences (biar bertahan setelah restart), lalu `emit`
state baru. Karena `SettingsCubit` di-provide di root app, emit ini bikin `MaterialApp` rebuild dan ganti
tema SELURUH app."*

**Kalau ditanya "kenapa Cubit, bukan Bloc?"**
→ *"Cubit versi ringkas dari Bloc. Di sini cuma 2 aksi sederhana (toggle bool), jadi bikin kelas Event =
boilerplate berlebih. Cubit langsung panggil method. Tetap patuh aturan 'no setState'."*

**Kalau ditanya "gimana dark mode bisa ganti seluruh app?"**
→ *"`SettingsCubit` di-provide di root (`app.dart`), dan `MaterialApp` dibungkus `BlocBuilder` yang dengerin
cubit itu. Pas `emit`, `MaterialApp` rebuild dengan `themeMode` baru → semua layar ikut ganti tema."*

---

## BAGIAN D — 10 KODE YANG PALING MUNGKIN DITUNJUK (prediksi)

Latih 10 ini sampai lancar — kemungkinan besar salah satunya ditunjuk:

1. **`emit(AuthLoading())`** → "bikin UI tampil loading sebelum proses async."
2. **`on<LoginRequested>(_onLoginRequested)`** → "daftarin: kalau event ini masuk, jalankan fungsi ini."
3. **`context.read<AuthBloc>().add(LoginRequested(...))`** → "kirim event ke BLoC dari UI."
4. **`BlocConsumer` / `BlocBuilder`** → "widget yang dengerin state BLoC & rebuild UI."
5. **`_escape` (CSV)** → "escape RFC 4180 biar koma di nama nggak merusak kolom."
6. **`escapeHtml` (Telegram)** → "cegah injection HTML di pesan."
7. **`prefs.getBool(...) ?? false`** → "baca setting, default false kalau belum ada."
8. **`registerFactory` vs `registerLazySingleton`** → "BLoC factory (baru tiap kali), repo singleton (di-share)."
9. **`Either` / `.fold()`** (di guest) → "Left gagal, Right sukses; fold buat handle keduanya."
10. **`.snapshots()`** (Firestore) → "stream realtime, UI update otomatis kalau data berubah."

---

## BAGIAN E — KALIMAT "KENAPA" (paling sering ditanya "kenapa X bukan Y")

Hafalkan pola jawabnya:

| Ditanya | Jawaban inti |
|---------|-------------|
| Kenapa BLoC bukan setState? | "Pisah logika dari UI, bisa dites, state bisa di-share." |
| Kenapa Cubit bukan Bloc (di Settings)? | "Cuma toggle sederhana, Event class = boilerplate berlebih." |
| Kenapa get_it? | "DI terpusat, bebas context, gampang di-mock saat test." |
| Kenapa BLoC factory bukan singleton? | "BLoC di-close saat layar tutup; singleton yang sudah close = crash." |
| Kenapa Hive bukan SharedPreferences? | "Hive buat data terstruktur/banyak; SharedPreferences buat nilai kecil." |
| Kenapa Telegram bukan WhatsApp? | "Gratis, tanpa verifikasi bisnis Meta." |
| Kenapa notif lewat backend? | "Sembunyikan bot token dari app." |
| Kenapa escape CSV/HTML? | "Cegah data rusak (koma pecah kolom) / injection (tag HTML)." |
| Kenapa Either di Guest, throw di Auth? | "Guest banyak jenis kegagalan yang dibedakan; Auth linear jadi try/catch cukup." |
| Kenapa locationId disimpan sebelum emit? | "Dashboard butuh baca locationId; hindari race condition." |

---

## BAGIAN F — CHECKLIST MENTAL SEBELUM MASUK

- [ ] Tahu 4 file bagianku: `auth_bloc`, `login_screen`, `notification_repository_impl`, `csv_export_service`, `settings_cubit`.
- [ ] Bisa jelasin alur login end-to-end tanpa lihat catatan.
- [ ] Hapal 6 pola di Bagian B (biar bisa baca kode apa pun).
- [ ] Hapal 10 kode di Bagian D.
- [ ] Hapal tabel "kenapa" di Bagian E.
- [ ] Tahu jawaban jujur: "scan & foto ada di form web, app Flutter buat admin."
- [ ] Tahu ranjau: test Export CSV/Excel, package excel & google_fonts belum dipakai.
- [ ] Siap bilang jujur kalau nggak tahu: "konsepnya X, detail spesifik ini bukan bagian saya."

---

*Latihan terbaik: minta teman buka file random, tunjuk baris, kamu jelasin. Ulangi sampai refleks.*
