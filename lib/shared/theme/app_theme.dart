import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'styles/text_styles.dart';
import 'styles/app_bar.dart';
import 'styles/filled_button.dart';
import 'styles/outlined_button.dart';

abstract class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Thmanyah Sans',
      scaffoldBackgroundColor: AppColors.neutralBackground,
      cardColor: AppColors.card,
      dividerColor: AppColors.primary100,
      colorScheme: lightColors,
      textTheme: AppTextStyles.textTheme(),
      appBarTheme: appBarStyle(),
      filledButtonTheme: filledButtonTheme(lightColors),
      outlinedButtonTheme: outlinedButtonTheme(lightColors),
      dividerTheme: const DividerThemeData(
        color: AppColors.primary100,
        thickness: 1,
        space: 1,
      ),

      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }

  static ThemeData dark() {
    // Fallback to light theme to disable dark mode completely for now
    return light();
  }
}
