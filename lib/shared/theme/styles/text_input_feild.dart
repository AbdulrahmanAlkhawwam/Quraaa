import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import 'text_styles.dart';

InputDecorationTheme textInputFeildTheme(ColorScheme colors) {
  return InputDecorationTheme(
    filled: true,
    fillColor: colors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
    labelStyle: AppTextStyles.bodySmall.copyWith(color: colors.onSurfaceVariant),
    floatingLabelStyle: AppTextStyles.bodySmall.copyWith(color: colors.primary),
    helperStyle: AppTextStyles.caption.copyWith(color: colors.onSurfaceVariant),
    errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error500),
    prefixIconColor: colors.onSurfaceVariant,
    suffixIconColor: colors.primary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      borderSide: BorderSide(color: colors.outline, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      borderSide: BorderSide(color: colors.outline, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      borderSide: BorderSide(color: colors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      borderSide: const BorderSide(color: AppColors.error500, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      borderSide: const BorderSide(color: AppColors.error500, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      borderSide: BorderSide(color: colors.outline.withAlpha(80), width: 1),
    ),
  );
}
