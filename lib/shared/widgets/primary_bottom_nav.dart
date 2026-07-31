import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../config/routes/route_names.dart';
import '../../core/di/injection_container.dart';
import '../../core/error_monitoring/user_context_provider.dart';
import '../../core/localization/localization_constants.dart';
import '../extensions/app_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

typedef HomeNavTap = void Function(int index, String route);

/// Shared primary navigation used by every top-level app destination.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    required this.currentIndex,
    this.isGuest,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final bool? isGuest;
  final HomeNavTap onTap;

  // Keep the cart implementation available for the planned future rollout.
  static const bool _showCart = false;

  @override
  Widget build(BuildContext context) {
    final bool guest =
        isGuest ??
        sl<UserContextProvider>().snapshot.subscriptionStatus != 'active';
    final Color shadowColor = context.isDark
        ? Colors.black
        : AppColors.primary900;
    final String fourthRoute = guest
        ? RouteNames.settings
        : RouteNames.bookAssistant;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: context.appCard,
          borderRadius: BorderRadius.circular(AppRadius.radius40),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor.withValues(
                alpha: context.isDark ? 0.34 : 0.18,
              ),
              blurRadius: 28,
              spreadRadius: -6,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            _destination(
              index: 0,
              route: RouteNames.home,
              icon: HugeIcons.strokeRoundedHome04,
              activeIcon: HugeIcons.strokeRoundedHome01,
              label: LocalizationConstants.homeNavHomeKey.tr(),
            ),
            _destination(
              index: 1,
              route: RouteNames.libraries,
              icon: HugeIcons.strokeRoundedStore04,
              activeIcon: HugeIcons.strokeRoundedStore01,
              label: LocalizationConstants.homeNavLibrariesKey.tr(),
            ),
            _destination(
              index: 2,
              route: RouteNames.userBooks,
              icon: HugeIcons.strokeRoundedBooks01,
              activeIcon: HugeIcons.strokeRoundedBooks02,
              label: LocalizationConstants.homeNavUserBooksKey.tr(),
              activeFlex: 3,
            ),
            _destination(
              index: 3,
              route: fourthRoute,
              icon: guest
                  ? HugeIcons.strokeRoundedSettings01
                  : HugeIcons.strokeRoundedSparkles,
              activeIcon: guest
                  ? HugeIcons.strokeRoundedSettings01
                  : HugeIcons.strokeRoundedSparkles,
              label: guest
                  ? LocalizationConstants.homeNavSettingsKey.tr()
                  : LocalizationConstants.homeNavAiKey.tr(),
              activeFlex: 3,
            ),
            if (_showCart)
              _destination(
                index: 4,
                route: RouteNames.cart,
                icon: HugeIcons.strokeRoundedShoppingCart01,
                activeIcon: HugeIcons.strokeRoundedShoppingCart01,
                label: LocalizationConstants.homeNavCartKey.tr(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _destination({
    required int index,
    required String route,
    required List<List<dynamic>> icon,
    required List<List<dynamic>> activeIcon,
    required String label,
    int activeFlex = 2,
  }) {
    final bool active = currentIndex == index;
    return Expanded(
      flex: active ? activeFlex : 1,
      child: _NavItem(
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        isActive: active,
        onTap: () => onTap(index, route),
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
    final Color activeColor = context.isDark
        ? AppColors.primary300
        : AppColors.primary600;

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: context.isDark ? 0.18 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.radius32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HugeIcon(
                icon: isActive ? activeIcon : icon,
                color: isActive ? activeColor : context.appTextSecondary,
                size: 24,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: isActive
                    ? Padding(
                        key: ValueKey<String>(label),
                        padding: const EdgeInsetsDirectional.only(start: 7),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                            color: activeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey<String>('inactive')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
