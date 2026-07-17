import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/styles/text_styles.dart';

/// Phone number field with a leading UAE flag, country code divider, and
/// number input. Styled to match the rounded outlined [ProfileTextField].
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.countryCode,
    required this.phoneNumber,
    required this.onPhoneNumberChanged,
  });

  final String countryCode;
  final String phoneNumber;
  final ValueChanged<String> onPhoneNumberChanged;

  static const double _borderWidth = 1.2;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void didUpdateWidget(covariant PhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phoneNumber != widget.phoneNumber &&
        _controller.text != widget.phoneNumber) {
      _controller.text = widget.phoneNumber;
      _controller.selection = TextSelection.collapsed(
        offset: widget.phoneNumber.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.profileFieldHeight,
      child: TextFormField(
        controller: _controller,
        onChanged: widget.onPhoneNumberChanged,
        keyboardType: TextInputType.phone,
        style: AppTextStyles.bodyMedium.copyWith(
          color: context.appTextPrimary,
        ),
        decoration: InputDecoration(
          labelText: LocalizationConstants.profileEditPhoneNumberKey.tr(),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: context.appTextSecondary,
          ),
          filled: true,
          fillColor: context.appCard,
          contentPadding: const EdgeInsetsDirectional.only(
            start: AppSpacing.spacing12,
            end: AppSpacing.spacing18,
            top: AppSpacing.spacing18,
            bottom: AppSpacing.spacing18,
          ),
          prefixIcon: _buildPrefix(context),
          prefixIconConstraints: const BoxConstraints(minWidth: 108),
          border: _outlineBorder(context.appBorder),
          enabledBorder: _outlineBorder(context.appBorder),
          focusedBorder: _outlineBorder(context.colors.primary),
        ),
      ),
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      borderSide: BorderSide(
        color: color,
        width: PhoneNumberField._borderWidth,
      ),
    );
  }

  Widget _buildPrefix(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: AppSpacing.spacing14),
        const Text(
          '🇦🇪',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(width: AppSpacing.spacing6),
        Text(
          widget.countryCode,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: context.appTextPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.spacing10),
        Container(
          width: 1,
          height: AppSpacing.spacing24,
          color: context.appBorder,
        ),
        const SizedBox(width: AppSpacing.spacing10),
      ],
    );
  }
}
