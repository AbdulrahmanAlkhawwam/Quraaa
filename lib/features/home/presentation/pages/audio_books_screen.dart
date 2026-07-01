import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/shared.dart';
import '../widgets/home_feature_screen.dart';

class AudioBooksScreen extends StatelessWidget {
  const AudioBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeFeatureScreen(
      title: 'Audio Book',
      subtitle: 'Listen on the go',
      description:
          'Open your audio library, continue playback, and switch between narrations without losing your place.',
      icon: HugeIcons.strokeRoundedAudioBook04,
      accentColor: AppColors.woodBrown,
    );
  }
}
