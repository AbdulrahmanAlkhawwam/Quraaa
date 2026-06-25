import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';

class ExplorerFailureView extends StatelessWidget {
  const ExplorerFailureView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const HugeIcon(
              icon: HugeIcons.strokeRoundedCancelCircle,
              color: AppColors.pdfLabel,
              size: 52,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowReloadHorizontal,
                color: AppColors.secondary,
                size: 20,
              ),
              label: Text(LocalizationConstants.retryKey.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
