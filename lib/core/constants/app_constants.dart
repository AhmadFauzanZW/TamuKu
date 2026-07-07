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
  static const String fieldInstansi = 'instansi';
  static const String fieldPhotoUrl = 'photoUrl';
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
  /// Ganti dengan URL production setelah deploy
  static const String backendBaseUrl = 'http://localhost:3000';

  // ─── Firebase / Auth ────────────────────────────────────────────────
  /// Google Sign-In Web Client ID dari Firebase Console
  static const String googleWebClientId =
      '762093911458-u891nq74tvdh8jcg9n8p40ieq1oitolg.apps.googleusercontent.com';

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
}
