import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import '../app_text_styles.dart';

ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colors) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary600,
      foregroundColor: AppColors.card,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius32),
      ),
      textStyle: AppTextStyles.buttonMedium,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) return AppColors.primary800;
        if (states.contains(WidgetState.hovered)) return AppColors.primary700;
        return null;
      }),
    ),
  );
}
