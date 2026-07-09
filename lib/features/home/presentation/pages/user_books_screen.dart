import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../widgets/home_feature_screen.dart';

class UserBooksScreen extends StatelessWidget {
  const UserBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeFeatureScreen(
      title: LocalizationConstants.homeFeatureUserBooksTitleKey.tr(),
      subtitle: LocalizationConstants.homeFeatureUserBooksSubtitleKey.tr(),
      description: LocalizationConstants.homeFeatureUserBooksDescriptionKey.tr(),
      icon: HugeIcons.strokeRoundedBooks02,
      accentColor: AppColors.forestGreen,
    );
  }
}
