import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/styles/text_styles.dart';

/// Section title displayed above the personal information card.
class PersonalDataSection extends StatelessWidget {
  const PersonalDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Personal Data',
      style: AppTextStyles.h4.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }
}
