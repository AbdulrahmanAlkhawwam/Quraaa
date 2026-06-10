import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/local_directory_snapshot.dart';

class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({
    required this.breadcrumbs,
    required this.onSelected,
    super.key,
  });

  final List<LocalPathSegment> breadcrumbs;
  final ValueChanged<LocalPathSegment> onSelected;

  @override
  Widget build(BuildContext context) {
    if (breadcrumbs.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final LocalPathSegment segment = breadcrumbs[index];
          final bool isLast = index == breadcrumbs.length - 1;

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: isLast ? null : () => onSelected(segment),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                segment.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLast ? AppColors.secondary : AppColors.textMuted,
                      fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.textMuted,
              size: 22,
            ),
          );
        },
        itemCount: breadcrumbs.length,
      ),
    );
  }
}
