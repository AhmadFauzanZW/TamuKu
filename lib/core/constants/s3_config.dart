/// Contabo S3 Storage configuration.
/// Credentials injected via --dart-define at build time.
/// DO NOT commit real credentials to git.
class S3Config {
  S3Config._();

  /// Contabo S3 endpoint (Asia - Singapore)
  static const String endPoint = 'sin1.contabostorage.com';

  /// Bucket name for guest photos
  static const String bucketName = 'tamuku';

  /// Use SSL
  static const bool useSsl = true;

  // ─── Credentials via --dart-define ──────────────────────────────
  // Usage: flutter build apk --dart-define=S3_ACCESS_KEY=xxx --dart-define=S3_SECRET_KEY=yyy
  static const String accessKey = String.fromEnvironment(
    'S3_ACCESS_KEY',
    defaultValue: '',
  );

  static const String secretKey = String.fromEnvironment(
    'S3_SECRET_KEY',
    defaultValue: '',
  );

  /// Base URL for public access to uploaded files.
  static String get publicBaseUrl => 'https://$endPoint/$bucketName';
}
