import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.firstName = '',
    this.profileImage,
    this.profileImageIsFile = true,
  });

  final String firstName;
  final String? profileImage;
  final bool profileImageIsFile;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final String resolvedFirstName = firstName.trim().isEmpty
        ? LocalizationConstants.homeDrawerUserKey.tr()
        : firstName.trim();
    final bool hasImage = profileImage != null && profileImage!.isNotEmpty;
    final Color headerTextColor =
        context.isDark ? AppColors.primary300 : AppColors.libraryGreen;
    final Color avatarColor =
        context.isDark ? AppColors.primary300 : AppColors.primary600;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.spacing16,
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              LocalizationConstants.homeGreetingKey.tr(
                namedArgs: <String, String>{'name': resolvedFirstName},
              ),
              style: AppTextStyles.h3.copyWith(
                fontSize: 22,
                color: headerTextColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: () => context.pushTo(RouteNames.settings),
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsetsDirectional.only(end: AppSpacing.spacing16),
            decoration: BoxDecoration(
              color: context.appSubtleSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary600, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? AppImage(
                    profileImage!,
                    isFile: profileImageIsFile,
                    fit: BoxFit.cover,
                    errorWidget: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        color: avatarColor,
                        size: 24,
                      ),
                    ),
                  )
                : Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: avatarColor,
                      size: 24,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
