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

  // Overlay Alphas
  static const int overlayLightAlpha = 100;
  static const int overlayMediumAlpha = 120;

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

  // File / explorer semantics
  static const Color textMuted = textTertiary;
  static const Color borderLight = primary100;
  static const Color pdfLabel = error500;
  static const Color pdfSurface = Color(0xFFFBEAEA);
  static const Color pdfFold = error500;
  static const Color unsupportedFileLabel = textTertiary;
  static const Color unsupportedFileSurface = surface;
  static const Color unsupportedFileFold = textTertiary;
  static const Color folderTab = primary600;
  static const Color folderBody = primary300;
  static const Color noteSurface = Color(0xFFFFF8E1);
  static const Color noteBorder = warning500;

  // Backward compatibility mappings
  static const Color primary = primary600;
  static const Color secondary = forestGreen;
  static const Color backgroundLight = neutralBackground;
  static const Color surfaceLight = surface;
  static const Color backgroundDark = neutralBackground;
  static const Color surfaceDarkLightCompat = surface;
  // static const Color primary = Color(0xFF16324F);
  // static const Color secondary = Color(0xFF2D6A4F);
  // static const Color backgroundLight = Color(0xFFF6F7FB);
  // static const Color surfaceLight = Color(0xFFFFFFFF);
  // static const Color backgroundDark = Color(0xFF0E1116);
  // static const Color surfaceDark = Color(0xFF181D25);
  // static const Color textPrimary = Color(0xFF243629);
  // static const Color textSecondary = Color(0xFF536458);
  // static const Color textMuted = Color(0xFFB7BEB8);
  // static const Color borderLight = Color(0xFFE3E8E2);
  // static const Color folderTab = Color(0xFF92D174);
  // static const Color folderBody = Color(0xFFB5E1A1);
  // static const Color pdfSurface = Color(0xFFF2938C);
  // static const Color pdfFold = Color(0xFFF5BBB6);
  // static const Color pdfLabel = Color(0xFFD33A2C);
  // static const Color unsupportedFileSurface = Color(0xFFEAF4E6);
  // static const Color unsupportedFileFold = Color(0xFFDDEED7);
  // static const Color unsupportedFileLabel = Color(0xFFD2E6CC);
  // static const Color noteSurface = Color(0xFFF1FAEC);
  // static const Color noteBorder = Color(0xFFDDEED7);

  // Settings feature colors.
  static const Color settingsBackground = Color(0xFFFFFFFF);
  static const Color settingsBackgroundDark = Color(0xFF0D160F);
  static const Color settingsSheetDark = Color(0xFF111D13);
  static const Color settingsHeader = Color(0xFF72D6E5);
  static const Color settingsHeaderDark = Color(0xFF356F78);
  static const Color settingsCardBackground = Color(0xFFF0FAEC);
  static const Color settingsCardBackgroundDark = Color(0xFF1A2B18);
  static const Color settingsActiveGreen = Color(0xFF4D9138);
  static const Color settingsActiveGreenDark = Color(0xFF95D977);
  static const Color settingsAccentGreen = Color(0xFF78C85B);
  static const Color settingsInactiveIcon = Color(0xFFA7D99B);
  static const Color settingsInactiveIconDark = Color(0xFF628F5A);
  static const Color settingsTextDark = Color(0xFFEAF6E7);
  static const Color settingsTextMutedDark = Color(0xFFAFC3AA);
  static const Color settingsBorder = Color(0xFFC9EDBE);
  static const Color settingsBorderDark = Color(0xFF385B34);
  static const Color settingsToggleInactive = Color(0xFFD8F0D3);
  static const Color settingsLogout = Color(0xFFED4032);
  static const Color settingsLogoutDark = Color(0xFFD84D40);
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
