import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'text_styles.dart';

TextButtonThemeData textButtonTheme(ColorScheme colors) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.libraryGreen,
      textStyle: AppTextStyles.titleMedium,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.libraryGreen.withAlpha(25);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.libraryGreen.withAlpha(10);
        }
        return null;
      }),
    ),
  );
}
