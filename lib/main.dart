import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'app.dart';

/// Firebase Messaging background handler.
/// Must be a top-level function (not in a class).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();
  // ignore: avoid_print
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Emulators disabled — using real Firebase backend (tamuku-6360f)
  // To re-enable, uncomment below and run: firebase emulators:start --only auth,firestore
  // if (kDebugMode) {
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  // }

  await di.init();
  runApp(const TamuKuApp());
}
