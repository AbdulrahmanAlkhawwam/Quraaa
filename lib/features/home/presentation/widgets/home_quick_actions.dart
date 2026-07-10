import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../shared/shared.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      child: Column(
        children: <Widget>[
          _HomeQuickActionTile(
            title: 'home.actions.browse_files'.tr(),
            icon: HugeIcons.strokeRoundedFolderOpen,
            accentColor: AppColors.primary600,
            onTap: () => context.pushTo(RouteNames.explorer),
          ),
          const SizedBox(height: AppSpacing.spacing10),
          _HomeQuickActionTile(
            title: 'home.actions.ask_assistant'.tr(),
            icon: HugeIcons.strokeRoundedSparkles,
            accentColor: AppColors.warning500,
            onTap: () => context.pushTo(RouteNames.bookAssistant),
          ),
        ],
      ),
    );
  }
}

class _HomeQuickActionTile extends StatelessWidget {
  const _HomeQuickActionTile({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final List<List<dynamic>> icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(AppRadius.radius8);
    final Color foreground = context.isDark
        ? AppColors.primary50
        : AppColors.libraryGreen;
    final Color borderColor = context.isDark
        ? accentColor.withValues(alpha: 0.30)
        : accentColor.withValues(alpha: 0.16);
    final Color iconBackground = context.isDark
        ? accentColor.withValues(alpha: 0.18)
        : accentColor.withValues(alpha: 0.12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          child: Ink(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.spacing14,
              AppSpacing.spacing12,
              AppSpacing.spacing12,
              AppSpacing.spacing12,
            ),
            decoration: BoxDecoration(
              color: context.appCard,
              borderRadius: borderRadius,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(AppRadius.radius8),
                  ),
                  child: HugeIcon(
                    icon: icon,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing8),
                HugeIcon(
                  icon: context.isRTL
                      ? HugeIcons.strokeRoundedArrowLeft01
                      : HugeIcons.strokeRoundedArrowRight01,
                  color: context.appTextTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}