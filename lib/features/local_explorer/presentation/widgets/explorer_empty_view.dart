import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';

class ExplorerEmptyView extends StatelessWidget {
  const ExplorerEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HugeIcon(
              icon: HugeIcons.strokeRoundedFolderOpen,
              color: context.appTextTertiary,
              size: 56,
            ),
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              LocalizationConstants.explorerEmptyTitleKey.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.appTextPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.spacing8),
            Text(
              LocalizationConstants.explorerEmptyMessageKey.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appTextSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
