import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/styles/text_styles.dart';

/// A single read-only row inside [PersonalDataCard].
///
/// The text is vertically centered and left aligned, matching the row style
/// used throughout the Settings screen.
class PersonalDataRow extends StatelessWidget {
  const PersonalDataRow({
    super.key,
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing20,
        vertical: AppSpacing.spacing16,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
