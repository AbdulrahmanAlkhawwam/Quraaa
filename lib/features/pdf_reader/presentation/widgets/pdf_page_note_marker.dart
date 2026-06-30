import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../domain/entities/pdf_text_note.dart';

class PdfPageNoteMarker extends StatelessWidget {
  const PdfPageNoteMarker({
    required this.note,
    required this.pageSize,
    required this.onPressed,
    super.key,
  });

  final PdfTextNote note;
  final Size pageSize;
  final ValueChanged<PdfTextNote> onPressed;

  @override
  Widget build(BuildContext context) {
    final PdfPageAnchor? anchor = note.anchor;
    if (anchor == null) {
      return const SizedBox.shrink();
    }

    final double left = ((anchor.xRatio.clamp(0.0, 1.0).toDouble() *
                pageSize.width) -
            12)
        .clamp(2.0, pageSize.width - 26)
        .toDouble();
    final double top = ((anchor.yRatio.clamp(0.0, 1.0).toDouble() *
                pageSize.height) -
            24)
        .clamp(2.0, pageSize.height - 28)
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      child: Tooltip(
        message: note.note,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onPressed(note),
            borderRadius: BorderRadius.circular(AppRadius.radius8),
            child: Opacity(
              opacity: 0.38,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.noteSurface,
                  borderRadius: BorderRadius.circular(AppRadius.radius8),
                  border: Border.all(color: AppColors.secondary),
                  boxShadow: AppShadows.elevation1,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedStickyNote02,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
