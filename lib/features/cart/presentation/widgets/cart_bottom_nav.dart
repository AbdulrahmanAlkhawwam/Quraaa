import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../shared/shared.dart';

class CartBottomNav extends StatelessWidget {
  const CartBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  static const List<_CartNavDestination> _destinations = <_CartNavDestination>[
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedHome04,
      activeIcon: HugeIcons.strokeRoundedHome01,
      label: 'home',
      route: RouteNames.home,
    ),
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedStore04,
      activeIcon: HugeIcons.strokeRoundedStore01,
      label: 'stores',
      route: RouteNames.stores,
    ),
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedBooks01,
      activeIcon: HugeIcons.strokeRoundedBooks02,
      label: 'libraries',
      route: RouteNames.userBooks,
    ),
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedAudioBook04,
      activeIcon: HugeIcons.strokeRoundedAudioBook04,
      label: 'audio',
      route: RouteNames.audioBooks,
    ),
    _CartNavDestination(
      icon: HugeIcons.strokeRoundedShoppingCart01,
      activeIcon: HugeIcons.strokeRoundedShoppingCart01,
      label: 'cart',
      route: RouteNames.cart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double scale = context.compactFeatureScale;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        8 * scale,
        24 * scale,
        24 * scale,
      ),
      child: Container(
        height: 76 * scale,
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: AppColors.primary600,
          borderRadius: BorderRadius.circular(40 * scale),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
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
      ),
    );
  }
}

class _CartNavDestination {
  const _CartNavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final List<List<dynamic>> icon;
  final List<List<dynamic>> activeIcon;
  final String label;
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
    return Expanded(
      flex: _isActive ? 3 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_isActive) {
            context.goTo(destination.route);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 56 * scale,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
          decoration: BoxDecoration(
            color: _isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30 * scale),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HugeIcon(
                icon: _isActive ? destination.activeIcon : destination.icon,
                color: _isActive ? AppColors.primary600 : Colors.white,
                size: 25 * scale,
              ),
              if (_isActive) ...<Widget>[
                SizedBox(width: 8 * scale),
                Flexible(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary600,
                      fontSize: 17 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
