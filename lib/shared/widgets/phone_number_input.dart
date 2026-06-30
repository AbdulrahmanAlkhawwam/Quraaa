import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/styles/text_styles.dart';

/// A styled international phone number input that matches the app's design.
///
/// Wraps [IntlPhoneNumberInput] from the `intl_phone_number_input` package
/// with a white rounded container, a vertical divider between the country
/// selector and the phone text field.
class PhoneNumberInput extends StatelessWidget {
  const PhoneNumberInput({
    super.key,
    this.controller,
    this.initialValue,
    this.countries = const <String>['SY'],
    this.onInputChanged,
    this.onInputValidated,
    this.validator,
    this.autoValidateMode,
    this.onFieldSubmitted,
    this.hintText,
    this.textStyle,
    this.selectorTextStyle,
  });

  final TextEditingController? controller;
  final PhoneNumber? initialValue;
  final List<String> countries;
  final ValueChanged<PhoneNumber>? onInputChanged;
  final ValueChanged<bool>? onInputValidated;
  final String? Function(String?)? validator;
  final AutovalidateMode? autoValidateMode;
  final VoidCallback? onFieldSubmitted;
  final String? hintText;
  final TextStyle? textStyle;
  final TextStyle? selectorTextStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.onboardingInputHeight,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(color: AppColors.primary200, width: 1),
      ),
      child: InternationalPhoneNumberInput(
        onInputChanged: onInputChanged,
        onInputValidated: onInputValidated,
        validator: validator,
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          setSelectorButtonAsPrefixIcon: true,
          useBottomSheetSafeArea: true,
        ),
        countries: countries,
        initialValue: initialValue ?? PhoneNumber(isoCode: 'SY'),
        textFieldController: controller,
        keyboardType: TextInputType.phone,
        textStyle:
            textStyle ??
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        selectorTextStyle:
            selectorTextStyle ??
            AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
        inputDecoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.spacing12,
            AppSpacing.spacing20,
            AppSpacing.spacing20,
            AppSpacing.spacing20,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 120,
            maxWidth: 120,
            minHeight: AppDimensions.onboardingInputHeight,
            maxHeight: AppDimensions.onboardingInputHeight,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        onFieldSubmitted:
            onFieldSubmitted != null ? (String _) => onFieldSubmitted!() : null,
      ),
    );
  }
}
