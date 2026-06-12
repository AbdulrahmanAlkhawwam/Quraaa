import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import '../app_text_styles.dart';

FilledButtonThemeData filledButtonTheme(ColorScheme colors) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary600,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius32),
      ),
      textStyle: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) return AppColors.primary800;
        if (states.contains(WidgetState.hovered)) return AppColors.primary700;
        return null;
      }),
    ),
  );
}
