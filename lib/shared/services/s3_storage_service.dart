import 'dart:io';
import 'package:minio/minio.dart';
import 'package:minio/io.dart';
import '../../core/constants/s3_config.dart';

/// Service for uploading/downloading files via Contabo S3.
class S3StorageService {
  late final Minio _client;

  S3StorageService() {
    _client = Minio(
      endPoint: S3Config.endpoint,
      useSSL: S3Config.useSsl,
      accessKey: S3Config.accessKey,
      secretKey: S3Config.secretKey,
      region: S3Config.region,
    );
  }

  /// Upload a guest photo to S3.
  /// Returns the public URL of the uploaded file.
  Future<String> uploadGuestPhoto({
    required File imageFile,
    required String guestId,
  }) async {
    final ext = imageFile.path.split('.').last;
    final objectName = 'guests/$guestId.${ext.isNotEmpty ? ext : 'jpg'}';

    await _client.fPutObject(
      S3Config.bucketName,
      objectName,
      imageFile.path,
      onProgress: (bytes) {},
    );

    return '${S3Config.publicBaseUrl}/$objectName';
  }

  /// Delete a guest photo from S3.
  Future<void> deleteGuestPhoto(String objectName) async {
    await _client.removeObject(S3Config.bucketName, objectName);
  }

  /// Check if the storage service is reachable.
  Future<bool> healthCheck() async {
    try {
      await _client.bucketExists(S3Config.bucketName);
      return true;
    } catch (_) {
      return false;
    }
  }
}
