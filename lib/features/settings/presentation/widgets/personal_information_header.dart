import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/styles/text_styles.dart';
import '../../../profile/presentation/pages/edit_profile_screen.dart';
import 'profile_image_card.dart';

/// Sliver header for the Personal Information screen.
///
/// Mirrors the Settings screen's SliverAppBar: green background, rounded
/// bottom corners, back arrow, centered title, edit action, and the profile
/// avatar inside the flexibleSpace.
class PersonalInformationHeader extends StatelessWidget {
  const PersonalInformationHeader({super.key, this.avatarUrl});

  final String? avatarUrl;

  static const double _toolbarHeight = 64;
  static const double _expandedHeight = 244;
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: _expandedHeight,
      toolbarHeight: _toolbarHeight,
      pinned: true,
      backgroundColor: AppColors.primary50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.radius40),
          bottomRight: Radius.circular(AppRadius.radius40),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          color: AppColors.libraryGreen,
          size: _iconSize,
        ),
      ),
      centerTitle: true,
      title: Text(
        'Me',
        style: AppTextStyles.h3.copyWith(
          color: AppColors.libraryGreen,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _openEditProfile(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedEdit03,
            color: AppColors.libraryGreen,
            size: _iconSize,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ProfileImageCard(avatarUrl: avatarUrl),
      ),
    );
  }

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }
}
