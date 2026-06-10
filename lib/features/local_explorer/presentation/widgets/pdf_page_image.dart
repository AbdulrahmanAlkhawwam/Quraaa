import 'dart:math' as math;
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../data/datasources/local/pdf_render_datasource.dart';

class PdfPageImage extends StatefulWidget {
  const PdfPageImage({
    required this.renderer,
    required this.path,
    required this.pageIndex,
    required this.zoom,
    required this.highlights,
    required this.onHighlightAdded,
    required this.onMessage,
    super.key,
  });

  final PdfRenderDataSource renderer;
  final String path;
  final int pageIndex;
  final double zoom;
  final List<PdfTextHighlight> highlights;
  final ValueChanged<PdfTextHighlight> onHighlightAdded;
  final ValueChanged<String> onMessage;

  @override
  State<PdfPageImage> createState() => _PdfPageImageState();
}

class _PdfPageImageState extends State<PdfPageImage> {
  Future<Uint8List>? _pageFuture;
  Future<PdfPageTextLayer>? _textLayerFuture;
  int? _renderWidth;
  Offset? _selectionStart;
  Offset? _selectionEnd;
  List<PdfTextContentInfo> _selectedContents = <PdfTextContentInfo>[];

  @override
  void didUpdateWidget(covariant PdfPageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path ||
        oldWidget.pageIndex != widget.pageIndex) {
      _pageFuture = null;
      _textLayerFuture = null;
      _renderWidth = null;
      _selectionStart = null;
      _selectionEnd = null;
      _selectedContents = <PdfTextContentInfo>[];
    }

