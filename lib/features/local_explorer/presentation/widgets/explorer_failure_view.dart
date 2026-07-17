import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
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
        padding: const EdgeInsets.all(AppSpacing.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const HugeIcon(
              icon: HugeIcons.strokeRoundedCancelCircle,
              color: AppColors.pdfLabel,
              size: 52,
            ),
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.appTextPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon:  HugeIcon(
                icon: HugeIcons.strokeRoundedArrowReloadHorizontal,
                color: context.isDark ? AppColors.primary300 : AppColors.secondary,
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
