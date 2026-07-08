import 'package:flutter/foundation.dart';

/// Application-wide constants for TamuKu.
abstract final class AppConstants {
  static const String appName = 'TamuKu';
  static const String appTagline = 'Buku Tamu Digital';
  static const String guestsCollection = 'guests';
  static const String locationsCollection = 'locations';
  static const String hostsCollection = 'hosts';
  static const String fieldGuestId = 'guestId';
  static const String fieldName = 'name';
  static const String fieldPhone = 'phone';
  static const String fieldEmail = 'email';
  static const String fieldKeperluan = 'keperluan';
  static const String fieldKeperluanLainnya = 'keperluanLainnya';
  static const String fieldInstansi = 'instansi';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldCheckInPhotoUrl = 'checkInPhotoUrl';
  static const String fieldCheckOutPhotoUrl = 'checkOutPhotoUrl';
  static const String fieldLocationId = 'locationId';
  static const String fieldCheckInTime = 'checkInTime';
  static const String fieldCheckOutTime = 'checkOutTime';
  static const String fieldHostPhone = 'hostPhone';
  static const String fieldStatus = 'status';
  static const String fieldAddress = 'address';
  static const String fieldAdminId = 'adminId';
  static const List<String> keperluanOptions = [
    'Meeting',
    'Personal',
    'Kantor',
    'Pengiriman',
    'Lainnya',
  ];
  static const String statusCheckedIn = 'checked_in';
  static const String statusCheckedOut = 'checked_out';
  static const String roleAdmin = 'admin';
  static const String roleHost = 'host';
  static const String loginTitle = 'Masuk sebagai Admin';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String loginButton = 'Masuk';
  static const String loginWithGoogle = 'Masuk dengan Google';
  static const String dashboardTitle = 'Dashboard';
  static const String guestListTitle = 'Daftar Tamu';
  static const String qrGeneratorTitle = 'QR Code Lokasi';
  static const String settingsTitle = 'Pengaturan';
  static const String scanTitle = 'Scan QR';
  static const String scanSubtitle = 'Scan QR untuk isi buku tamu';
  static const String formTitle = 'Isi Buku Tamu';
  static const String nameLabel = 'Nama Lengkap';
  static const String phoneLabel = 'No. WhatsApp';
  static const String keperluanLabel = 'Keperluan';
  static const String instansiLabel = 'Instansi (opsional)';
  static const String submitButton = 'Kirim';
  static const String checkoutButton = 'Saya Pulang';
  static const String thankYouTitle = 'Terima kasih!';
  static const String thankYouMessage = 'Data kunjungan Anda sudah tercatat.';
  static const String checkoutTitle = 'Konfirmasi Check-Out';
  static const String checkoutMessage =
      'Tekan tombol di bawah untuk mencatat waktu kepulangan Anda.';
  static const String qrNotFoundTitle = 'QR Code Tidak Dikenal';
  static const String qrNotFoundMessage =
      'QR tidak valid atau sudah kedaluwarsa. Silakan hubungi resepsionis.';
  static const String scanAgainButton = 'Scan Ulang';
  static const String searchHint = 'Cari nama tamu...';
  static const String filterToday = 'Hari Ini';
  static const String filterThisWeek = 'Minggu Ini';
  static const String filterAll = 'Semua';
  static const String statusActive = 'Aktif';
  static const String statusReturned = 'Pulang';
  static const String statusPending = 'Menunggu';
  static const String locationNameLabel = 'Nama Lokasi';
  static const String addressLabel = 'Alamat';
  static const String hostPhoneLabel = 'No. WhatsApp Host';
  static const String whatsappNotificationLabel = 'Notifikasi Telegram';
  static const String darkModeLabel = 'Mode Gelap';
  static const String logoutButton = 'Keluar';
  static const String printButton = 'Unduh / Cetak Poster';
  static const String manualInputButton = 'Input Kode Manual';
  static const String cameraInstruction = 'Arahkan kamera ke QR Code';
  static const String statTodayGuests = 'Tamu Hari Ini';
  static const String statActiveGuests = 'Tamu Aktif';
  static const String chartTitle = 'Kunjungan 7 Hari Terakhir';
  static const String actionGuestList = 'Daftar Tamu';
  static const String actionQRCode = 'QR Code';
  static const String actionExportCSV = 'Export CSV';

  // ─── Export ────────────────────────────────────────────────────────
  static const String actionExportExcel = 'Export Excel';
  static const String exportSuccess = 'Berhasil mengekspor data tamu';
  static const String exportNoData = 'Tidak ada data untuk diekspor';

  // ─── Sort ──────────────────────────────────────────────────────────
  static const String sortNewest = 'Terbaru';
  static const String sortOldest = 'Terlama';
  static const String sortByName = 'Nama A-Z';

  // ─── Preview ───────────────────────────────────────────────────────
  static const String previewTitle = 'Pratinjau Data Tamu';
  static const String previewSave = 'Simpan';
  static const String previewShare = 'Bagikan';
  static const String previewClose = 'Tutup';
  static const String previewTotalRows = 'Total: %d data tamu';
  static const String nameRequired = 'Nama wajib diisi';
  static const String nameTooShort = 'Nama minimal 2 karakter';
  static const String phoneRequired = 'No. WhatsApp wajib diisi';
  static const String phoneInvalid = 'Format nomor tidak valid';
  static const String emailInvalid = 'Format email tidak valid';
  static const String keperluanRequired = 'Pilih keperluan kunjungan';
  static const String keyDarkMode = 'darkMode';
  static const String keyNotificationsEnabled = 'notificationsEnabled';
  static const String keyLocationId = 'locationId';
  static const String keyHostId = 'hostId';
  static const int qrCodeExpiryMinutes = 1440;
  static const int autoRefreshSeconds = 30;