    if (oldWidget.zoom != widget.zoom) {
      _pageFuture = null;
      _renderWidth = null;
      _selectionStart = null;
      _selectionEnd = null;
      _selectedContents = <PdfTextContentInfo>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Future<PdfPageTextLayer> textLayerFuture = _textLayerFuture ??=
        widget.renderer.textLayer(
          path: widget.path,
          pageIndex: widget.pageIndex,
        );

    return FutureBuilder<PdfPageTextLayer>(
      future: textLayerFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<PdfPageTextLayer> textSnapshot,
      ) {
        final PdfPageTextLayer textLayer =
            textSnapshot.data ?? const PdfPageTextLayer.empty();

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double viewportWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final double pageWidth =
                (viewportWidth * widget.zoom).clamp(260.0, 4200.0).toDouble();
            final double pageHeight = pageWidth / _aspectRatio(textLayer);
            final Size pageSize = Size(pageWidth, pageHeight);
            final double pixelRatio =
                MediaQuery.devicePixelRatioOf(context)
                    .clamp(1.0, 3.0)
                    .toDouble();
            final int renderWidth =
                (pageWidth * pixelRatio).round().clamp(480, 3200).toInt();

            if (_pageFuture == null || _renderWidth != renderWidth) {
              _renderWidth = renderWidth;
              _pageFuture = widget.renderer.renderPage(
                path: widget.path,
                pageIndex: widget.pageIndex,
                width: renderWidth,
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: AppShadows.elevation1,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: SizedBox(
                      width: pageWidth,
                      height: pageHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          FutureBuilder<Uint8List>(
                            future: _pageFuture,
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<Uint8List> snapshot,
                            ) {
                              return _RenderedPageImage(snapshot: snapshot);
                            },
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _TextBoundsPainter(
                                rects: widget.highlights
                                    .expand(
                                      (PdfTextHighlight highlight) =>
                                          highlight.bounds,
                                    )
                                    .toList(growable: false),
                                textLayer: textLayer,
                                pageSize: pageSize,
                                color: const Color(0x66F6D86B),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _TextBoundsPainter(
                                rects: _selectedContents
                                    .expand(
                                      (PdfTextContentInfo content) =>
                                          content.bounds,
                                    )
                                    .toList(growable: false),
                                textLayer: textLayer,
                                pageSize: pageSize,
                                color: const Color(0x553B8F65),
                              ),
                            ),
                          ),
                          if (_selectionStart != null &&
                              _selectionEnd != null)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _SelectionRectPainter(
                                  start: _selectionStart!,
                                  end: _selectionEnd!,
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: _SelectionGestureLayer(
                              enabled: textLayer.hasText,
                              textLayer: textLayer,
                              pageSize: pageSize,
                              onSelectionStarted: _startSelection,
                              onSelectionMoved: _moveSelection,
                              onSelectionFinished: _finishSelection,
                              onUnavailable: () {
                                widget.onMessage(
                                  LocalizationConstants
                                      .pdfReaderSelectionUnavailableKey
                                      .tr(),
                                );
                              },
                              onTap: _clearSelection,
                            ),
                          ),
                          if (_selectedText.isNotEmpty)
                            _SelectionToolbarPosition(
                              selectedBounds: _selectedLocalBounds(
                                textLayer: textLayer,
                                pageSize: pageSize,
                              ),
                              pageSize: pageSize,
                              child: _SelectionToolbar(
                                onCopy: _copySelectedText,
                                onShare: _shareSelectedText,
                                onHighlight: _markSelectedText,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String get _selectedText {
    return _selectedContents
        .map((PdfTextContentInfo content) => content.text)
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _startSelection({
    required Offset position,
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) {
    final Offset clamped = _clampOffset(position, pageSize);
    setState(() {
      _selectionStart = clamped;
      _selectionEnd = clamped;
      _selectedContents = _contentsInsideSelection(
        textLayer: textLayer,
        pageSize: pageSize,
      );
    });
  }

  void _moveSelection({
    required Offset position,
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) {
    setState(() {
      _selectionEnd = _clampOffset(position, pageSize);
      _selectedContents = _contentsInsideSelection(
        textLayer: textLayer,
        pageSize: pageSize,
      );
    });
  }

  void _finishSelection() {
    if (_selectedContents.isEmpty) {
      _clearSelection();
    }
  }

  void _clearSelection() {
    if (_selectionStart == null &&
        _selectionEnd == null &&
        _selectedContents.isEmpty) {
      return;
    }

    setState(() {
      _selectionStart = null;
      _selectionEnd = null;
      _selectedContents = <PdfTextContentInfo>[];
    });
  }

  Future<void> _copySelectedText() async {
    final String text = _selectedText;
    if (text.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: text));
    widget.onMessage(LocalizationConstants.pdfReaderCopiedKey.tr());
    _clearSelection();
  }

  Future<void> _shareSelectedText() async {
    final String text = _selectedText;
    if (text.isEmpty) {
      return;
    }

    try {
      await widget.renderer.shareText(text);
      _clearSelection();
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      widget.onMessage(LocalizationConstants.pdfReaderCopiedKey.tr());
      _clearSelection();
    }
  }

  void _markSelectedText() {
    final String text = _selectedText;
    if (text.isEmpty || _selectedContents.isEmpty) {
      return;
    }

    widget.onHighlightAdded(
      PdfTextHighlight(
        text: text,
        bounds: _selectedContents
            .expand((PdfTextContentInfo content) => content.bounds)
            .toList(growable: false),
      ),
    );
    widget.onMessage(LocalizationConstants.pdfReaderHighlightedKey.tr());
    _clearSelection();
  }

  List<PdfTextContentInfo> _contentsInsideSelection({
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) {
    final Offset? start = _selectionStart;
    final Offset? end = _selectionEnd;
    if (start == null || end == null || !textLayer.hasText) {
      return const <PdfTextContentInfo>[];
    }

    final Rect selection = _rectFromOffsets(start, end).inflate(6);
    return textLayer.contents.where((PdfTextContentInfo content) {
      return content.bounds.any((Rect pageRect) {
        final Rect localRect = _pageRectToLocal(
          pageRect,
          textLayer: textLayer,
          pageSize: pageSize,
        ).inflate(2);
        return selection.overlaps(localRect) ||
            selection.contains(localRect.center);
      });
    }).toList(growable: false);
  }

  Rect? _selectedLocalBounds({
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) {
    Rect? bounds;
    for (final PdfTextContentInfo content in _selectedContents) {
      for (final Rect pageRect in content.bounds) {
        final Rect localRect = _pageRectToLocal(
          pageRect,
          textLayer: textLayer,
          pageSize: pageSize,
        );
        bounds = bounds == null ? localRect : _mergeRects(bounds!, localRect);
      }
    }

    return bounds;
  }

  Rect _pageRectToLocal(
    Rect pageRect, {
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) {
    final double sourceWidth = math.max(textLayer.width, 1.0);
    final double sourceHeight = math.max(textLayer.height, 1.0);
    final double scaleX = pageSize.width / sourceWidth;
    final double scaleY = pageSize.height / sourceHeight;

    return Rect.fromLTRB(
      pageRect.left * scaleX,
      pageRect.top * scaleY,
      pageRect.right * scaleX,
      pageRect.bottom * scaleY,
    );
  }

  double _aspectRatio(PdfPageTextLayer textLayer) {
    if (textLayer.width > 0 && textLayer.height > 0) {
      return textLayer.width / textLayer.height;
    }

    return 0.72;
  }
}

class _RenderedPageImage extends StatelessWidget {
  const _RenderedPageImage({required this.snapshot});

  final AsyncSnapshot<Uint8List> snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    final Uint8List? bytes = snapshot.data;
    if (snapshot.hasError || bytes == null || bytes.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedPdf02,
            color: AppColors.pdfLabel,
            size: 54,
          ),
        ),
      );
    }

    return Image.memory(
      bytes,
      fit: BoxFit.fill,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
    );
  }
}

class _SelectionGestureLayer extends StatelessWidget {
  const _SelectionGestureLayer({
    required this.enabled,
    required this.textLayer,
    required this.pageSize,
    required this.onSelectionStarted,
    required this.onSelectionMoved,
    required this.onSelectionFinished,
    required this.onUnavailable,
    required this.onTap,
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
  final VoidCallback onUnavailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      onLongPressStart: (LongPressStartDetails details) {
        if (!enabled) {
          onUnavailable();
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

class _SelectionToolbarPosition extends StatelessWidget {
  const _SelectionToolbarPosition({
    required this.selectedBounds,
    required this.pageSize,
    required this.child,
  });

  final Rect? selectedBounds;
  final Size pageSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Rect? bounds = selectedBounds;
    if (bounds == null) {
      return const SizedBox.shrink();
    }

    final double left = _clampDouble(
      bounds.left,
      AppSpacing.sm,
      math.max(AppSpacing.sm, pageSize.width - 174),
    );
    final double top = _clampDouble(
      bounds.top - 54,
      AppSpacing.sm,
      math.max(AppSpacing.sm, pageSize.height - 54),
    );

    return Positioned(
      left: left,
      top: top,
      child: child,
    );
  }
}

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.onCopy,
    required this.onShare,
    required this.onHighlight,
  });

  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onHighlight;

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
            _ToolbarButton(
              tooltip: LocalizationConstants.pdfReaderCopyKey.tr(),
              icon: HugeIcons.strokeRoundedCopy01,
              onPressed: onCopy,
            ),
            _ToolbarButton(
              tooltip: LocalizationConstants.pdfReaderShareKey.tr(),
              icon: HugeIcons.strokeRoundedShare01,
              onPressed: onShare,
            ),
            _ToolbarButton(
              tooltip: LocalizationConstants.pdfReaderHighlightKey.tr(),
              icon: HugeIcons.strokeRoundedPencilEdit01,
              onPressed: onHighlight,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final List<List<dynamic>> icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: 42, height: 42),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: HugeIcon(
        icon: icon,
        color: AppColors.surfaceLight,
        size: 21,
      ),
    );
  }
}

class _TextBoundsPainter extends CustomPainter {
  const _TextBoundsPainter({
    required this.rects,
    required this.textLayer,
    required this.pageSize,
    required this.color,
  });

  final List<Rect> rects;
  final PdfPageTextLayer textLayer;
  final Size pageSize;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (rects.isEmpty) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final double sourceWidth = math.max(textLayer.width, 1.0);
    final double sourceHeight = math.max(textLayer.height, 1.0);
    final double scaleX = pageSize.width / sourceWidth;
    final double scaleY = pageSize.height / sourceHeight;

    for (final Rect pageRect in rects) {
      final Rect localRect = Rect.fromLTRB(
        pageRect.left * scaleX,
        pageRect.top * scaleY,
        pageRect.right * scaleX,
        pageRect.bottom * scaleY,
      ).inflate(1.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(localRect, const Radius.circular(3)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TextBoundsPainter oldDelegate) {
    return rects != oldDelegate.rects ||
        textLayer != oldDelegate.textLayer ||
        pageSize != oldDelegate.pageSize ||
        color != oldDelegate.color;
  }
}

class _SelectionRectPainter extends CustomPainter {
  const _SelectionRectPainter({
    required this.start,
    required this.end,
  });

  final Offset start;
  final Offset end;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = _rectFromOffsets(start, end);
    if (rect.width < 2 && rect.height < 2) {
      return;
    }

    final RRect roundedRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(6),
    );
    canvas.drawRRect(
      roundedRect,
      Paint()
        ..color = const Color(0x223B8F65)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      roundedRect,
      Paint()
        ..color = AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _SelectionRectPainter oldDelegate) {
    return start != oldDelegate.start || end != oldDelegate.end;
  }
}

Offset _clampOffset(Offset offset, Size size) {
  return Offset(
    _clampDouble(offset.dx, 0, size.width),
    _clampDouble(offset.dy, 0, size.height),
  );
}

double _clampDouble(double value, double min, double max) {
  if (max < min) {
    return min;
  }

  return value.clamp(min, max).toDouble();
}

Rect _rectFromOffsets(Offset first, Offset second) {
  return Rect.fromLTRB(
    math.min(first.dx, second.dx),
    math.min(first.dy, second.dy),
    math.max(first.dx, second.dx),
    math.max(first.dy, second.dy),
  );
}

Rect _mergeRects(Rect first, Rect second) {
  return Rect.fromLTRB(
    math.min(first.left, second.left),
    math.min(first.top, second.top),
    math.max(first.right, second.right),
    math.max(first.bottom, second.bottom),
  );
}
