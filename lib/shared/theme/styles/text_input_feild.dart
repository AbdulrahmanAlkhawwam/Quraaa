import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import 'text_styles.dart';

InputDecorationTheme textInputFeildTheme(ColorScheme colors) {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
    floatingLabelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.primary600),
    helperStyle: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
    errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error500),
    prefixIconColor: AppColors.textTertiary,
    suffixIconColor: AppColors.primary600,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      borderSide: const BorderSide(color: AppColors.primary200, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      borderSide: const BorderSide(color: AppColors.primary200, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      borderSide: const BorderSide(color: AppColors.primary600, width: 1.5),
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
      borderSide: const BorderSide(color: AppColors.surface, width: 1),
    ),
  );
}
