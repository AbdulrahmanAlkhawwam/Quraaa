import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The shared rounded input used across forms, including authentication.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.hintText,
    required this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode,
    this.keyboardType,
    this.height = 48,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final AutovalidateMode? autovalidateMode;
  final TextInputType? keyboardType;
  final double height;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(8));
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        textInputAction: textInputAction,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary900),
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        autovalidateMode: autovalidateMode,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: suffixIcon,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.primary200)),
          enabledBorder: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.primary200)),
          focusedBorder: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.primary600, width: 1.5)),
          errorBorder: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.error500)),
          focusedErrorBorder: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.error500, width: 1.5)),
        ),
      ),
    );
  }
}
