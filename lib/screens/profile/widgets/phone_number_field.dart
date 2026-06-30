import 'package:flutter/material.dart';

import '../../../shared/theme/styles/text_styles.dart';

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

  static const double _height = 64;
  static const double _radius = 16;
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
      height: PhoneNumberField._height,
      child: TextFormField(
        controller: _controller,
        onChanged: widget.onPhoneNumberChanged,
        keyboardType: TextInputType.phone,
        style: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF243B18),
        ),
        decoration: InputDecoration(
          labelText: 'Phone Number',
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF8A9A84),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.only(
            left: 12,
            right: 18,
            top: 18,
            bottom: 18,
          ),
          prefixIcon: _buildPrefix(),
          prefixIconConstraints: const BoxConstraints(minWidth: 108),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PhoneNumberField._radius),
            borderSide: const BorderSide(
              color: Color(0xFFBED6AE),
              width: PhoneNumberField._borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PhoneNumberField._radius),
            borderSide: const BorderSide(
              color: Color(0xFFBED6AE),
              width: PhoneNumberField._borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PhoneNumberField._radius),
            borderSide: const BorderSide(
              color: Color(0xFF243B18),
              width: PhoneNumberField._borderWidth,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrefix() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 14),
        const Text(
          '🇦🇪',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 6),
        Text(
          widget.countryCode,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF243B18),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 1,
          height: 24,
          color: const Color(0xFFBED6AE),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
