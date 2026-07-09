import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';

class PdfReaderMessageView extends StatelessWidget {
  const PdfReaderMessageView({
    required this.icon,
    required this.message,
    super.key,
  });

  final List<List<dynamic>> icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HugeIcon(icon: icon, color: context.isDark ? AppColors.primary300 : AppColors.secondary, size: 56),
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.appTextPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
