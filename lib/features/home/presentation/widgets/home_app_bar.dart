import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

enum _HomeProfileMenuAction { profile, cart, sellBook }

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
        ? LocalizationConstants.appNameKey.tr()
        : firstName.trim();
    final Color headerTextColor = context.isDark
        ? AppColors.primary300
        : AppColors.libraryGreen;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.spacing16,
      title: Text(
        LocalizationConstants.homeGreetingKey.tr(
          namedArgs: <String, String>{'name': resolvedFirstName},
        ),
        style: AppTextStyles.h3.copyWith(fontSize: 22, color: headerTextColor),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpacing.spacing16),
          child: PopupMenuButton<_HomeProfileMenuAction>(
            tooltip: LocalizationConstants.homeDrawerProfileKey.tr(),
            offset: const Offset(0, AppSpacing.spacing10),
            position: PopupMenuPosition.under,
            color: context.appCard,
            elevation: 8,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radius8),
            ),
            constraints: const BoxConstraints(minWidth: 170, maxWidth: 190),
            onSelected: (_HomeProfileMenuAction action) =>
                _onMenuSelected(context, action),
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_HomeProfileMenuAction>>[
                  _menuItem(
                    context,
                    value: _HomeProfileMenuAction.profile,
                    label: LocalizationConstants.homeDrawerProfileKey.tr(),
                    icon: HugeIcons.strokeRoundedUser,
                  ),
                  _menuItem(
                    context,
                    value: _HomeProfileMenuAction.cart,
                    label: LocalizationConstants.homeNavCartKey.tr(),
                    icon: HugeIcons.strokeRoundedShoppingCart01,
                    showNotificationDot: true,
                  ),
                  _menuItem(
                    context,
                    value: _HomeProfileMenuAction.sellBook,
                    label: LocalizationConstants.homeProfileMenuSellBookKey
                        .tr(),
                    icon: HugeIcons.strokeRoundedStore01,
                    showAddBadge: true,
                  ),
                ],
            child: _ProfileAvatar(
              profileImage: profileImage,
              profileImageIsFile: profileImageIsFile,
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<_HomeProfileMenuAction> _menuItem(
    BuildContext context, {
    required _HomeProfileMenuAction value,
    required String label,
    required List<List<dynamic>> icon,
    bool showNotificationDot = false,
    bool showAddBadge = false,
  }) {
    return PopupMenuItem<_HomeProfileMenuAction>(
      value: value,
      height: 46,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appTextSecondary,
              ),
            ),
          ),
          _MenuIcon(
            icon: icon,
            showNotificationDot: showNotificationDot,
            showAddBadge: showAddBadge,
          ),
        ],
      ),
    );
  }

  void _onMenuSelected(BuildContext context, _HomeProfileMenuAction action) {
    switch (action) {
      case _HomeProfileMenuAction.profile:
        context.pushTo(RouteNames.settings);
        return;
      case _HomeProfileMenuAction.cart:
        context.pushTo(RouteNames.cart);
        return;
      case _HomeProfileMenuAction.sellBook:
        context.showSuccessSnackBar(
          message: Message(
            title: LocalizationConstants.homeProfileMenuSellBookKey.tr(),
            value: LocalizationConstants.homeFeatureUnderDevelopmentKey.tr(),
          ),
        );
    }
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profileImage,
    required this.profileImageIsFile,
  });

  final String? profileImage;
  final bool profileImageIsFile;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = profileImage?.trim().isNotEmpty ?? false;
    final Color avatarColor = context.isDark
        ? AppColors.primary300
        : AppColors.primary600;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.appSubtleSurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.error500, width: 1.6),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? AppImage(
                  profileImage!,
                  isFile: profileImageIsFile,
                  fit: BoxFit.cover,
                  errorWidget: _avatarPlaceholder(avatarColor),
                )
              : _avatarPlaceholder(avatarColor),
        ),
        PositionedDirectional(
          end: -1,
          bottom: 1,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarPlaceholder(Color color) {
    return Center(
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedUser,
        color: color,
        size: 23,
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon({
    required this.icon,
    required this.showNotificationDot,
    required this.showAddBadge,
  });

  final List<List<dynamic>> icon;
  final bool showNotificationDot;
  final bool showAddBadge;

  @override
  Widget build(BuildContext context) {
    final Color color = context.isDark
        ? AppColors.primary300
        : AppColors.libraryGreen;

    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Center(
            child: HugeIcon(icon: icon, color: color, size: 23),
          ),
          if (showNotificationDot)
            const PositionedDirectional(
              end: 1,
              top: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 6, height: 6),
              ),
            ),
          if (showAddBadge)
            PositionedDirectional(
              end: -1,
              bottom: -1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.appCard,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 12, color: color),
              ),
            ),
        ],
      ),
    );
  }
}
