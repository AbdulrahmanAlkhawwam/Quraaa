import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';

import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/styles/text_styles.dart';

/// Rounded outlined text field used in the Edit Profile form.
class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.keyboardType,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  static const double _borderWidth = 1.2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.profileFieldHeight,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: AppTextStyles.bodyMedium.copyWith(
          color: context.appTextPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffixIcon: suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: context.appTextSecondary,
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
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
