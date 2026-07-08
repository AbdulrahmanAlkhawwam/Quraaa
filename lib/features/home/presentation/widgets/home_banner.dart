import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

/// Large promotional banner shown below the search bar on the home screen.
class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spacing24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary400, AppColors.primary600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radius24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            LocalizationConstants.homeBannerTitleKey.tr(),
            style: AppTextStyles.h4.copyWith(
              color: AppColors.card,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            LocalizationConstants.homeBannerSubtitleKey.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.card.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }
}
