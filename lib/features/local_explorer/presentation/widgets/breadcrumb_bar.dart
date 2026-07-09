import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
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
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final LocalPathSegment segment = breadcrumbs[index];
          final bool isLast = index == breadcrumbs.length - 1;

          return InkWell(
            borderRadius: BorderRadius.circular(AppRadius.radius8),
            onTap: isLast ? null : () => onSelected(segment),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing4,
                vertical: AppSpacing.spacing4,
              ),
              child: Text(
                segment.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLast
                          ? context.isDark
                              ? AppColors.primary300
                              : AppColors.secondary
                          : context.appTextTertiary,
                      fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4),
            child: HugeIcon(
              icon: context.isRTL ? HugeIcons.strokeRoundedArrowLeft01 : HugeIcons.strokeRoundedArrowRight01,
              color: context.appTextTertiary,
              size: 16,
            ),
          );
        },
        itemCount: breadcrumbs.length,
      ),
    );
  }
}
