import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_colors_dark.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// TamuKu complete theme configuration.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary900,
      onPrimary: Colors.white,
      secondary: AppColors.primary700,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.display,
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      titleMedium: AppTextStyles.h3,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      labelSmall: AppTextStyles.caption,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary900,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        textStyle: AppTextStyles.button,
        elevation: 1,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary900,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        side: const BorderSide(color: AppColors.primary900, width: 1.5),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary900),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary900, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDisabled),
      labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary900,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      labelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      showCheckmark: false,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary700;
        }
        return AppColors.border;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary100;
        }
        return AppColors.borderLight;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary900,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: CircleBorder(),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      elevation: 4,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColorsDark.primary900,
      onPrimary: Colors.black,
      secondary: AppColorsDark.primary700,
      onSecondary: Colors.black,
      surface: AppColorsDark.surface,
      onSurface: AppColorsDark.textPrimary,
      error: AppColorsDark.accentRed,
      onError: Colors.black,
      outline: AppColorsDark.border,
    ),
    scaffoldBackgroundColor: AppColorsDark.background,
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.display,
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      titleMedium: AppTextStyles.h3,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      labelSmall: AppTextStyles.caption,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsDark.primary900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.primary900,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        textStyle: AppTextStyles.button.copyWith(color: Colors.black),
        elevation: 1,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColorsDark.surfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColorsDark.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.primary900, width: 2),
      ),
      hintStyle: AppTextStyles.body.copyWith(color: AppColorsDark.textDisabled),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: AppColorsDark.primary900,
      side: const BorderSide(color: AppColorsDark.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.primary700;
        }
        return AppColorsDark.border;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.primary50;
        }
        return AppColorsDark.borderLight;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColorsDark.border,
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColorsDark.primary900,
      foregroundColor: Colors.black,
      elevation: 3,
      shape: CircleBorder(),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColorsDark.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
  );
}
