import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// A labeled field used on auth screens.
class AuthLabeledField extends StatelessWidget {
  const AuthLabeledField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing12),
        child,
      ],
    );
  }
}

/// A reusable rounded text field used on auth screens.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.hintText,
    required this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.onboardingInputHeight,
      child: TextFormField(
        controller: controller,
        textInputAction: textInputAction,
        obscureText: obscureText,
        textCapitalization: textCapitalization,
        style: AppTextStyles.bodyLarge.copyWith(color: context.appTextPrimary),
        validator: validator,
        onFieldSubmitted: onSubmitted,
        autovalidateMode: autovalidateMode,
        decoration: InputDecoration(hintText: hintText, suffixIcon: suffixIcon),
      ),
    );
  }
}