  // ─── Local Storage (Hive) ─────────────────────────────────────────
  /// Hive box name for cached guest data
  static const String boxNameGuests = 'guests';

  /// Hive box name for cached location data
  static const String boxNameLocations = 'locations';

  /// Hive box name for sync queue operations
  static const String boxNameSyncQueue = 'sync_queue';

  /// Hive box name for the cached authenticated user (offline session)
  static const String boxNameAuth = 'auth';

  // ─── Storage (Contabo S3) ──────────────────────────────────────────
  /// Maximum file size for guest photos (5MB)
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024;

  /// Allowed image MIME types for guest photos
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  // ─── Backend API ──────────────────────────────────────────────────
  /// Contabo VPS backend base URL
  /// Otomatis pakai localhost di debug, production URL di release
  static String get backendBaseUrl => kDebugMode
      ? 'http://localhost:3000'
      : 'https://tamuku.chronaxis.site';

  /// API key untuk backend authentication (x-api-key header)
  /// Harus sama dengan API_KEY di backend .env
  static const String backendApiKey = 'tamuku-dev-key-2026';

  // ─── Firebase / Auth ────────────────────────────────────────────────
  /// Google Sign-In Web Client ID dari Firebase Console
  static const String googleWebClientId =
      '762093911458-u891nq74tvdh8jcg9n8p40ieq1oitolg.apps.googleusercontent.com';

  // ─── Checkout Screen Strings ────────────────────────────────────
  /// Guest data card title on checkout screen
  static const String guestDataTitle = 'Data Tamu';

  /// Duration card title on checkout screen
  static const String visitDuration = 'Durasi Kunjungan';

  /// Already checked-out status text
  static const String alreadyCheckedOut = 'Tamu sudah check-out';

  /// Label: Nama
  static const String labelName = 'Nama';

  /// Label: Keperluan
  static const String labelKeperluan = 'Keperluan';

  /// Label: Instansi
  static const String labelInstansi = 'Instansi';

  /// Label: Waktu Check-in
  static const String labelCheckInTime = 'Waktu Check-in';

  // ─── Error Screen Strings ───────────────────────────────────────
  /// Error screen default title
  static const String errorTitle = 'Terjadi Kesalahan';

  /// Error screen default message
  static const String errorMessage = 'Silakan coba lagi.';

  /// Retry button text
  static const String retryButton = 'Coba Lagi';

  // ─── Confirmation Screen Strings ────────────────────────────────
  /// Back button text
  static const String backButton = 'Kembali';

  // ─── Web Guest URL ────────────────────────────────────────────────
  /// Base URL for the web-based guest check-in page
  /// Served by Contabo backend at /guest/
  static String get guestWebUrl => kDebugMode
      ? 'http://localhost:3000/guest'
      : 'https://tamuku.chronaxis.site/guest';

  // ─── Telegram ────────────────────────────────────────────────────
  /// Telegram Bot username (tanpa @)
  static const String telegramBotUsername = 'TamuKuBot';

  // ─── Auth UI Strings ─────────────────────────────────────────────
  static const String emailRequired = 'Email wajib diisi';
  static const String passwordRequired = 'Password wajib diisi';
  static const String passwordTooShort = 'Password minimal 6 karakter';
  static const String loginSuccessMessage = 'Berhasil masuk sebagai admin';
  static const String showPassword = 'Tampilkan password';
  static const String hidePassword = 'Sembunyikan password';
  static const String googleNotAvailable =
      'Login dengan Google belum tersedia. Segera hadir.';
  static const String orDivider = 'atau';

  // ─── Settings UI Strings ─────────────────────────────────────────
  static const String sectionProfileLocation = 'PROFIL LOKASI';
  static const String sectionPreferences = 'PREFERENSI';
  static const String exportFailed = 'Gagal mengekspor data';
  static const String logoutConfirmTitle = 'Keluar Akun';
  static const String logoutConfirmMessage = 'Apakah Anda yakin ingin keluar?';
  static const String cancelButton = 'Batal';

  // ─── Dashboard UI Strings ──────────────────────────────────────
  static const String dashboardSummaryTitle = 'Ringkasan Hari Ini';
  static const String dashboardChartPlaceholder =
      'Area Grafik Batang fl_chart\n(Akan disinkronkan dengan data riil)';
  static const String dashboardRecentTitle = 'Aktivitas Tamu Terbaru';
  static const String dashboardViewAll = 'Lihat Semua';

  // ─── Guest List UI Strings ─────────────────────────────────────
  static const String guestListSearchHint = 'Cari nama tamu atau keperluan...';
  static const String filterCheckedIn = 'Check-In';
  static const String filterCompleted = 'Selesai';

  // ─── QR Generator UI Strings ───────────────────────────────────
  static const String qrInstruction =
      'Silakan tunjukkan QR Code di bawah ini kepada tamu untuk dipindai '
      'saat melakukan check-in.';
  static const String qrShareButton = 'Bagikan QR Code';
  static const String qrGeneratorDescription =
      'Tampilkan QR code untuk check-in tamu';
}
