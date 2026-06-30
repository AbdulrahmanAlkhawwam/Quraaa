import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import 'text_styles.dart';

AppBarTheme appBarStyle() => AppBarTheme(
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  shadowColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  // centerTitle: true,
  titleSpacing: AppSpacing.spacing24,
  toolbarHeight: 64,
  iconTheme: const IconThemeData(color: AppColors.primary50),
  actionsIconTheme: const IconThemeData(color: AppColors.primary50),
  titleTextStyle: AppTextStyles.appBarTitle.copyWith(
    color: AppColors.primary50,
  ),
);
