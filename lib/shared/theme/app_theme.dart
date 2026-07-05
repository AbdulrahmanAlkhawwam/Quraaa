import 'package:flutter/material.dart';
import 'package:quraaa/shared/shared.dart';

import 'styles/app_bar.dart';
import 'styles/filled_button.dart';
import 'styles/outlined_button.dart';
import 'styles/text_button.dart';
import 'styles/text_input_feild.dart';

abstract class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Thmanyah Sans',
      // scaffoldBackgroundColor: AppColors.neutralBackground,
      cardColor: AppColors.card,
      dividerColor: AppColors.primary100,
      // colorScheme: lightColors,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTextStyles.textTheme(),
      appBarTheme: appBarStyle(lightColors),
      filledButtonTheme: filledButtonTheme(lightColors),
      outlinedButtonTheme: outlinedButtonTheme(lightColors),
      textButtonTheme: textButtonTheme(lightColors),
      inputDecorationTheme: textInputFeildTheme(lightColors),
      dividerTheme: const DividerThemeData(
        color: AppColors.primary100,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        borderRadius: BorderRadius.circular(AppRadius.radius40),
        linearMinHeight: 8,
        strokeWidth: 8,
        linearTrackColor: AppColors.primary600,
        color: AppColors.primary100,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Thmanyah Sans',
      scaffoldBackgroundColor: AppColors.neutralBackgroundDark,
      cardColor: AppColors.cardDark,
      dividerColor: AppColors.outlineDark,
      colorScheme: darkColors,
      textTheme: AppTextStyles.textTheme().apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      appBarTheme: appBarStyle(darkColors),
      filledButtonTheme: filledButtonTheme(darkColors),
      outlinedButtonTheme: outlinedButtonTheme(darkColors),
      textButtonTheme: textButtonTheme(darkColors),
      inputDecorationTheme: textInputFeildTheme(darkColors),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineDark,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        borderRadius: BorderRadius.circular(AppRadius.radius40),
        linearMinHeight: 8,
        strokeWidth: 8,
        linearTrackColor: AppColors.primary800,
        color: AppColors.primary400,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        // colorScheme: const ColorScheme.dark(
        //   primary: AppColors.settingsActiveGreenDark,
        //   secondary: AppColors.settingsHeader,
        //   surface: AppColors.surfaceDark,
        //   onSurface: AppColors.settingsTextDark,
        // ),
      ),
    );
  }
}
