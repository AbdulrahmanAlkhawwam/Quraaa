import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_radius.dart';

/// Simple avatar illustration used inside the profile preview card.
///
/// Built from basic shapes so no external asset is required. The illustration
/// is approximately 170 logical pixels tall and aligned to the bottom center.
class ProfileAvatarIllustration extends StatelessWidget {
  const ProfileAvatarIllustration({super.key});

  static const double _headSize = 72;
  static const double _bodyWidth = 132;
  static const double _bodyHeight = 86;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.avatarIllustrationHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: _headSize,
            height: _headSize,
            decoration: const BoxDecoration(
              color: AppColors.editProfileTitle,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: _bodyWidth,
            height: _bodyHeight,
            decoration: BoxDecoration(
              color: AppColors.editProfileTitle,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_bodyWidth / 2),
                topRight: Radius.circular(_bodyWidth / 2),
                bottomLeft: const Radius.circular(AppRadius.radius16),
                bottomRight: const Radius.circular(AppRadius.radius16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
