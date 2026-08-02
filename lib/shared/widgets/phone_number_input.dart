import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../theme/app_dimensions.dart';
import '../theme/styles/text_styles.dart';

/// An international phone input that uses the same visual treatment as the
/// other authentication text fields.
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: AppDimensions.onboardingInputHeight,
      child: InternationalPhoneNumberInput(
        onInputChanged: onInputChanged,
        onInputValidated: onInputValidated,
        validator: validator,
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          setSelectorButtonAsPrefixIcon: true,
          useBottomSheetSafeArea: true,
          leadingPadding: 12,
          trailingSpace: false,
        ),
        countries: countries,
        initialValue: initialValue ?? PhoneNumber(isoCode: 'SY'),
        textFieldController: controller,
        keyboardType: TextInputType.phone,
        textStyle:
            textStyle ??
            AppTextStyles.bodyLarge.copyWith(color: colors.onSurface),
        selectorTextStyle:
            selectorTextStyle ??
            AppTextStyles.bodyMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
        inputDecoration: InputDecoration(
          hintText: hintText,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 112,
            maxWidth: 112,
            minHeight: AppDimensions.onboardingInputHeight,
            maxHeight: AppDimensions.onboardingInputHeight,
          ),
        ),
        autoValidateMode: autoValidateMode ?? AutovalidateMode.disabled,
        autofillHints: const <String>[AutofillHints.telephoneNumber],
        onFieldSubmitted:
            onFieldSubmitted != null ? (String _) => onFieldSubmitted!() : null,
      ),
    );
  }
}