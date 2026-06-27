import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../../../shared/theme/app_spacing.dart';
import 'pdf_toolbar_button.dart';

class PdfSelectionToolbar extends StatelessWidget {
  const PdfSelectionToolbar({
    required this.onCopy,
    required this.onShare,
    required this.onNote,
    super.key,
  });

  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: AppShadows.elevation1,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PdfToolbarButton(
              tooltip: LocalizationConstants.pdfReaderCopyKey.tr(),
              icon: HugeIcons.strokeRoundedCopy01,
              onPressed: onCopy,
            ),
            PdfToolbarButton(
              tooltip: LocalizationConstants.pdfReaderShareKey.tr(),
              icon: HugeIcons.strokeRoundedShare01,
              onPressed: onShare,
            ),
            PdfToolbarButton(
              tooltip: LocalizationConstants.pdfReaderAddNoteKey.tr(),
              icon: HugeIcons.strokeRoundedNoteAdd,
              onPressed: onNote,
            ),
          ],
        ),
      ),
    );
  }
}
