import 'package:flutter/material.dart';

import 'onboarding_progress_indicator.dart';

/// Dotted step indicator.
///
/// [activeIndex] is 0-based. This widget delegates to
/// [OnboardingProgressIndicator] after converting to a 1-based index.
class StepsIndicator extends StatelessWidget {
  const StepsIndicator({
    super.key,
    required this.activeIndex,
    required this.count,
  });

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return OnboardingProgressIndicator(
      activeIndex: activeIndex + 1,
      count: count,
    );
  }
}
