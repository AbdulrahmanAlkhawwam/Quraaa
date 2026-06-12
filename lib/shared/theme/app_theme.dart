import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'styles/filled_button.dart';
import 'styles/outlined_button.dart';

abstract class AppTheme {
  static ThemeData light() {
    const ColorScheme colors = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary600,
      onPrimary: AppColors.card,
      primaryContainer: AppColors.primary100,
      onPrimaryContainer: AppColors.primary900,
      secondary: AppColors.forestGreen,
      onSecondary: AppColors.card,
      error: AppColors.error500,
      onError: AppColors.card,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.primary100,
      shadow: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Thmanyah Sans',
      scaffoldBackgroundColor: AppColors.neutralBackground,
      cardColor: AppColors.card,
      dividerColor: AppColors.primary100,
      colorScheme: colors,
      textTheme: AppTextStyles.textTheme(),
      filledButtonTheme: filledButtonTheme(colors),
      outlinedButtonTheme: outlinedButtonTheme(colors),
      dividerTheme: const DividerThemeData(
        color: AppColors.primary100,
        thickness: 1,
        space: 1,
      ),

      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }

  static ThemeData dark() {
    // Fallback to light theme to disable dark mode completely for now
    return light();
  }
}

