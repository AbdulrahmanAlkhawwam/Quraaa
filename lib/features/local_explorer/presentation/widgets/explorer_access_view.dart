import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';

class ExplorerAccessView extends StatelessWidget {
  const ExplorerAccessView({
    required this.onAccessRequested,
    super.key,
  });

  final VoidCallback onAccessRequested;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.noteSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.noteBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedFolderUnlocked,
                  color: AppColors.secondary,
                  size: 58,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  LocalizationConstants.explorerAccessTitleKey.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  LocalizationConstants.explorerAccessMessageKey.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: onAccessRequested,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedFolderUnlocked,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: Text(LocalizationConstants.explorerAccessActionKey.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
