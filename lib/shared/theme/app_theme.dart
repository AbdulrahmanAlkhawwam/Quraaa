import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTextStyles.textTheme(),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.settingsActiveGreenDark,
        secondary: AppColors.settingsHeader,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.settingsTextDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTextStyles.textTheme(),
    );
  }
}
