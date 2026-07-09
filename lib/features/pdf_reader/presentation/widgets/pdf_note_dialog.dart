import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
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
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appCard,
            borderRadius: BorderRadius.circular(AppRadius.radius16),
            border: Border.all(color: context.appBorder),
            boxShadow: AppShadows.elevation1,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DialogHeader(hasSelectedText: hasSelectedText),
                const SizedBox(height: AppSpacing.spacing16),
                _NoteContext(
                  selectedText: widget.selectedText,
                  hasSelectedText: hasSelectedText,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 5,
                  cursorColor: AppColors.secondary,
                  decoration: InputDecoration(
                    hintText: LocalizationConstants.pdfReaderNoteHintKey.tr(),
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.appTextTertiary,
                        ),
                    filled: true,
                    fillColor: context.appBackground,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.radius8),
                      borderSide: BorderSide(
                        color: context.appBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.radius8),
                      borderSide: BorderSide(
                        color: context.isDark ? AppColors.primary300 : AppColors.secondary,
                        width: 1.4,
                      ),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appTextPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.spacing24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop<String>(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.appTextPrimary,
                          side: BorderSide(color: context.appBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.radius8),
                          ),
                        ),
                        child: Text(
                          MaterialLocalizations.of(context).cancelButtonLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacing8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop(_controller.text.trim());
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: context.isDark ? AppColors.primary300 : AppColors.secondary,
                          foregroundColor: AppColors.card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.radius8),
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
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.appSubtleSurface,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.spacing8),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedStickyNote02,
              color: context.isDark ? AppColors.primary300 : AppColors.secondary,
              size: 22,
            ),
          ),
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
        color: context.appSubtleSurface,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(color: context.appBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing8),
        child: Text(
          hasSelectedText
              ? selectedText
              : LocalizationConstants.pdfReaderPageNoteMessageKey.tr(),
          maxLines: hasSelectedText ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.appTextSecondary,
              ),
        ),
      ),
    );
  }
}
