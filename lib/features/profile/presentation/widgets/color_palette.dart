import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_radius.dart';

/// Two-row color palette for selecting the avatar background color.
class ColorPalette extends StatelessWidget {
  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          _PaletteRow(
            colors: AppColors.avatarBackgroundPalette.first,
            selectedColor: selectedColor,
            onColorSelected: onColorSelected,
          ),
          const SizedBox(height: 18),
          _PaletteRow(
            colors: AppColors.avatarBackgroundPalette.last,
            selectedColor: selectedColor,
            onColorSelected: onColorSelected,
          ),
        ],
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: colors
          .map(
            (Color color) => _ColorSwatch(
              color: color,
              isSelected: color == selectedColor,
              onTap: () => onColorSelected(color),
            ),
          )
          .toList(growable: false),
    );
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
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: AppDimensions.profileSwatchSize,
          height: AppDimensions.profileSwatchSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.radius10),
          ),
        ),
      ),
    );
  }
}
