import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_shadows.dart';

class PdfScrollToTopButton extends StatelessWidget {
  const PdfScrollToTopButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.elevation1,
      ),
      child: FloatingActionButton.small(
        heroTag: 'pdf-reader-scroll-top',
        tooltip: 'Top',
        onPressed: onPressed,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.surfaceLight,
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedArrowUp01,
          color: AppColors.surfaceLight,
          size: 22,
        ),
      ),
    );
  }
}
