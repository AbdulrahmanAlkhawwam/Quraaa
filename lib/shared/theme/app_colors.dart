import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Scale
  static const Color primary50 = Color(0xFFF0F9EC);
  static const Color primary100 = Color(0xFFE1F2D9);
  static const Color primary200 = Color(0xFFD2ECC6);
  static const Color primary300 = Color(0xFFB4DF9F);
  static const Color primary400 = Color(0xFF97D279);
  static const Color primary500 = Color(0xFF79C553);
  static const Color primary600 = Color(0xFF5FAC3A);
  static const Color primary700 = Color(0xFF4A862D);
  static const Color primary800 = Color(0xFF356020);
  static const Color primary900 = Color(0xFF203913);

  // Neutral Scale
  static const Color neutralBackground = Color(0xFFF4F5F1);
  static const Color surface = Color(0xFFE6E8E3);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF24311C);
  static const Color textSecondary = Color(0xFF4A5942);
  static const Color textTertiary = Color(0xFF7C8577);

  // Semantics
  static const Color success500 = Color(0xFF4A8D29);
  static const Color warning500 = Color(0xFFA88032);
  static const Color error500 = Color(0xFFA54747);

  // Special Colors
  static const Color libraryGreen = Color(0xFF163A07);
  static const Color forestGreen = Color(0xFF33641A);
  static const Color leafGreen = Color(0xFF74C14C);
  static const Color woodBrown = Color(0xFF6A4B2A);
  static const Color bookPaper = Color(0xFFF4F5F1);

  // Backward compatibility mappings
  static const Color primary = primary600;
  static const Color secondary = forestGreen;
  static const Color backgroundLight = neutralBackground;
  static const Color surfaceLight = surface;
  static const Color backgroundDark = neutralBackground;
  static const Color surfaceDark = surface;
}

final ColorScheme lightColors = ColorScheme(
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
);
