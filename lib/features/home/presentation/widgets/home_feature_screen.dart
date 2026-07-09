import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class HomeFeatureScreen extends StatelessWidget {
  const HomeFeatureScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final String description;
  final List<List<dynamic>> icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
        leading: IconButton(
          onPressed: () => context.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          title,
          style: AppTextStyles.appBarTitle.copyWith(
            color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: context.isDark
                ? <Color>[AppColors.neutralBackgroundDark, AppColors.surfaceDark]
                : <Color>[AppColors.neutralBackground, AppColors.primary50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spacing16),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.radius32),
                    border: Border.all(color: accentColor.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(
                          icon: icon,
                          color: accentColor,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              subtitle,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: context.appTextSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing4),
                            Text(
                              title,
                              style: AppTextStyles.h3.copyWith(
                                color: context.appTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing24),
                Text(
                  description,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: context.appTextSecondary,
                    height: 1.45,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.onboardingButtonHeight,
                  child: FilledButton(
                    onPressed: () => context.goTo(RouteNames.home),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: AppColors.card,
                    ),
                    child: Text(LocalizationConstants.homeFeatureBackToHomeKey.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
