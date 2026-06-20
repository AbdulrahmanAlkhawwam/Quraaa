import 'dart:math' as math;
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../data/datasources/local/pdf_render_datasource.dart';
import 'pdf_selection_gesture_layer.dart';
import 'pdf_selection_toolbar.dart';
import 'pdf_selection_toolbar_position.dart';
import 'rendered_pdf_page_image.dart';

class PdfPageImage extends StatefulWidget {
  const PdfPageImage({
    required this.renderer,
    required this.path,
    required this.pageIndex,
    required this.highlights,
    required this.onHighlightAdded,
    required this.onMessage,
    super.key,
  });

  final PdfRenderDataSource renderer;
  final String path;
  final int pageIndex;
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
      _resetSelectionFields();
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
                viewportWidth.clamp(260.0, 4200.0).toDouble();
            final double pageHeight = pageWidth / _aspectRatio(textLayer);
            final Size pageSize = Size(pageWidth, pageHeight);
            final double pixelRatio =
                MediaQuery.devicePixelRatioOf(context)
                    .clamp(1.0, 3.0)
                    .toDouble();
            final int renderWidth = (pageWidth * pixelRatio * 2)
                .round()
                .clamp(720, 3600)
                .toInt();

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
              child: SizedBox(
                width: pageWidth,
                height: pageHeight,
                child: InteractiveViewer(
                  minScale: 0.85,
                  maxScale: 4,
                  panEnabled: true,
                  scaleEnabled: true,
                  clipBehavior: Clip.hardEdge,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: AppShadows.elevation1,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: SizedBox.expand(
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            FutureBuilder<Uint8List>(
                              future: _pageFuture,
                              builder: (
                                BuildContext context,
                                AsyncSnapshot<Uint8List> snapshot,
                              ) {
                                return RenderedPdfPageImage(snapshot: snapshot);
                              },
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _TextBoundsPainter(
                                  rects: _highlightRects,
                                  textLayer: textLayer,
                                  pageSize: pageSize,
                                  color: const Color(0x66F6D86B),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _TextBoundsPainter(
                                  rects: _selectedRects,
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
                              child: PdfSelectionGestureLayer(
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
                              PdfSelectionToolbarPosition(
                                selectedBounds: _selectedLocalBounds(
                                  textLayer: textLayer,
                                  pageSize: pageSize,
                                ),
                                pageSize: pageSize,
                                child: PdfSelectionToolbar(
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

  List<Rect> get _highlightRects {
    return widget.highlights
        .expand((PdfTextHighlight highlight) => highlight.bounds)
        .toList(growable: false);
  }

  List<Rect> get _selectedRects => _rectsFromContents(_selectedContents);

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
      _resetSelectionFields();
    });
  }

  Future<void> _copySelectedText() async {
    final String text = _selectedText;
    if (text.isEmpty) {
      return;
    }

    await _copyTextToClipboard(text);
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
      await _copyTextToClipboard(text);
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
        bounds: _selectedRects,
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

  double _aspectRatio(PdfPageTextLayer textLayer) {
    if (textLayer.width > 0 && textLayer.height > 0) {
      return textLayer.width / textLayer.height;
    }

    return 0.72;
  }

  void _resetSelectionFields() {
    _selectionStart = null;
    _selectionEnd = null;
    _selectedContents = <PdfTextContentInfo>[];
  }

  Future<void> _copyTextToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    widget.onMessage(LocalizationConstants.pdfReaderCopiedKey.tr());
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

    for (final Rect pageRect in rects) {
      final Rect localRect = _pageRectToLocal(
        pageRect,
        textLayer: textLayer,
        pageSize: pageSize,
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

Rect _pageRectToLocal(
  Rect pageRect, {
  required PdfPageTextLayer textLayer,
  required Size pageSize,
}) {
  final double scaleX = pageSize.width / math.max(textLayer.width, 1.0);
  final double scaleY = pageSize.height / math.max(textLayer.height, 1.0);

  return Rect.fromLTRB(
    pageRect.left * scaleX,
    pageRect.top * scaleY,
    pageRect.right * scaleX,
    pageRect.bottom * scaleY,
  );
}

List<Rect> _rectsFromContents(Iterable<PdfTextContentInfo> contents) {
  return contents
      .expand((PdfTextContentInfo content) => content.bounds)
      .toList(growable: false);
}
