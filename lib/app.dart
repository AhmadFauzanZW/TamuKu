import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

class TamuKuApp extends StatelessWidget {
  const TamuKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(child: Text(AppConstants.appName)),
      ),
    );
  }
}
