import 'package:flutter/material.dart';

import 'app_colors_dark.dart';

/// TamuKu Color System
/// Complete design token palette extracted from mockups.
abstract final class AppColors {
  // ── Primary Green ──
  static const Color primary900 = Color(0xFF1B5E20);
  static const Color primary700 = Color(0xFF2E7D32);
  static const Color primary500 = Color(0xFF43A047);
  static const Color primary100 = Color(0xFFC8E6C9);
  static const Color primary50 = Color(0xFFE8F5E9);

  // ── Neutral ──
  static const Color background = Color(0xFFFAFAF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // ── Accent ──
  static const Color accentRed = Color(0xFFD32F2F);
  static const Color accentRedLight = Color(0xFFFFEBEE);
  static const Color accentAmber = Color(0xFFF9A825);
  static const Color accentAmberLight = Color(0xFFFFF8E1);
  static const Color accentBlue = Color(0xFF4285F4);

  // ── Semantic ──
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningBg = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF4285F4);

  // ─── Theme-aware helpers ──────────────────────────────────────────
  
  /// Returns the appropriate background color based on current theme.
  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.background
          : background;

  /// Returns the appropriate surface color based on current theme.
  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.surface
          : surface;

  /// Returns the appropriate primary text color based on current theme.
  static Color textPrimaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.textPrimary
          : textPrimary;

  /// Returns the appropriate secondary text color based on current theme.
  static Color textSecondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.textSecondary
          : textSecondary;

  /// Returns the appropriate border color based on current theme.
  static Color borderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.border
          : border;

  /// Returns the appropriate primary900 color based on current theme.
  static Color primary900Of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.primary900
          : primary900;

  /// Returns the appropriate primary700 color based on current theme.
  static Color primary700Of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.primary700
          : primary700;

  /// Returns the appropriate disabled text color based on current theme.
  static Color textDisabledOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.textDisabled
          : textDisabled;

  /// Returns the appropriate surface variant color based on current theme.
  static Color surfaceVariantOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.surfaceVariant
          : surfaceVariant;

  /// Returns the appropriate accent red color based on current theme.
  static Color accentRedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.accentRed
          : accentRed;
}
