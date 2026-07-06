import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// HTTP client for Contabo VPS backend API.
class ApiClient {
  final http.Client _httpClient;

  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Generate a presigned S3 upload URL for guest photos.
  Future<Map<String, String>> getUploadUrl(String contentType) async {
    final response = await _httpPost(
      '/api/upload/url',
      body: {'contentType': contentType},
    );
    return {
      'uploadUrl': response['uploadUrl'] as String,
      'fileUrl': response['fileUrl'] as String,
    };
  }

  /// Send FCM push notification via backend.
  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final bodyMap = <String, dynamic>{
      'token': token,
      'title': title,
      'body': body,
    };
    if (data != null) bodyMap['data'] = data;
    await _httpPost('/api/notifications/send', body: bodyMap);
  }

  /// Check backend health.
  Future<bool> healthCheck() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConstants.backendBaseUrl}/health'),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _httpPost(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('${AppConstants.backendBaseUrl}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
