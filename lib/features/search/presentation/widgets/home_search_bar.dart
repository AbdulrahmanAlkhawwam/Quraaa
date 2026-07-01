import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../../shared/shared.dart';

/// A reusable search bar component for the home screen.
///
/// Matches the pill-shaped, light-green search bar shown in the design
/// with a primary label, secondary label, and a circular search icon.
///
/// Example usage:
/// ```dart
/// HomeSearchBar(
///   primaryText: 'History',
///   secondaryText: 'Mathematical',
///   onTap: () => openSearch(),
/// )
/// ```
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.primaryText,
    this.secondaryText,
    this.onTap,
    this.backgroundColor,
    this.margin,
    this.height = 56,
  });

  /// The main label shown in green (e.g. "History").
  final String? primaryText;

  /// The subtitle shown in lighter text (e.g. "Mathematical").
  final String? secondaryText;

  /// Callback when the search bar is tapped.
  final VoidCallback? onTap;

  /// Background color of the search bar. Defaults to [AppColors.primary50].
  final Color? backgroundColor;

  /// Margin around the search bar. Defaults to horizontal 16.
  final EdgeInsetsGeometry? margin;

  /// Height of the search bar. Defaults to 56.
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: margin ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
            ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary50,
          borderRadius: BorderRadius.circular(AppRadius.radius40),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary900.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: AppSpacing.spacing20),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (primaryText != null && primaryText!.isNotEmpty)
                    Text(
                      primaryText!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (secondaryText != null && secondaryText!.isNotEmpty)
                    Text(
                      secondaryText!,
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
            // Circular search icon button
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
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: AppColors.primary400,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spacing12),
          ],
        ),
      ),
    );
  }
}
