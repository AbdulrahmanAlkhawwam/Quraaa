import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

/// Customization panel that lets the user pick which avatar feature to edit.
class AvatarCustomizationTabs extends StatelessWidget {
  const AvatarCustomizationTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  static const List<_TabConfig> _tabs = <_TabConfig>[
    _TabConfig(
      labelKey: LocalizationConstants.avatarTabBackgroundKey,
      icon: HugeIcons.strokeRoundedPaintBrush02,
    ),
    _TabConfig(
      labelKey: LocalizationConstants.avatarTabHairKey,
      icon: HugeIcons.strokeRoundedUser,
    ),
    _TabConfig(
      labelKey: LocalizationConstants.avatarTabBeardKey,
      icon: HugeIcons.strokeRoundedUserAccount,
    ),
    _TabConfig(
      labelKey: LocalizationConstants.avatarTabMustacheKey,
      icon: HugeIcons.strokeRoundedUser,
    ),
    _TabConfig(
      labelKey: LocalizationConstants.avatarTabClothingKey,
      icon: HugeIcons.strokeRoundedShirt01,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.profileFieldHeight + AppSpacing.spacing26,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing8,
        vertical: AppSpacing.spacing10,
      ),
      decoration: BoxDecoration(
        color: AppColors.avatarTabBackground,
        borderRadius: BorderRadius.circular(AppRadius.radius18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<Widget>.generate(
          _tabs.length,
          (int index) => _buildTab(context, index),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final _TabConfig tab = _tabs[index];
    final bool isSelected = index == selectedTab;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing10,
        vertical: AppSpacing.spacing8,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.avatarTabSelected
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
      ),
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: tab.icon,
              color: isSelected
                  ? AppColors.editProfileSectionTitle
                  : AppColors.editProfileHint,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.spacing6),
            Text(
              tab.labelKey.tr(),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected
                    ? AppColors.editProfileSectionTitle
                    : AppColors.editProfileHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig({required this.labelKey, required this.icon});

  final String labelKey;
  final List<List<dynamic>> icon;
}
