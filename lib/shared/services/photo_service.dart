import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';

/// Service to fetch presigned S3 GET URLs for guest photos.
///
/// S3 bucket is private — raw URLs won't load. This service calls the
/// backend to generate time-limited presigned GET URLs instead.
class PhotoService {
  const PhotoService._();

  /// Converts a raw S3 URL to a presigned GET URL via backend.
  ///
  /// Returns the presigned URL on success, or falls back to [rawUrl]
  /// if the backend call fails (offline, server error, etc.).
  static Future<String> getSignedUrl(String rawUrl) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.backendBaseUrl}/api/guests/photo-url'
        '?url=${Uri.encodeComponent(rawUrl)}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final data = json['data'] as Map<String, dynamic>;
          return data['signedUrl'] as String;
        }
      }
    } catch (_) {
      // Offline or backend unreachable — fall through to raw URL.
    }
    return rawUrl;
  }
}
