import 'package:flutter/material.dart';

abstract class AppTextStyles {
  static const String displayFont = 'Thmanyah Serif Display';
  static const String sansFont = 'Thmanyah Sans';

  static const TextStyle h1 = TextStyle(
    fontFamily: displayFont,
    fontSize: 48,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: displayFont,
    fontSize: 40,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w500, // Medium
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sansFont,
    fontSize: 18,
    fontWeight: FontWeight.w400, // Regular
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sansFont,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sansFont,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sansFont,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w500, // Medium
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: displayFont,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
  );

  static TextTheme textTheme() {
    return const TextTheme(
      displayLarge: h1,
      displayMedium: h2,
      displaySmall: h3,
      headlineLarge: h4,
      headlineMedium: titleLarge,
      headlineSmall: titleMedium,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: buttonSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: buttonMedium,
      labelMedium: buttonSmall,
      labelSmall: caption,
    );
  }
}

