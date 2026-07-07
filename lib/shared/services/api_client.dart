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

  /// Send notification via Telegram Bot API through backend.
  Future<void> sendTelegramNotification({
    required String chatId,
    required String text,
  }) async {
    await _httpPost(
      '/api/notifications/telegram',
      body: {'chatId': chatId, 'text': text},
    );
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

  /// Calls the backend Excel export endpoint and returns the file path.
  Future<String> exportExcel({
    required List<Map<String, dynamic>> guests,
    String? locationName,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('${AppConstants.backendBaseUrl}/api/export/excel'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': AppConstants.backendApiKey,
      },
      body: jsonEncode({
        'guests': guests,
        'locationName': locationName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Export gagal: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Export gagal');
    }

    return data['data']['path'] as String;
  }

  Future<Map<String, dynamic>> _httpPost(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('${AppConstants.backendBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': AppConstants.backendApiKey,
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
