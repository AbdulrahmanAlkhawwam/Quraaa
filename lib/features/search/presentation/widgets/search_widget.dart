import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../search.dart';

/// A search widget for the home screen that uses [OpenContainer] from the
/// `animations` package to create a smooth "search bar into expanded search"
/// transition animation.
///
/// Wraps [HomeSearchBar] so the visual component can be reused independently.
class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
    this.primaryText = 'History',
    this.secondaryText = 'Mathematical',
  });

  /// The main label shown in the search bar.
  final String primaryText;

  /// The subtitle shown in the search bar.
  final String secondaryText;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<void>(
      // Use fade-through transition for a smooth morph effect.
      transitionType: ContainerTransitionType.fadeThrough,
      // Duration for the open/close animation.
      transitionDuration: const Duration(milliseconds: 500),
      // Closed widget — the search bar shown on the home screen.
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return HomeSearchBar(
          primaryText: primaryText,
          secondaryText: secondaryText,
          onTap: openContainer,
        );
      },
      // Open widget — the full search screen.
      openBuilder: (BuildContext context, VoidCallback closeContainer) {
        return const SearchScreen();
      },
      // Shape of the closed widget.
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius40),
      ),
      // Shape of the open widget (fullscreen).
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      // Color behind the transition.
      closedColor: AppColors.primary50,
      openColor: AppColors.neutralBackground,
      // Elevation for the closed widget.
      closedElevation: 0,
      openElevation: 0,
      middleColor: AppColors.neutralBackground,
    );
  }
}
