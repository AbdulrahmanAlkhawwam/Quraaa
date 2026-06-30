import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../shared/extensions/app_context.dart';
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
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadius.radius32),
          bottomRight: Radius.circular(AppRadius.radius32),
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
                      color: AppColors.primary100,
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
                          'Welcome',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quraaa User',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textPrimary,
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
                label: 'Home',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedUser,
                label: 'Profile',
                onTap: () {
                  Navigator.of(context).pop();
                  context.goTo(RouteNames.profile);
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedBookmark01,
                label: 'Bookmarks',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedLibrary,
                label: 'Library',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: AppSpacing.spacing16),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.spacing16),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedSettings01,
                label: 'Settings',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedHelpCircle,
                label: 'Help & Support',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              const Spacer(),
              _DrawerItem(
                icon: HugeIcons.strokeRoundedLogout02,
                label: 'Logout',
                iconColor: AppColors.error500,
                textColor: AppColors.error500,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: HugeIcon(
        icon: icon,
        color: iconColor ?? AppColors.primary600,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius12),
      ),
    );
  }
}
