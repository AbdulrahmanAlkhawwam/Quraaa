import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_image.dart';

/// Circular avatar used in the Settings screen's SliverAppBar.
///
/// When [imagePath] is provided and points to an existing file or a remote
/// URL, it is displayed as the avatar; otherwise a default user icon is shown.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.imagePath});

  final String? imagePath;

  static const double _size = 140;
  static const double _iconSize = 64;
  static const double _borderWidth = 4;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imagePath != null && imagePath!.isNotEmpty;
    final bool isNetworkImage = hasImage &&
        (imagePath!.startsWith('http://') ||
            imagePath!.startsWith('https://'));

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: AppColors.primary100,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.card, width: _borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? AppImage(
              imagePath,
              fit: BoxFit.cover,
              isFile: !isNetworkImage,
              placeholder: _buildShimmer(),
              errorWidget: _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.primary100,
      highlightColor: AppColors.primary50,
      child: Container(
        width: _size,
        height: _size,
        color: AppColors.primary100,
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedUser,
        color: AppColors.primary500,
        size: _iconSize,
      ),
    );
  }
}
