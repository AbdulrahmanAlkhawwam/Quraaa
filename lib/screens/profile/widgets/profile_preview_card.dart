import 'package:flutter/material.dart';

import 'profile_avatar_illustration.dart';

/// Large rounded preview card that shows the avatar over the selected
/// background color.
class ProfilePreviewCard extends StatelessWidget {
  const ProfilePreviewCard({
    super.key,
    required this.backgroundColor,
  });

  final Color backgroundColor;

  static const double _height = 220;
  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: _height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ProfileAvatarIllustration(),
        ),
      ),
    );
  }
}
