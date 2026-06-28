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
  static const Color neutralBackgroundDark = Color(0xFF121612);
  static const Color surfaceDark = Color(0xFF1A2118);
  static const Color cardDark = Color(0xFF20281D);
  static const Color textPrimaryDark = Color(0xFFF3F6EF);
  static const Color textSecondaryDark = Color(0xFFC5CEC0);
  static const Color textTertiaryDark = Color(0xFF8D9788);
  static const Color outlineDark = Color(0xFF34412F);

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

  // Edit Profile / Avatar
  static const Color editProfileBackground = Color(0xFFF7F7F5);
  static const Color editProfileTitle = Color(0xFF243B18);
  static const Color editProfileSectionTitle = Color(0xFF2D3A27);
  static const Color editProfileHint = Color(0xFF8A9A84);
  static const Color editProfileBorder = Color(0xFFBED6AE);
  static const Color avatarTabBackground = Color(0xFFF4F6F1);
  static const Color avatarTabSelected = Color(0xFFE8F2DE);
  static const Color avatarDefaultBackground = Color(0xFFDCE9D4);

  /// Two-row palette used for the avatar background selector.
  static const List<List<Color>> avatarBackgroundPalette = <List<Color>>[
    <Color>[
      Color(0xFFEF8E8F),
      Color(0xFFF0A486),
      Color(0xFFEDAF86),
      Color(0xFFEDBA84),
      Color(0xFFEBD577),
      Color(0xFF8FD19E),
      Color(0xFF79CAC5),
    ],
    <Color>[
      Color(0xFF74C7CF),
      Color(0xFF74C4DD),
      Color(0xFF73A9DD),
      Color(0xFF9A95DD),
      Color(0xFFC584D7),
      Color(0xFFC9B4A2),
      Color(0xFFB5A79A),
    ],
  ];

  // Backward compatibility mappings
  static const Color primary = primary600;
  static const Color secondary = forestGreen;
  static const Color backgroundLight = neutralBackground;
  static const Color surfaceLight = surface;
  static const Color backgroundDark = neutralBackground;
  static const Color surfaceDarkLightCompat = surface;
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

final ColorScheme darkColors = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.primary400,
  onPrimary: AppColors.libraryGreen,
  primaryContainer: AppColors.primary800,
  onPrimaryContainer: AppColors.primary50,
  secondary: AppColors.primary500,
  onSecondary: AppColors.libraryGreen,
  error: AppColors.error500,
  onError: AppColors.card,
  surface: AppColors.surfaceDark,
  onSurface: AppColors.textPrimaryDark,
  onSurfaceVariant: AppColors.textSecondaryDark,
  outline: AppColors.primary800,
  shadow: Colors.black54,
);
