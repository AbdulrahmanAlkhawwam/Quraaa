import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';

class ExplorerHeader extends StatelessWidget {
  const ExplorerHeader({
    required this.isGridMode,
    required this.canNavigateBack,
    required this.onNavigateBack,
    required this.onToggleView,
    required this.onRefresh,
    super.key,
  });

  final bool isGridMode;
  final bool canNavigateBack;
  final VoidCallback onNavigateBack;
  final VoidCallback onToggleView;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: canNavigateBack ? onNavigateBack : null,
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: context.isDark ? AppColors.primary300 : AppColors.secondary,
            size: 24,
          ),
          color: context.isDark ? AppColors.primary300 : AppColors.secondary,
          iconSize: 24,
        ),
        Expanded(
          child: Text(
            LocalizationConstants.explorerTitleKey.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.explorerTitle().copyWith(
              color: context.isDark ? AppColors.primary300 : AppColors.secondary,
            ),
          ),
        ),
        IconButton(
          tooltip: isGridMode
              ? LocalizationConstants.explorerListViewKey.tr()
              : LocalizationConstants.explorerGridViewKey.tr(),
          onPressed: onToggleView,
          icon: HugeIcon(
            icon: isGridMode
                ? HugeIcons.strokeRoundedGridTable
                : HugeIcons.strokeRoundedViewAgenda,
            color: context.isDark ? AppColors.primary300 : AppColors.secondary,
            size: 25,
          ),
          color: context.isDark ? AppColors.primary300 : AppColors.secondary,
          iconSize: 25,
        ),
        const SizedBox(width: AppSpacing.spacing8),
        IconButton(
          tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
          onPressed: onRefresh,
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedReload,
            color: context.isDark ? AppColors.primary300 : AppColors.secondary,
            size: 27,
          ),
          color: context.isDark ? AppColors.primary300 : AppColors.secondary,
          iconSize: 27,
        ),
      ],
    );
  }
}
