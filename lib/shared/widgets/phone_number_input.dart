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
class PhoneNumberInput extends StatefulWidget {
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
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  late String _dialCode;

  static const Map<String, String> _dialCodes = <String, String>{
    'SY': '+963',
    'AE': '+971',
    'BH': '+973',
    'EG': '+20',
    'IQ': '+964',
    'JO': '+962',
    'KW': '+965',
    'LB': '+961',
    'OM': '+968',
    'QA': '+974',
    'SA': '+966',
  };

  @override
  void initState() {
    super.initState();
    _dialCode = widget.initialValue?.dialCode ??
        _dialCodes[widget.initialValue?.isoCode ?? 'SY'] ??
        '+963';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.onboardingInputHeight,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.radius24),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Stack(
        children: [
          InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber value) {
              setState(() {
                _dialCode = value.dialCode ?? _dialCode;
              });
              widget.onInputChanged?.call(value);
            },
            onInputValidated: widget.onInputValidated,
            validator: widget.validator,
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              setSelectorButtonAsPrefixIcon: true,
              useBottomSheetSafeArea: true,
            ),
            countries: widget.countries,
            initialValue: widget.initialValue ?? PhoneNumber(isoCode: 'SY'),
            textFieldController: widget.controller,
            keyboardType: TextInputType.phone,
            textStyle: widget.textStyle ??
                AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
            selectorTextStyle: widget.selectorTextStyle ??
                AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
            inputDecoration: InputDecoration(
              hintText: widget.hintText,
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
            onFieldSubmitted: widget.onFieldSubmitted != null
                ? (String _) => widget.onFieldSubmitted!()
                : null,
          ),
          Positioned(
            left: 80,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Center(
                child: Text(
                  _dialCode,
                  style: widget.selectorTextStyle ??
                      AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 120,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 1,
                height: 24,
                color: AppColors.primary200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
