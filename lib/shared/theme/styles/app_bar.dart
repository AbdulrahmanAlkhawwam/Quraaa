import 'package:flutter/material.dart';

import '../app_spacing.dart';
import 'text_styles.dart';

AppBarTheme appBarStyle(ColorScheme colors) => AppBarTheme(
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  shadowColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  titleSpacing: AppSpacing.spacing24,
  toolbarHeight: 64,
  iconTheme: IconThemeData(color: colors.onSurface),
  actionsIconTheme: IconThemeData(color: colors.onSurface),
  titleTextStyle: AppTextStyles.appBarTitle.copyWith(
    color: colors.onSurface,
  ),
);
