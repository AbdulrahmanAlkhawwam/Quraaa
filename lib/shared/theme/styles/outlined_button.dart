import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import 'text_styles.dart';

OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colors) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: colors.onSurface,
      backgroundColor: colors.surface,
      disabledForegroundColor: colors.onSurface.withAlpha(97),
      minimumSize: Size(double.infinity, AppSpacing.spacing48),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius32),
      ),
      textStyle: AppTextStyles.buttonMedium,
      elevation: 0,
    ).copyWith(
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: colors.onSurface.withAlpha(31), width: 1);
        }
        return BorderSide(color: colors.outline, width: 1);
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.primary.withAlpha(31);
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.primary.withAlpha(20);
        }
        return null;
      }),
    ),
  );
}
