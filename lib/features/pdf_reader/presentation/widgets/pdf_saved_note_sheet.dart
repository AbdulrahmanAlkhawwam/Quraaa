import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/pdf_text_note.dart';

class PdfSavedNoteSheet extends StatelessWidget {
  const PdfSavedNoteSheet({
    required this.note,
    super.key,
  });

  final PdfTextNote note;

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedText = note.selectedText.trim().isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedStickyNote02,
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    hasSelectedText
                        ? LocalizationConstants.pdfReaderNoteTitleKey.tr()
                        : LocalizationConstants.pdfReaderPageNoteTitleKey.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            if (hasSelectedText) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.noteSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.noteBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Text(
                    note.selectedText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              note.note,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(note),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: Color(0xFFC24135),
                    size: 18,
                  ),
                  label: Text(
                    LocalizationConstants.pdfReaderDeleteNoteKey.tr(),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFC24135),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    MaterialLocalizations.of(context).closeButtonLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
