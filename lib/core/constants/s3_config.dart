/// Contabo S3 Storage configuration.
/// Replace placeholder values with real credentials.
/// DO NOT commit real credentials to git.
class S3Config {
  S3Config._();

  /// Contabo S3 endpoint (Asia - Singapore)
  static const String endpoint = 'sg.contabostorage.com';

  /// Bucket name for guest photos
  static const String bucketName = 'tamuku-guest-photos';

  /// Region (Contabo uses empty string for default)
  static const String region = '';

  /// Use SSL
  static const bool useSsl = true;

  // ─── Credentials (replace with your Contabo S3 API keys) ─────────
  /// Access Key from Contabo Customer Control Panel → Object Storage → API Keys
  static const String accessKey = 'YOUR_CONTABO_ACCESS_KEY';

  /// Secret Key from Contabo Customer Control Panel → Object Storage → API Keys
  static const String secretKey = 'YOUR_CONTABO_SECRET_KEY';

  /// Base URL for public access to uploaded files.
  /// Format: https://endpoint/bucket
  static String get publicBaseUrl => 'https://$endpoint/$bucketName';
}
