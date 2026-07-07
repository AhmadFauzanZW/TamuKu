import 'package:flutter/material.dart';

/// Dark mode overrides — applied when ThemeMode.dark is active.
abstract final class AppColorsDark {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2D2D2D);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF616161);
  static const Color border = Color(0xFF404040);
  static const Color borderLight = Color(0xFF333333);

  static const Color primary900 = Color(0xFF4CAF50);
  static const Color primary700 = Color(0xFF66BB6A);
  static const Color primary50 = Color(0xFF1B3A1D);

  static const Color accentRed = Color(0xFFEF5350);
  static const Color accentRedLight = Color(0xFF3E2020);
  static const Color accentAmber = Color(0xFFFFD54F);
  static const Color accentAmberLight = Color(0xFF3E3520);

  // ─── Semantic colors (dark) ──────────────────────────────────────
  static const Color success = Color(0xFF66BB6A);
  static const Color successBg = Color(0xFF1B3A1D);
  static const Color warning = Color(0xFFFFD54F);
  static const Color warningBg = Color(0xFF3E3520);
  static const Color info = Color(0xFF42A5F5);
  static const Color infoBg = Color(0xFF1A2A3E);
}
