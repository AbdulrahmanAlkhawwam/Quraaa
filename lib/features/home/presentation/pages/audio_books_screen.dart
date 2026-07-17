import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../widgets/home_feature_screen.dart';

class AudioBooksScreen extends StatelessWidget {
  const AudioBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeFeatureScreen(
      title: LocalizationConstants.homeFeatureAudioBooksTitleKey.tr(),
      subtitle: LocalizationConstants.homeFeatureAudioBooksSubtitleKey.tr(),
      description: LocalizationConstants.homeFeatureAudioBooksDescriptionKey.tr(),
      icon: HugeIcons.strokeRoundedAudioBook04,
      accentColor: AppColors.woodBrown,
      currentIndex: 3,
    );
  }
}
