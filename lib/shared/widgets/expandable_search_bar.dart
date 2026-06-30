import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/styles/text_styles.dart';

class ExpandableSearchBar extends StatelessWidget {
  const ExpandableSearchBar({
    super.key,
    required this.openBuilder,
    this.title = 'Search',
    this.subtitle = 'Find settings, books, and more',
    this.backgroundColor = AppColors.primary50,
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
    this.height = 56,
    this.leadingIcon = HugeIcons.strokeRoundedSearch01,
    this.borderColor = AppColors.primary100,
  });

  final WidgetBuilder openBuilder;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final EdgeInsetsGeometry margin;
  final double height;
  final List<List<dynamic>> leadingIcon;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<void>(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 500),
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return GestureDetector(
          onTap: openContainer,
          child: Container(
            height: height,
            margin: margin,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.radius40),
              border: Border.all(color: borderColor),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary900.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(width: AppSpacing.spacing20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary700,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: leadingIcon,
                      color: AppColors.primary500,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing12),
              ],
            ),
          ),
        );
      },
      openBuilder: (BuildContext context, VoidCallback closeContainer) {
        return openBuilder(context);
      },
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius40),
      ),
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      closedColor: backgroundColor,
      openColor: AppColors.neutralBackground,
      middleColor: AppColors.neutralBackground,
      closedElevation: 0,
      openElevation: 0,
    );
  }
}
