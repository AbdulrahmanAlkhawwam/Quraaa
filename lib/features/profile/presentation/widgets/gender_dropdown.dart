import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
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
            color: context.appTextSecondary,
          ),
          filled: true,
          fillColor: context.appCard,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing18,
            vertical: AppSpacing.spacing18,
          ),
          border: _outlineBorder(context.appBorder),
          enabledBorder: _outlineBorder(context.appBorder),
          focusedBorder: _outlineBorder(context.colors.primary),
          suffixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.spacing12),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              color: context.appTextPrimary,
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
            dropdownColor: context.appCard,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.appTextPrimary,
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
