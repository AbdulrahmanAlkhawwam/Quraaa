import 'package:flutter/material.dart';
import 'package:quraaa/shared/shared.dart';

import 'app_colors.dart';
import 'styles/text_styles.dart';
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
      scaffoldBackgroundColor: AppColors.neutralBackground,
      cardColor: AppColors.card,
      dividerColor: AppColors.primary100,
      colorScheme: lightColors,
      textTheme: AppTextStyles.textTheme(),
      appBarTheme: appBarStyle(),
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
    return light();
  }
}
