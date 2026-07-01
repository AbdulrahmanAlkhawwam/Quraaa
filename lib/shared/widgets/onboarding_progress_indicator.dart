import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Dotted progress indicator used during onboarding.
///
/// [activeIndex] is 1-based. Pass [activeIndex] = 1 to highlight the first dot.
class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.activeIndex,
    required this.count,
  });

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (index) {
        final bool active = index == activeIndex - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsetsDirectional.only(
            end: index == count - 1 ? 0 : AppSpacing.spacing8,
          ),
          width: active
              ? AppDimensions.onboardingDotActiveWidth
              : AppDimensions.onboardingDotSize,
          height: AppDimensions.onboardingDotSize,
          decoration: BoxDecoration(
            color: active ? AppColors.primary600 : AppColors.primary100,
            borderRadius: BorderRadius.circular(AppRadius.radius40),
          ),
        );
      }),
    );
  }
}
