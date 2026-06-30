import 'package:flutter/material.dart';

import '../bloc/edit_profile_bloc.dart';

/// Two-row color palette for selecting the avatar background color.
class ColorPalette extends StatelessWidget {
  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  static const double _colorSize = 44;
  static const double _colorRadius = 10;
  static const double _horizontalSpacing = 16;
  static const double _verticalSpacing = 14;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: editProfileColorPalette.map((List<Color> row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: _verticalSpacing),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildRow(row),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildRow(List<Color> row) {
    final List<Widget> children = <Widget>[];

    for (int index = 0; index < row.length; index++) {
      if (index > 0) {
        children.add(const SizedBox(width: _horizontalSpacing));
      }

      children.add(
        _ColorSwatch(
          color: row[index],
          isSelected: row[index] == selectedColor,
          onTap: () => onColorSelected(row[index]),
        ),
      );
    }

    return children;
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: ColorPalette._colorSize,
      height: ColorPalette._colorSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ColorPalette._colorRadius),
        border: isSelected
            ? Border.all(
                color: const Color(0xFF243B18),
                width: 2.5,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ColorPalette._colorRadius),
        ),
      ),
    );
  }
}
