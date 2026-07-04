import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
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
          color: AppColors.editProfileTitle,
        ),
        decoration: InputDecoration(
          labelText: LocalizationConstants.profileEditPhoneNumberKey.tr(),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.editProfileHint,
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.only(
            left: AppSpacing.spacing12,
            right: AppSpacing.spacing18,
            top: AppSpacing.spacing18,
            bottom: AppSpacing.spacing18,
          ),
          prefixIcon: _buildPrefix(),
          prefixIconConstraints: const BoxConstraints(minWidth: 108),
          border: _outlineBorder(AppColors.editProfileBorder),
          enabledBorder: _outlineBorder(AppColors.editProfileBorder),
          focusedBorder: _outlineBorder(AppColors.editProfileTitle),
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

  Widget _buildPrefix() {
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
            color: AppColors.editProfileTitle,
          ),
        ),
        const SizedBox(width: AppSpacing.spacing10),
        Container(
          width: 1,
          height: AppSpacing.spacing24,
          color: AppColors.editProfileBorder,
        ),
        const SizedBox(width: AppSpacing.spacing10),
      ],
    );
  }
}
