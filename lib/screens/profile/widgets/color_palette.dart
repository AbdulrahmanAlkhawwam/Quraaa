import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_dimensions.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_spacing.dart';

/// Two-row color palette for selecting the avatar background color.
class ColorPalette extends StatelessWidget {
  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  static const double _horizontalSpacing = AppSpacing.spacing16;
  static const double _verticalSpacing = AppSpacing.spacing14;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AppColors.avatarBackgroundPalette.map((List<Color> row) {
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
      width: AppDimensions.profileSwatchSize,
      height: AppDimensions.profileSwatchSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.radius10),
        border: isSelected
            ? Border.all(
                color: AppColors.editProfileTitle,
                width: 2.5,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.radius10),
        ),
      ),
    );
  }
}
