import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../shared/theme/styles/text_styles.dart';

/// Dropdown field for gender that matches the rounded outlined style of
/// [ProfileTextField].
class GenderDropdown extends StatelessWidget {
  const GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const double _height = 64;
  static const double _radius = 16;
  static const double _borderWidth = 1.2;

  static const List<String> _options = <String>[
    'Male',
    'Female',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Gender',
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: AppTextStyles.bodySmall.copyWith(
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
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              color: const Color(0xFF243B18),
              size: 20,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const SizedBox.shrink(),
            dropdownColor: Colors.white,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF243B18),
            ),
            items: _options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ),
    );
  }
}
