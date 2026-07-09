import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';

class PdfReaderTitleBlock extends StatelessWidget {
  const PdfReaderTitleBlock({
    required this.fileName,
    super.key,
  });

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          LocalizationConstants.pdfReaderTitleKey.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.isDark ? AppColors.primary300 : AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.appTextSecondary,
              ),
        ),
      ],
    );
  }
}
