import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../shared/services/s3_storage_service.dart';

/// Temporary connection test utilities.
/// Delete after all services confirmed working.
class FirebaseTest {
  /// Test Firestore read/write
  static Future<void> testFirestore() async {
    final db = FirebaseFirestore.instance;
    try {
      await db.collection('test').doc('hello').set({
        'message': 'TamuKu connected!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      final doc = await db.collection('test').doc('hello').get();
      final data = doc.data();
      if (data != null) {
        // ignore: avoid_print
        print('✅ Firestore connected! Message: ${data['message']}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Firestore error: $e');
    }
  }

  /// Test Firebase Auth status
  static Future<void> testAuth() async {
    final auth = FirebaseAuth.instance;
    try {
      final user = auth.currentUser;
      if (user != null) {
        // ignore: avoid_print
        print('✅ User login: ${user.email}');
      } else {
        // ignore: avoid_print
        print('⚠️ Belum ada user login');
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Auth error: $e');
    }
  }

  /// Test Contabo S3 connection
  static Future<void> testS3() async {
    try {
      final service = S3StorageService();
      final healthy = await service.healthCheck();
      if (healthy) {
        // ignore: avoid_print
        print('✅ S3 Storage connected!');
      } else {
        // ignore: avoid_print
        print('❌ S3 bucket not reachable');
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ S3 error: $e');
    }
  }

  /// Test FCM token retrieval
  static Future<void> testFCM() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      // ignore: avoid_print
      print('✅ FCM Token: $token');
    } catch (e) {
      // ignore: avoid_print
      print('❌ FCM error: $e');
    }
  }

  /// Run all tests
  static Future<void> runAll() async {
    // ignore: avoid_print
    print('=== Firebase Connection Tests ===');
    await testFirestore();
    await testAuth();
    await testS3();
    await testFCM();
    // ignore: avoid_print
    print('=== Tests Complete ===');
  }
}
