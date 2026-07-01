import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import 'text_styles.dart';

FilledButtonThemeData filledButtonTheme(ColorScheme colors) {
  return FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.surface;
        }
        return colors.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurface.withAlpha(97);
        }
        return colors.onPrimary;
      }),
      minimumSize: WidgetStateProperty.all(
        Size(double.infinity, AppSpacing.spacing48),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing16,
          vertical: AppSpacing.spacing12,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius32),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        AppTextStyles.buttonMedium.copyWith(color: colors.onPrimary),
      ),
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.onPrimary.withAlpha(31);
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.onPrimary.withAlpha(20);
        }
        return null;
      }),
    ),
  );
}
