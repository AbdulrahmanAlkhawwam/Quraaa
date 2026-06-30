import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing12,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: BorderRadius.circular(AppRadius.radius40),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
                  _NavItem(
                    icon: HugeIcons.strokeRoundedHome04,
                    activeIcon: HugeIcons.strokeRoundedHome01,
                    label: 'Home',
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: HugeIcons.strokeRoundedStore04,
                    activeIcon: HugeIcons.strokeRoundedStore01,
                    label: 'Stores',
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavItem(
                    icon: HugeIcons.strokeRoundedBooks01,
                    activeIcon: HugeIcons.strokeRoundedBooks02,
                    label: 'User Books',
                    isActive: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: HugeIcons.strokeRoundedAudioBook04,
                    activeIcon: HugeIcons.strokeRoundedAudioBook04,
                    label: 'Audio Book',
                    isActive: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  _NavItem(
                    icon: HugeIcons.strokeRoundedShoppingCart01,
                    activeIcon: HugeIcons.strokeRoundedShoppingCart01,
                    label: 'Cart',
                    isActive: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? AppSpacing.spacing12 : AppSpacing.spacing8,
          vertical: AppSpacing.spacing8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.radius24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 1.0,
                end: isActive ? 1.15 : 1.0,
              ),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              builder: (BuildContext context, double scale, Widget? child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: HugeIcon(
                icon: isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary600 : AppColors.card,
                size: 24,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (
                Widget child,
                Animation<double> animation,
              ) {
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
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
