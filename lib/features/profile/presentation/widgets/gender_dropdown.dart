import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/styles/text_styles.dart';

/// Dropdown field for gender that matches the rounded outlined style of
/// [ProfileTextField].
class GenderDropdown extends StatelessWidget {
  const GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const double _borderWidth = 1.2;

  static final List<String> _optionKeys = <String>[
    LocalizationConstants.profileEditGenderMaleKey,
    LocalizationConstants.profileEditGenderFemaleKey,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.profileFieldHeight,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: LocalizationConstants.profileEditGenderKey.tr(),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.editProfileHint,
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing18,
            vertical: AppSpacing.spacing18,
          ),
          border: _outlineBorder(AppColors.editProfileBorder),
          enabledBorder: _outlineBorder(AppColors.editProfileBorder),
          focusedBorder: _outlineBorder(AppColors.editProfileTitle),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.spacing12),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              color: AppColors.editProfileTitle,
              size: 20,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const SizedBox.shrink(),
            dropdownColor: AppColors.card,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.editProfileTitle,
            ),
            items: _optionKeys.map((String key) {
              final String label = key.tr();
              return DropdownMenuItem<String>(
                value: label,
                child: Text(label),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      borderSide: BorderSide(
        color: color,
        width: _borderWidth,
      ),
    );
  }
}
