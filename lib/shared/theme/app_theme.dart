import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Thmanyah Sans',
      scaffoldBackgroundColor: AppColors.neutralBackground,
      cardColor: AppColors.card,
      dividerColor: AppColors.primary100,
      
      colorScheme: const ColorScheme(
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
      ),

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

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.card,
          elevation: 0,
          textStyle: AppTextStyles.buttonMedium,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primary800;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary700;
            }
            return null;
          }),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.card,
          textStyle: AppTextStyles.buttonMedium,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primary800;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary700;
            }
            return null;
          }),
        ),
      ),

      textTheme: AppTextStyles.textTheme(),
    );
  }

  static ThemeData dark() {
    // Fallback to light theme to disable dark mode completely for now
    return light();
  }
}

