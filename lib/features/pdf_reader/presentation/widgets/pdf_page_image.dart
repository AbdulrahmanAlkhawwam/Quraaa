import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../../../shared/extensions/app_context.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/entities/pdf_text_note.dart';
import '../../domain/entities/pdf_reader_local_state.dart';
import '../../domain/use_cases/get_pdf_text_layer_use_case.dart';
import '../../domain/use_cases/render_pdf_page_use_case.dart';
import '../../domain/use_cases/share_pdf_text_use_case.dart';
import '../../domain/value_objects/pdf_reader_result.dart';
import 'pdf_page_note_marker.dart';
import 'pdf_page_turn_gesture_layer.dart';
import 'pdf_selection_gesture_layer.dart';
import 'pdf_selection_toolbar.dart';
import 'pdf_selection_toolbar_position.dart';
import 'rendered_pdf_page_image.dart';

typedef PdfTextNoteRequested = void Function({
  required String selectedText,
  required List<PdfTextBounds> bounds,
  required PdfPageAnchor? anchor,
});

class PdfPageImage extends StatefulWidget {
  const PdfPageImage({
    required this.renderPage,
    required this.getTextLayer,
    required this.shareText,
    required this.path,
    required this.pageIndex,
    required this.highlights,
    required this.notes,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPreviousPageTurn,
    required this.onNextPageTurn,
    required this.onNoteRequested,
    required this.onSavedNotePressed,
    required this.onMessage,
    this.enablePageTurnGestures = true,
    this.continuousScrolling = false,
    this.inkMode = false,
    this.inkColorValue = 0xFFF5C242,
    this.inkTool = PdfInkTool.highlighter,
    this.renderQualityScale = 1,
    this.inkStrokes = const <PdfInkStroke>[],
    this.onInkStrokeCompleted,
    super.key,
  });

  final RenderPdfPageUseCase renderPage;
  final GetPdfTextLayerUseCase getTextLayer;
  final SharePdfTextUseCase shareText;
  final String path;
  final int pageIndex;
  final List<PdfTextHighlight> highlights;
  final List<PdfTextNote> notes;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPreviousPageTurn;
  final VoidCallback onNextPageTurn;
  final PdfTextNoteRequested onNoteRequested;
  final ValueChanged<PdfTextNote> onSavedNotePressed;
  final ValueChanged<String> onMessage;
  final bool enablePageTurnGestures;
  final bool continuousScrolling;
  final bool inkMode;
  final int inkColorValue;
  final double renderQualityScale;
  final PdfInkTool inkTool;
  final List<PdfInkStroke> inkStrokes;
  final ValueChanged<PdfInkStroke>? onInkStrokeCompleted;

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
  final List<PdfInkPoint> _draftInkPoints = <PdfInkPoint>[];
  final _InkDraftNotifier _draftInkRepaint = _InkDraftNotifier();

