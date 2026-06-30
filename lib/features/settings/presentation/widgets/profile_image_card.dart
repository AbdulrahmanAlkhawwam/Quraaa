import 'package:flutter/material.dart';

import 'profile_avatar.dart';

/// Profile image area used inside the [PersonalInformationHeader].
///
/// Mirrors the avatar placement from the Settings screen's SliverAppBar
/// flexibleSpace: 80 logical pixels above the avatar and 24 below it.
class ProfileImageCard extends StatelessWidget {
  const ProfileImageCard({super.key, this.avatarUrl});

  final String? avatarUrl;

  static const double _avatarTopSpacing = 80;
  static const double _avatarBottomSpacing = 24;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: _avatarTopSpacing),
        ProfileAvatar(imagePath: avatarUrl),
        const SizedBox(height: _avatarBottomSpacing),
      ],
    );
  }
}
