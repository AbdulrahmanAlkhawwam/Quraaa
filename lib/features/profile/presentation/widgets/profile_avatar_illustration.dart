import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../shared/theme/app_dimensions.dart';

/// Avatar illustration used inside the profile preview card.
class ProfileAvatarIllustration extends StatelessWidget {
  const ProfileAvatarIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.avatarIllustrationHeight,
      child: SvgPicture.asset(
        AppIcons.man,
        width: AppDimensions.avatarIllustrationWidth,
        height: AppDimensions.avatarIllustrationHeight,
        fit: BoxFit.contain,
      ),
    );
  }
}
