import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'injection_container.dart' as di;
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const TamuKuApp());
}
