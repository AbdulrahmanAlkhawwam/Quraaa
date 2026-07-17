import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../widgets/home_feature_screen.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeFeatureScreen(
      title: LocalizationConstants.homeFeatureStoresTitleKey.tr(),
      subtitle: LocalizationConstants.homeFeatureStoresSubtitleKey.tr(),
      description: LocalizationConstants.homeFeatureStoresDescriptionKey.tr(),
      icon: HugeIcons.strokeRoundedStore01,
      accentColor: AppColors.primary600,
    );
  }
}
