import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
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
        color: context.appSubtleSurface,
        shape: BoxShape.circle,
        border: Border.all(color: context.appCard, width: _borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? AppImage(
              imagePath,
              fit: BoxFit.cover,
              isFile: !isNetworkImage,
              placeholder: _buildShimmer(context),
              errorWidget: _buildFallback(context),
            )
          : _buildFallback(context),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.appSubtleSurface,
      highlightColor: context.appCard,
      child: Container(
        width: _size,
        height: _size,
        color: context.appSubtleSurface,
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Center(
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedUser,
        color: context.isDark ? AppColors.primary300 : AppColors.primary500,
        size: _iconSize,
      ),
    );
  }
}
