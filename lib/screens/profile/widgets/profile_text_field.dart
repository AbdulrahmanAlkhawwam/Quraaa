import 'package:flutter/material.dart';

import '../../../shared/theme/styles/text_styles.dart';

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

  static const double _height = 64;
  static const double _radius = 16;
  static const double _borderWidth = 1.2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF243B18),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffixIcon: suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF8A9A84),
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF8A9A84),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: const BorderSide(
              color: Color(0xFFBED6AE),
              width: _borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: const BorderSide(
              color: Color(0xFFBED6AE),
              width: _borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: const BorderSide(
              color: Color(0xFF243B18),
              width: _borderWidth,
            ),
          ),
        ),
      ),
    );
  }
}
