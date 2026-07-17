import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../../../shared/models/message.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/styles/text_styles.dart';

/// Side drawer for additional navigation from the home screen.
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.appCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(AppRadius.radius32),
          bottomEnd: Radius.circular(AppRadius.radius32),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: context.appSubtleSurface,
                      borderRadius: BorderRadius.circular(AppRadius.radius16),
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: AppColors.primary600,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          LocalizationConstants.homeDrawerWelcomeKey.tr(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.appTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocalizationConstants.homeDrawerUserKey.tr(),
                          style: AppTextStyles.h3.copyWith(
                            color: context.appTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing32),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.spacing16),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedHome01,
                label: LocalizationConstants.homeNavHomeKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedUser,
                label: LocalizationConstants.homeDrawerProfileKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  context.goTo(RouteNames.profile);
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedBookmark01,
                label: LocalizationConstants.homeDrawerBookmarksKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  _showComingSoon(
                    context,
                    LocalizationConstants.homeDrawerBookmarksKey.tr(),
                  );
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedLibrary,
                label: LocalizationConstants.homeDrawerLibraryKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  context.goTo(RouteNames.libraries);
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedStore01,
                label: LocalizationConstants.homeDrawerStoresKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  context.goTo(RouteNames.stores);
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedBooks02,
                label: LocalizationConstants.homeNavUserBooksKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  context.goTo(RouteNames.userBooks);
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedAudioBook04,
                label: LocalizationConstants.homeNavAudioBookKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  context.goTo(RouteNames.audioBooks);
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedShoppingCart01,
                label: LocalizationConstants.homeNavCartKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  context.goTo(RouteNames.cart);
                },
              ),
              const SizedBox(height: AppSpacing.spacing16),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.spacing16),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedSettings01,
                label: LocalizationConstants.homeDrawerSettingsKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  context.pushTo(RouteNames.settings);
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedHelpCircle,
                label: LocalizationConstants.homeDrawerHelpSupportKey.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  _showComingSoon(
                    context,
                    LocalizationConstants.homeDrawerHelpSupportKey.tr(),
                  );
                },
              ),
              const Spacer(),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedLogout02,
                label: LocalizationConstants.homeDrawerLogoutKey.tr(),
                iconColor: AppColors.error500,
                textColor: AppColors.error500,
                onTap: () {
                  Navigator.of(context).pop();
                  unawaited(_logout(context));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await sl<StorageService>().clearAll();
    if (context.mounted) {
      context.goTo(RouteNames.auth);
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    context.showSuccessSnackBar(
      message: Message(
        title: LocalizationConstants.profileComingSoonTitleKey.tr(),
        value: LocalizationConstants.profileComingSoonMessageKey.tr(
          namedArgs: <String, String>{'feature': feature},
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: HugeIcon(
          icon: icon,
          color: iconColor ?? (context.isDark ? AppColors.primary300 : AppColors.primary600),
          size: 22,
        ),
        title: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: textColor ?? context.appTextPrimary,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius12),
        ),
      ),
    );
  }
}