  @override
  void didUpdateWidget(covariant PdfPageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path ||
        oldWidget.pageIndex != widget.pageIndex) {
      _pageFuture = null;
      _textLayerFuture = null;
      _renderWidth = null;
      _resetSelectionFields();
      _clearDraftInk();
    }
    if (oldWidget.inkMode && !widget.inkMode) {
      _clearDraftInk();
    }
  }

  @override
  void dispose() {
    _draftInkRepaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Future<PdfPageTextLayer> textLayerFuture =
        _textLayerFuture ??= _loadTextLayer();

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
            final double viewportHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height;
            final double availableWidth = math.max(120, viewportWidth);
            final double availableHeight = math.max(120, viewportHeight - 8);
            final double aspectRatio = _aspectRatio(textLayer);
            double pageWidth = availableWidth.clamp(120.0, 4200.0).toDouble();
            double pageHeight = pageWidth / aspectRatio;
            if (pageHeight > availableHeight) {
              pageHeight = availableHeight.clamp(120.0, 4200.0).toDouble();
              pageWidth = pageHeight * aspectRatio;
            }
            final Size pageSize = Size(pageWidth, pageHeight);
            final double pixelRatio = MediaQuery.devicePixelRatioOf(context)
                .clamp(1.0, 3.0)
                .toDouble();
            final double renderScale = widget.continuousScrolling
                ? 1.05 * widget.renderQualityScale.clamp(1.0, 2.25).toDouble()
                : 1.5;
            const int maxRenderWidth = 3200;
            final int renderWidth = (pageWidth * pixelRatio * renderScale)
                .round()
                .clamp(640, maxRenderWidth)
                .toInt();

            if (_pageFuture == null || _renderWidth != renderWidth) {
              _renderWidth = renderWidth;
              _pageFuture = _renderPage(renderWidth);
            }

            return SizedBox.expand(
              child: InteractiveViewer(
                key: ValueKey<String>('${widget.path}:${widget.pageIndex}'),
                minScale: 1,
                maxScale: 4.5,
                boundaryMargin: EdgeInsets.zero,
                panEnabled: !widget.inkMode && !widget.continuousScrolling,
                scaleEnabled: !widget.inkMode && !widget.continuousScrolling,
                clipBehavior: Clip.hardEdge,
                child: Center(
                  child: SizedBox(
                    width: pageWidth,
                    height: pageHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.appCard,
                        borderRadius: BorderRadius.circular(AppRadius.radius8),
                        border: Border.all(color: context.appBorder),
                        boxShadow: AppShadows.elevation1,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.radius8),
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
                                  return RenderedPdfPageImage(
                                    snapshot: snapshot,
                                  );
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
                                  enabled: textLayer.hasText && !widget.inkMode,
                                  textLayer: textLayer,
                                  pageSize: pageSize,
                                  onSelectionStarted: _startSelection,
                                  onSelectionMoved: _moveSelection,
                                  onSelectionFinished: _finishSelection,
                                  onPageLongPressed: _requestPageNoteAt,
                                  onTap: _clearSelection,
                                ),
                              ),
                              if (widget.enablePageTurnGestures &&
                                  !widget.inkMode)
                                Positioned.fill(
                                  child: PdfPageTurnGestureLayer(
                                    canGoPrevious: widget.canGoPrevious,
                                    canGoNext: widget.canGoNext,
                                    onPrevious: widget.onPreviousPageTurn,
                                    onNext: widget.onNextPageTurn,
                                  ),
                                ),
                              for (final PdfTextNote note in widget.notes)
                                if (note.isPageAnchorNote)
                                  PdfPageNoteMarker(
                                    note: note,
                                    pageSize: pageSize,
                                    onPressed: widget.onSavedNotePressed,
                                  ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      painter: _PdfInkPainter(
                                        strokes: widget.inkStrokes,
                                        draftPoints: _draftInkPoints,
                                        draftColorValue: widget.inkColorValue,
                                        draftTool: widget.inkTool,
                                        repaint: _draftInkRepaint,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.inkMode)
                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    dragStartBehavior: DragStartBehavior.down,
                                    onPanStart: (DragStartDetails details) =>
                                        _startInk(
                                      details.localPosition,
                                      pageSize,
                                    ),
                                    onPanUpdate: (DragUpdateDetails details) =>
                                        _updateInk(
                                      details.localPosition,
                                      pageSize,
                                    ),
                                    onPanEnd: (_) => _finishInk(),
                                    onPanCancel: _cancelInk,
                                  ),
                                ),
                              if (_selectedText.isNotEmpty && !widget.inkMode)
                                PdfSelectionToolbarPosition(
                                  selectedBounds: _selectedLocalBounds(
                                    textLayer: textLayer,
                                    pageSize: pageSize,
                                  ),
                                  pageSize: pageSize,
                                  child: PdfSelectionToolbar(
                                    onCopy: _copySelectedText,
                                    onShare: _shareSelectedText,
                                    onNote: _requestNoteForSelectedText,
                                  ),
                                ),
                            ],
                          ),
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

  void _startInk(Offset position, Size pageSize) {
    _clearDraftInk();
    _draftInkPoints.add(_inkPoint(position, pageSize));
    _draftInkRepaint.repaint();
  }

  void _updateInk(Offset position, Size pageSize) {
    if (_draftInkPoints.isEmpty) {
      return;
    }
    final PdfInkPoint point = _inkPoint(position, pageSize);
    final PdfInkPoint previous = _draftInkPoints.last;
    final double dx = (point.xRatio - previous.xRatio) * pageSize.width;
    final double dy = (point.yRatio - previous.yRatio) * pageSize.height;
    if (dx * dx + dy * dy < 1) {
      return;
    }
    _draftInkPoints.add(point);
    _draftInkRepaint.repaint();
  }

  void _finishInk() {
    if (_draftInkPoints.isEmpty) {
      _cancelInk();
      return;
    }
    final PdfInkStroke stroke = PdfInkStroke(
      id: widget.path +
          '-' +
          widget.pageIndex.toString() +
          '-' +
          DateTime.now().microsecondsSinceEpoch.toString(),
      pageIndex: widget.pageIndex,
      colorValue: widget.inkColorValue,
      tool: widget.inkTool,
      widthRatio: widget.inkTool == PdfInkTool.highlighter ? 0.018 : 0.0045,
      points: List<PdfInkPoint>.unmodifiable(_draftInkPoints),
    );
    _clearDraftInk();
    widget.onInkStrokeCompleted?.call(stroke);
  }

  void _cancelInk() => _clearDraftInk();

  void _clearDraftInk() {
    if (_draftInkPoints.isEmpty) {
      return;
    }
    _draftInkPoints.clear();
    _draftInkRepaint.repaint();
  }

  PdfInkPoint _inkPoint(Offset position, Size pageSize) {
    return PdfInkPoint(
      xRatio: _ratioOf(position.dx, pageSize.width),
      yRatio: _ratioOf(position.dy, pageSize.height),
    );
  }

  String get _selectedText {
    return _selectedContents
        .map((PdfTextContentInfo content) => content.text)
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<PdfTextBounds> get _highlightRects {
    return widget.highlights
        .expand((PdfTextHighlight highlight) => highlight.bounds)
        .toList(growable: false);
  }

  List<PdfTextBounds> get _selectedRects {
    return _boundsFromContents(_selectedContents);
  }

  void _startSelection({
    required Offset position,
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) {
    final Offset clamped = _clampOffset(position, pageSize);
    final List<PdfTextContentInfo> contents = _contentsNearPosition(
      position: clamped,
      textLayer: textLayer,
      pageSize: pageSize,
    );
    if (contents.isEmpty) {
      _requestPageNoteAt(position: clamped, pageSize: pageSize);
      return;
    }

    setState(() {
      _selectionStart = clamped;
      _selectionEnd = clamped;
      _selectedContents = contents;
    });
  }

  void _moveSelection({
    required Offset position,
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) {
    if (_selectionStart == null) {
      return;
    }

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
      final bool shared = await _shareText(text);
      if (!shared) {
        await _copyTextToClipboard(text);
      }
      _clearSelection();
    } catch (_) {
      await _copyTextToClipboard(text);
      _clearSelection();
    }
  }

  void _requestNoteForSelectedText() {
    final String text = _selectedText;
    if (text.isEmpty || _selectedContents.isEmpty) {
      return;
    }

    widget.onNoteRequested(
      selectedText: text,
      bounds: _selectedRects,
      anchor: null,
    );
    _clearSelection();
  }

  void _requestPageNoteAt({
    required Offset position,
    required Size pageSize,
  }) {
    final Offset clamped = _clampOffset(position, pageSize);
    _clearSelection();
    widget.onNoteRequested(
      selectedText: '',
      bounds: const <PdfTextBounds>[],
      anchor: PdfPageAnchor(
        xRatio: _ratioOf(clamped.dx, pageSize.width),
        yRatio: _ratioOf(clamped.dy, pageSize.height),
      ),
    );
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
      return content.bounds.any((PdfTextBounds pageRect) {
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

  List<PdfTextContentInfo> _contentsNearPosition({
    required Offset position,
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) {
    if (!textLayer.hasText) {
      return const <PdfTextContentInfo>[];
    }

    final Rect hitRect = Rect.fromCircle(center: position, radius: 20);

    for (final PdfTextContentInfo content in textLayer.contents) {
      for (final PdfTextBounds pageRect in content.bounds) {
        final Rect localRect = _pageRectToLocal(
          pageRect,
          textLayer: textLayer,
          pageSize: pageSize,
        );
        if (hitRect.overlaps(localRect.inflate(5)) ||
            localRect.contains(position)) {
          return <PdfTextContentInfo>[content];
        }
      }
    }

    return const <PdfTextContentInfo>[];
  }

  Rect? _selectedLocalBounds({
    required PdfPageTextLayer textLayer,
    required Size pageSize,
  }) {
    Rect? bounds;
    for (final PdfTextContentInfo content in _selectedContents) {
      for (final PdfTextBounds pageRect in content.bounds) {
        final Rect localRect = _pageRectToLocal(
          pageRect,
          textLayer: textLayer,
          pageSize: pageSize,
        );
        bounds = bounds == null ? localRect : _mergeRects(bounds, localRect);
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

  Future<PdfPageTextLayer> _loadTextLayer() async {
    final PdfReaderResult<PdfPageTextLayer> result = await widget.getTextLayer(
      GetPdfTextLayerParams(
        path: widget.path,
        pageIndex: widget.pageIndex,
      ),
    );

    return result.fold(
      onSuccess: (PdfPageTextLayer textLayer) => textLayer,
      onFailure: (_) => const PdfPageTextLayer.empty(),
    );
  }

  Future<Uint8List> _renderPage(int width) async {
    final PdfReaderResult<Uint8List> result = await widget.renderPage(
      RenderPdfPageParams(
        path: widget.path,
        pageIndex: widget.pageIndex,
        width: width,
      ),
    );

    return result.fold(
      onSuccess: (Uint8List bytes) => bytes,
      onFailure: (failure) => throw StateError(failure.message),
    );
  }

  Future<bool> _shareText(String text) async {
    final PdfReaderResult<bool> result = await widget.shareText(
      SharePdfTextParams(text: text),
    );

    return result.fold(
      onSuccess: (bool shared) => shared,
      onFailure: (_) => false,
    );
  }
}

class _InkDraftNotifier extends ChangeNotifier {
  void repaint() => notifyListeners();
}

class _PdfInkPainter extends CustomPainter {
  _PdfInkPainter({
    required this.strokes,
    required this.draftPoints,
    required this.draftColorValue,
    required this.draftTool,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<PdfInkStroke> strokes;
  final List<PdfInkPoint> draftPoints;
  final int draftColorValue;
  final PdfInkTool draftTool;

  @override
  void paint(Canvas canvas, Size size) {
    for (final PdfInkStroke stroke in strokes) {
      _paintStroke(
        canvas,
        size,
        points: stroke.points,
        colorValue: stroke.colorValue,
        widthRatio: stroke.widthRatio,
        tool: stroke.tool,
      );
    }
    _paintStroke(
      canvas,
      size,
      points: draftPoints,
      colorValue: draftColorValue,
      widthRatio: draftTool == PdfInkTool.highlighter ? 0.018 : 0.0045,
      tool: draftTool,
    );
  }

  void _paintStroke(
    Canvas canvas,
    Size size, {
    required List<PdfInkPoint> points,
    required int colorValue,
    required double widthRatio,
    required PdfInkTool tool,
  }) {
    if (points.isEmpty) {
      return;
    }
    final double minimumWidth = tool == PdfInkTool.highlighter ? 7 : 1.6;
    final double strokeWidth =
        math.max(minimumWidth, size.shortestSide * widthRatio);
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..color = Color(colorValue)
          .withValues(alpha: tool == PdfInkTool.highlighter ? 0.34 : 0.96)
      ..blendMode = tool == PdfInkTool.highlighter
          ? BlendMode.multiply
          : BlendMode.srcOver
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final Offset first = Offset(
      points.first.xRatio * size.width,
      points.first.yRatio * size.height,
    );
    if (points.length == 1) {
      canvas.drawCircle(
          first, strokeWidth / 2, paint..style = PaintingStyle.fill);
      return;
    }

    final Path path = Path()..moveTo(first.dx, first.dy);
    for (int index = 1; index < points.length - 1; index++) {
      final PdfInkPoint point = points[index];
      final PdfInkPoint following = points[index + 1];
      final Offset control = Offset(
        point.xRatio * size.width,
        point.yRatio * size.height,
      );
      final Offset next = Offset(
        following.xRatio * size.width,
        following.yRatio * size.height,
      );
      final Offset end = Offset.lerp(control, next, 0.5)!;
      path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    }
    final PdfInkPoint last = points.last;
    path.lineTo(
      last.xRatio * size.width,
      last.yRatio * size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PdfInkPainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        draftPoints != oldDelegate.draftPoints ||
        draftColorValue != oldDelegate.draftColorValue ||
        draftTool != oldDelegate.draftTool;
  }
}

class _TextBoundsPainter extends CustomPainter {
  const _TextBoundsPainter({
    required this.rects,
    required this.textLayer,
    required this.pageSize,
    required this.color,
  });

  final List<PdfTextBounds> rects;
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

    for (final PdfTextBounds pageRect in rects) {
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

double _ratioOf(double value, double size) {
  if (size <= 0) {
    return 0;
  }

  return (value / size).clamp(0.0, 1.0).toDouble();
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
  PdfTextBounds pageRect, {
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

List<PdfTextBounds> _boundsFromContents(
  Iterable<PdfTextContentInfo> contents,
) {
  return contents
      .expand((PdfTextContentInfo content) => content.bounds)
      .toList(growable: false);
}
