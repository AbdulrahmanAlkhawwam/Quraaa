import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class ExplorerPermissionButton extends StatelessWidget {
  const ExplorerPermissionButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    super.key,
  });

  static const double _height = 40;
  static const Color _primaryColor = Color(0xFF5BB235);
  static const Color _outlineColor = Color(0xFFCBEFC4);

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isPrimary ? _primaryColor : Colors.transparent,
          foregroundColor:
              isPrimary ? AppColors.surfaceLight : AppColors.textPrimary,
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: _outlineColor),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.explorerTitle().copyWith(
            fontSize: isPrimary ? 17 : 16,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1),
        ),
      ),
    );
  }
}
