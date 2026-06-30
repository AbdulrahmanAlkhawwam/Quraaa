import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../shared/theme/styles/text_styles.dart';

/// Customization panel that lets the user pick which avatar feature to edit.
class AvatarCustomizationTabs extends StatelessWidget {
  const AvatarCustomizationTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  static const double _height = 90;
  static const double _radius = 18;
  static const double _selectedRadius = 12;

  static const List<_TabConfig> _tabs = <_TabConfig>[
    _TabConfig(label: 'Background', icon: HugeIcons.strokeRoundedPaintBrush02),
    _TabConfig(label: 'Hair', icon: HugeIcons.strokeRoundedUser),
    _TabConfig(label: 'Beard', icon: HugeIcons.strokeRoundedUserAccount),
    _TabConfig(label: 'Mustache', icon: HugeIcons.strokeRoundedUser),
    _TabConfig(label: 'Clothing', icon: HugeIcons.strokeRoundedShirt01),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F1),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<Widget>.generate(
          _tabs.length,
          (int index) => _buildTab(index),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final _TabConfig tab = _tabs[index];
    final bool isSelected = index == selectedTab;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F2DE) : Colors.transparent,
        borderRadius: BorderRadius.circular(_selectedRadius),
      ),
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(_selectedRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: tab.icon,
              color: isSelected
                  ? const Color(0xFF2D3A27)
                  : const Color(0xFF8A9A84),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              tab.label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF2D3A27)
                    : const Color(0xFF8A9A84),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig({
    required this.label,
    required this.icon,
  });

  final String label;
  final List<List<dynamic>> icon;
}
