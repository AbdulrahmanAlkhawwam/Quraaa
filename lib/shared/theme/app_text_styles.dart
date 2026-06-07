import 'package:flutter/material.dart';

abstract class AppTextStyles {
  static TextTheme textTheme() {
    const String fontFamily = 'Poppins';
    return const TextTheme(
      headlineLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
    );
  }
}
