import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';

class PdfPageNumberLabel extends StatelessWidget {
  const PdfPageNumberLabel({
    required this.pageIndex,
    required this.pageCount,
    super.key,
  });

  final int pageIndex;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        '${pageIndex + 1} / $pageCount',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}
