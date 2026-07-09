import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/extensions/app_context.dart';

import '../../../../shared/theme/styles/text_styles.dart';

/// Section title displayed above the personal information card.
class PersonalDataSection extends StatelessWidget {
  const PersonalDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      LocalizationConstants.profileEditPersonalDataKey.tr(),
      style: AppTextStyles.h4.copyWith(
        color: context.appTextPrimary,
      ),
    );
  }
}
