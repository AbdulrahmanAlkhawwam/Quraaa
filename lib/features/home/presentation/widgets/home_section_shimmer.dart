import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/shared.dart';

class HomeSectionShimmer extends StatelessWidget {
  const HomeSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final Color baseColor =
        context.isDark ? AppColors.surfaceDark : AppColors.primary100;
    final Color highlightColor =
        context.isDark ? AppColors.neutralBackgroundDark : AppColors.primary50;

    return SizedBox(
      key: const ValueKey<String>('home-books-shimmer'),
      height: 276,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (separatorContext, separatorIndex) =>
            const SizedBox(width: AppSpacing.spacing16),
        itemBuilder: (itemContext, itemIndex) {
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: const _HomeBookCardSkeleton(),
          );
        },
      ),
    );
  }
}

class _HomeBookCardSkeleton extends StatelessWidget {
  const _HomeBookCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 3 / 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.radius16),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing10),
          _bar(width: 124, height: 16),
          const SizedBox(height: AppSpacing.spacing8),
          _bar(width: 88, height: 12),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
      ),
    );
  }
}
