import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import '../app_text_styles.dart';

OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colors) {
  return OutlinedButtonThemeData(
    style:
        OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: AppColors.primary200, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius32),
          ),
          textStyle: AppTextStyles.buttonLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed))
              return AppColors.primary700.withOpacity(0.1);
            if (states.contains(WidgetState.hovered))
              return AppColors.primary700.withOpacity(0.05);
            return null;
          }),
        ),
  );
}
