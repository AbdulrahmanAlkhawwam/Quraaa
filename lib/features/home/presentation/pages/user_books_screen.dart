import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/shared.dart';
import '../widgets/home_feature_screen.dart';

class UserBooksScreen extends StatelessWidget {
  const UserBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeFeatureScreen(
      title: 'User Books',
      subtitle: 'Your saved library',
      description:
          'Keep track of the books you are reading, the ones you saved, and everything that belongs in your personal shelf.',
      icon: HugeIcons.strokeRoundedBooks02,
      accentColor: AppColors.forestGreen,
    );
  }
}
