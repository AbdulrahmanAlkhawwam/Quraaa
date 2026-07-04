import 'package:flutter/material.dart';

import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_radius.dart';
import 'profile_avatar_illustration.dart';

/// Large rounded preview card that shows the avatar over the selected
/// background color.
class ProfilePreviewCard extends StatelessWidget {
  const ProfilePreviewCard({
    super.key,
    required this.backgroundColor,
  });

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: AppDimensions.profilePreviewHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radius20),
      ),
      child: const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ProfileAvatarIllustration(),
        ),
      ),
    );
  }
}
