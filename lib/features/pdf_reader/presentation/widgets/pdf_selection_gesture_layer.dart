import 'package:flutter/material.dart';

import '../../domain/entities/pdf_text_layer.dart';

class PdfSelectionGestureLayer extends StatelessWidget {
  const PdfSelectionGestureLayer({
    required this.enabled,
    required this.textLayer,
    required this.pageSize,
    required this.onSelectionStarted,
    required this.onSelectionMoved,
    required this.onSelectionFinished,
    required this.onPageLongPressed,
    required this.onTap,
    super.key,
  });

  final bool enabled;
  final PdfPageTextLayer textLayer;
  final Size pageSize;
  final void Function({
    required Offset position,
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) onSelectionStarted;
  final void Function({
    required Offset position,
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) onSelectionMoved;
  final VoidCallback onSelectionFinished;
  final void Function({
    required Offset position,
    required Size pageSize,
  }) onPageLongPressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      onLongPressStart: (LongPressStartDetails details) {
        if (!enabled) {
          onPageLongPressed(
            position: details.localPosition,
            pageSize: pageSize,
          );
          return;
        }

        onSelectionStarted(
          position: details.localPosition,
          textLayer: textLayer,
          pageSize: pageSize,
        );
      },
      onLongPressMoveUpdate: !enabled
          ? null
          : (LongPressMoveUpdateDetails details) {
              onSelectionMoved(
                position: details.localPosition,
                textLayer: textLayer,
                pageSize: pageSize,
              );
            },
      onLongPressEnd: !enabled ? null : (_) => onSelectionFinished(),
      onLongPressCancel: !enabled ? null : onSelectionFinished,
    );
  }
}
