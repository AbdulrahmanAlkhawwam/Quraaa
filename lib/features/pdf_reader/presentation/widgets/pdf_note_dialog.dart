import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../../../shared/theme/app_spacing.dart';

class PdfNoteDialog extends StatefulWidget {
  const PdfNoteDialog({
    this.selectedText = '',
    super.key,
  });

  final String selectedText;

  @override
  State<PdfNoteDialog> createState() => _PdfNoteDialogState();
}

class _PdfNoteDialogState extends State<PdfNoteDialog> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedText = widget.selectedText.trim().isNotEmpty;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppShadows.elevation1,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DialogHeader(hasSelectedText: hasSelectedText),
                const SizedBox(height: AppSpacing.md),
                _NoteContext(
                  selectedText: widget.selectedText,
                  hasSelectedText: hasSelectedText,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 5,
                  cursorColor: AppColors.secondary,
                  decoration: InputDecoration(
                    hintText: LocalizationConstants.pdfReaderNoteHintKey.tr(),
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(
                        color: AppColors.secondary,
                        width: 1.4,
                      ),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop<String>(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.noteBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        child: Text(
                          MaterialLocalizations.of(context).cancelButtonLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop(_controller.text.trim());
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.surfaceLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        child: Text(
                          LocalizationConstants.pdfReaderSaveNoteKey.tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.hasSelectedText});

  final bool hasSelectedText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.noteSurface,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedStickyNote02,
              color: AppColors.secondary,
              size: 22,
            ),
          ),
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
    );
  }
}

class _NoteContext extends StatelessWidget {
  const _NoteContext({
    required this.selectedText,
    required this.hasSelectedText,
  });

  final String selectedText;
  final bool hasSelectedText;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.noteSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.noteBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Text(
          hasSelectedText
              ? selectedText
              : LocalizationConstants.pdfReaderPageNoteMessageKey.tr(),
          maxLines: hasSelectedText ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ),
    );
  }
}
