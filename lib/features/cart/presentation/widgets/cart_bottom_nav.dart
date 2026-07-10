import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class CartBottomNav extends StatelessWidget {
  const CartBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  static const List<_CartNavDestination> _destinations = <_CartNavDestination>[
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedHome04,
      activeIcon: HugeIcons.strokeRoundedHome01,
      labelKey: LocalizationConstants.cartNavHomeKey,
      route: RouteNames.home,
    ),
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedStore04,
      activeIcon: HugeIcons.strokeRoundedStore01,
      labelKey: LocalizationConstants.cartNavStoresKey,
      route: RouteNames.stores,
    ),
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedBooks01,
      activeIcon: HugeIcons.strokeRoundedBooks02,
      labelKey: LocalizationConstants.cartNavLibrariesKey,
      route: RouteNames.libraries,
    ),
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedAudioBook04,
      activeIcon: HugeIcons.strokeRoundedAudioBook04,
      labelKey: LocalizationConstants.cartNavAudioKey,
      route: RouteNames.audioBooks,
    ),
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedShoppingCart01,
      activeIcon: HugeIcons.strokeRoundedShoppingCart01,
      labelKey: LocalizationConstants.cartNavCartKey,
      route: RouteNames.cart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double scale = (context.width / 430).clamp(0.9, 1.0).toDouble();
    final Color shadowColor =
        context.isDark ? Colors.black : AppColors.primary900;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(
        20 * scale,
        0,
        20 * scale,
        20 * scale,
      ),
      child: Container(
        height: 76 * scale,
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: AppColors.primary600,
          borderRadius: BorderRadius.circular(42 * scale),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor.withValues(alpha: context.isDark ? 0.34 : 0.18),
              blurRadius: 28 * scale,
              spreadRadius: -6 * scale,
              offset: Offset(0, 14 * scale),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            for (int index = 0; index < _destinations.length; index++)
              _NavItem(
                index: index,
                currentIndex: currentIndex,
                destination: _destinations[index],
                scale: scale,
              ),
          ],
        ),
      ),
    );
  }
}

class _CartNavDestination {
  const _CartNavDestination({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    required this.route,
  });

  final List<List<dynamic>> icon;
  final List<List<dynamic>> activeIcon;
  final String labelKey;
  final String route;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.destination,
    required this.scale,
  });

  final int index;
  final int currentIndex;
  final _CartNavDestination destination;
  final double scale;

  bool get _isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        context.isDark ? AppColors.primary300 : AppColors.primary600;

    return Expanded(
      flex: _isActive ? 3 : 1,
      child: Semantics(
        button: true,
        selected: _isActive,
        label: destination.labelKey.tr(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!_isActive) {
              context.goTo(destination.route);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            height: 58 * scale,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10 * scale),
            decoration: BoxDecoration(
              color: _isActive ? context.appCard : Colors.transparent,
              borderRadius: BorderRadius.circular(32 * scale),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedScale(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  scale: _isActive ? 1.08 : 1,
                  child: HugeIcon(
                    icon: _isActive ? destination.activeIcon : destination.icon,
                    color: _isActive ? activeColor : Colors.white,
                    size: 25 * scale,
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
                    child: _isActive
                        ? Padding(
                            key: ValueKey<String>(destination.labelKey),
                            padding: EdgeInsetsDirectional.only(start: 8 * scale),
                            child: Transform.translate(
                              offset: Offset(0, 10 * scale),
                              child: Text(
                                destination.labelKey.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: activeColor,
                                  fontSize: 17 * scale,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
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
      ),
    );
  }
}