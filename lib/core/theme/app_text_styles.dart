import 'package:flutter/material.dart';
import 'app_colors.dart';

/// TamuKu Typography Scale
/// Uses system default fonts (Roboto / SF Pro).
abstract final class AppTextStyles {
  // ── Display / Stats ──
  static const TextStyle display = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 56 / 48,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle stats = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  // ── Headings ──
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  // ── Body ──
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  // ── Caption / Overline ──
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 16 / 10,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  // ── Button ──
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: 0.5,
    color: Colors.white,
  );
}
