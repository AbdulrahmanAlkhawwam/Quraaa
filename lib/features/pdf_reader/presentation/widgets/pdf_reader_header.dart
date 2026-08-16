import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/pdf_reader_local_state.dart';

class PdfReaderHeader extends StatelessWidget {
  const PdfReaderHeader({
    required this.annotationMode,
    required this.inkTool,
    required this.inkColor,
    required this.canUndo,
    required this.canRedo,
    required this.onBack,
    required this.onInfo,
    required this.translateAvailable,
    required this.onTranslate,
    required this.onHighlight,
    required this.onAddNote,
    required this.onLayout,
    required this.onEdit,
    required this.onUndo,
    required this.onRedo,
    required this.onChooseColor,
    required this.onSave,
    super.key,
  });

  final bool annotationMode;
  final PdfInkTool inkTool;
  final Color inkColor;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onBack;
  final VoidCallback onInfo;
  final bool translateAvailable;
  final VoidCallback? onTranslate;
  final VoidCallback onHighlight;
  final VoidCallback onAddNote;
  final VoidCallback onLayout;
  final VoidCallback onEdit;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onChooseColor;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        context.isDark ? AppColors.primary300 : AppColors.secondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border(
          bottom: BorderSide(color: context.appBorder, width: 8),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          annotationMode ? 6 : AppSpacing.spacing16,
          AppSpacing.spacing10,
          annotationMode ? 6 : AppSpacing.spacing16,
          AppSpacing.spacing10,
        ),
        child: Row(
          children: <Widget>[
            _HeaderButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: context.isRTL
                  ? HugeIcons.strokeRoundedArrowRight01
                  : HugeIcons.strokeRoundedArrowLeft01,
              color: iconColor,
              onPressed: onBack,
            ),
            const Spacer(),
            if (annotationMode) ...<Widget>[
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderUndoKey.tr(),
                icon: HugeIcons.strokeRoundedUndo,
                color: iconColor,
                onPressed: canUndo ? onUndo : null,
              ),
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderRedoKey.tr(),
                icon: HugeIcons.strokeRoundedRedo,
                color: iconColor,
                onPressed: canRedo ? onRedo : null,
              ),
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderHighlightKey.tr(),
                icon: HugeIcons.strokeRoundedHighlighter,
                color: iconColor,
                selected: inkTool == PdfInkTool.highlighter,
                onPressed: onHighlight,
              ),
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderPenKey.tr(),
                icon: HugeIcons.strokeRoundedPencil,
                color: iconColor,
                selected: inkTool == PdfInkTool.pen,
                onPressed: onEdit,
              ),
              _ColorButton(
                color: inkColor,
                tooltip: LocalizationConstants.pdfReaderColorKey.tr(),
                onPressed: onChooseColor,
              ),
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderSaveAnnotationsKey.tr(),
                icon: HugeIcons.strokeRoundedSave,
                color: iconColor,
                onPressed: onSave,
              ),
            ] else ...<Widget>[
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderInfoKey.tr(),
                icon: HugeIcons.strokeRoundedInformationCircle,
                color: iconColor,
                onPressed: onInfo,
              ),
              if (translateAvailable)
                _HeaderButton(
                  tooltip: LocalizationConstants.pdfReaderTranslateKey.tr(),
                  icon: HugeIcons.strokeRoundedTranslate,
                  color: iconColor,
                  onPressed: onTranslate,
                ),
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderHighlightKey.tr(),
                icon: HugeIcons.strokeRoundedHighlighter,
                color: iconColor,
                onPressed: onHighlight,
              ),
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderAddNoteKey.tr(),
                icon: HugeIcons.strokeRoundedNoteAdd,
                color: iconColor,
                onPressed: onAddNote,
              ),
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderLayoutKey.tr(),
                icon: HugeIcons.strokeRoundedLayout01,
                color: iconColor,
                onPressed: onLayout,
              ),
              _HeaderButton(
                tooltip: LocalizationConstants.pdfReaderPenKey.tr(),
                icon: HugeIcons.strokeRoundedPencil,
                color: iconColor,
                onPressed: onEdit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.selected = false,
  });

  final String tooltip;
  final List<List<dynamic>> icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      style: selected
          ? IconButton.styleFrom(
              backgroundColor: AppColors.primary100,
              shape: const CircleBorder(),
            )
          : null,
      icon: HugeIcon(
        icon: icon,
        color: onPressed == null ? context.appTextTertiary : color,
        size: 25,
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      icon: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.20),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
      ),
    );
  }
}
