import 'package:flutter/material.dart';
import '../app_spacing.dart';
import 'text_styles.dart';

TextButtonThemeData textButtonTheme(ColorScheme colors) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: colors.primary,
      disabledForegroundColor: colors.onSurface.withAlpha(97),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing8,
      ),
      textStyle: AppTextStyles.titleMedium,
    ).copyWith(
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
