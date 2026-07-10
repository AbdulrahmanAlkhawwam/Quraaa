import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quraaa/shared/extensions/app_context.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';

/// Floating pill-style bottom navigation bar for the home screen.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final Color shadowColor =
        context.isDark ? Colors.black : AppColors.primary900;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.spacing16,
        0,
        AppSpacing.spacing16,
        AppSpacing.spacing20,
      ),
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(AppSpacing.spacing8),
        decoration: BoxDecoration(
          color: AppColors.primary600,
          borderRadius: BorderRadius.circular(AppRadius.radius40),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor.withValues(alpha: context.isDark ? 0.34 : 0.18),
              blurRadius: 28,
              spreadRadius: -6,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: currentIndex == 0 ? 2 : 1,
              child: _NavItem(
                icon: HugeIcons.strokeRoundedHome04,
                activeIcon: HugeIcons.strokeRoundedHome01,
                label: LocalizationConstants.homeNavHomeKey.tr(),
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            Expanded(
              flex: currentIndex == 1 ? 2 : 1,
              child: _NavItem(
                icon: HugeIcons.strokeRoundedStore04,
                activeIcon: HugeIcons.strokeRoundedStore01,
                label: LocalizationConstants.homeNavLibrariesKey.tr(),
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
            Expanded(
              flex: currentIndex == 2 ? 3 : 1,
              child: _NavItem(
                icon: HugeIcons.strokeRoundedBooks01,
                activeIcon: HugeIcons.strokeRoundedBooks02,
                label: LocalizationConstants.homeNavUserBooksKey.tr(),
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ),
            Expanded(
              flex: currentIndex == 3 ? 3 : 1,
              child: _NavItem(
                icon: HugeIcons.strokeRoundedAudioBook04,
                activeIcon: HugeIcons.strokeRoundedAudioBook04,
                label: LocalizationConstants.homeNavAudioBookKey.tr(),
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ),
            Expanded(
              flex: currentIndex == 4 ? 2 : 1,
              child: _NavItem(
                icon: HugeIcons.strokeRoundedShoppingCart01,
                activeIcon: HugeIcons.strokeRoundedShoppingCart01,
                label: LocalizationConstants.homeNavCartKey.tr(),
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final List<List<dynamic>> activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        context.isDark ? AppColors.primary300 : AppColors.primary600;

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 56,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? AppSpacing.spacing14 : AppSpacing.spacing10,
            vertical: AppSpacing.spacing8,
          ),
          decoration: BoxDecoration(
            color: isActive ? context.appCard : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.radius32),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedScale(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                scale: isActive ? 1.08 : 1,
                child: HugeIcon(
                  icon: isActive ? activeIcon : icon,
                  color: isActive ? activeColor : AppColors.card,
                  size: 25,
                ),
              ),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        axisAlignment: -1,
                        child: child,
                      ),
                    );
                  },
                  child: isActive
                      ? Padding(
                          key: ValueKey<String>(label),
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.spacing8,
                          ),
                          child: Transform.translate(
                            offset: const Offset(0, 10),
                            child: Text(
                              label,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: activeColor,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey<String>('inactive')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}