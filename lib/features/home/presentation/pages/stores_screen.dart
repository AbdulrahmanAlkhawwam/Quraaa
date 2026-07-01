import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../widgets/home_feature_screen.dart';
import '../../../../shared/shared.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeFeatureScreen(
      title: 'Stores',
      subtitle: 'Browse the catalog',
      description:
          'Explore the reading store, discover new releases, and find the next book to add to your collection.',
      icon: HugeIcons.strokeRoundedStore01,
      accentColor: AppColors.primary600,
    );
  }
}
