import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';

class PdfPageCounterBadge extends StatelessWidget {
  const PdfPageCounterBadge({
    required this.currentPage,
    required this.pageCount,
    super.key,
  });

  final int? currentPage;
  final int? pageCount;

  @override
  Widget build(BuildContext context) {
    final int? total = pageCount;
    if (total == null || total <= 0) {
      return const SizedBox.shrink();
    }

    final int page = (currentPage ?? 1).clamp(1, total).toInt();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appSubtleSurface,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(color: context.appBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing8,
          vertical: AppSpacing.spacing4,
        ),
        child: Text(
          '$page / $total',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.isDark ? AppColors.primary300 : AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
