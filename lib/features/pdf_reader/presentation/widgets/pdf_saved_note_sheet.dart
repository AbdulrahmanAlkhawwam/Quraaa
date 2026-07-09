import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
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
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.spacing24,
          AppSpacing.spacing16,
          AppSpacing.spacing24,
          AppSpacing.spacing24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                HugeIcon(
                  icon: HugeIcons.strokeRoundedStickyNote02,
                  color: context.isDark ? AppColors.primary300 : AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.spacing8),
                Expanded(
                  child: Text(
                    hasSelectedText
                        ? LocalizationConstants.pdfReaderNoteTitleKey.tr()
                        : LocalizationConstants.pdfReaderPageNoteTitleKey.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.appTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            if (hasSelectedText) ...<Widget>[
              const SizedBox(height: AppSpacing.spacing16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.appSubtleSurface,
                  borderRadius: BorderRadius.circular(AppRadius.radius8),
                  border: Border.all(color: context.appBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.spacing8),
                  child: Text(
                    note.selectedText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appTextSecondary,
                        ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              note.note,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.appTextPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            Row(
              children: <Widget>[
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(note),
                  icon: HugeIcon(
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
