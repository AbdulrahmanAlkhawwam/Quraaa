import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../../../core/localization/localization_constants.dart';
import '../../domain/entities/pdf_reader_local_state.dart';
import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/entities/pdf_text_note.dart';
import '../../domain/use_cases/get_pdf_text_layer_use_case.dart';
import '../../domain/use_cases/render_pdf_page_use_case.dart';
import '../../domain/use_cases/share_pdf_text_use_case.dart';
import '../bloc/pdf_reader_bloc.dart';
import 'pdf_page_image.dart';
import 'pdf_reader_spread_view.dart';
import 'pdf_reader_zoom_controls.dart';

class PdfReaderContinuousView extends StatefulWidget {
  const PdfReaderContinuousView({
    required this.state,
    required this.scrollDirection,
    required this.inkStrokes,
    required this.inkMode,
    required this.inkColorValue,
    required this.inkTool,
    required this.renderPage,
    required this.getTextLayer,
    required this.shareText,
    required this.onPageChanged,
    required this.onInkStrokeCompleted,
    required this.onNoteRequested,
    required this.onSavedNotePressed,
    required this.onMessage,
    super.key,
  });

  final PdfReaderReady state;
  final PdfReaderScrollDirection scrollDirection;
  final List<PdfInkStroke> inkStrokes;
  final bool inkMode;
  final int inkColorValue;
  final PdfInkTool inkTool;
  final RenderPdfPageUseCase renderPage;
  final GetPdfTextLayerUseCase getTextLayer;
  final SharePdfTextUseCase shareText;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<PdfInkStroke> onInkStrokeCompleted;
  final PdfPageNoteRequested onNoteRequested;
  final ValueChanged<PdfTextNote> onSavedNotePressed;
  final ValueChanged<String> onMessage;

  @override
  State<PdfReaderContinuousView> createState() =>
      _PdfReaderContinuousViewState();
}

class _PdfReaderContinuousViewState extends State<PdfReaderContinuousView>
    with SingleTickerProviderStateMixin {
  static const double _minZoomScale = 1;
  static const double _maxZoomScale = 4;
  static const List<double> _zoomStops = <double>[
    1,
    1.25,
    1.5,
    2,
    2.5,
    3,
    4,
  ];

  late final ScrollController _controller = ScrollController();
  late final TransformationController _transformationController =
      TransformationController()..addListener(_handleTransformationChanged);
  late final AnimationController _zoomAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )
    ..addListener(_handleZoomAnimationTick)
    ..addStatusListener(_handleZoomAnimationStatus);
  final ValueNotifier<double> _zoomScale = ValueNotifier<double>(1);
  final Map<int, Offset> _activePointers = <int, Offset>{};
  Animation<Matrix4>? _zoomAnimation;
  double _itemExtent = 1;
  double _pinchStartDistance = 1;
  double _pinchStartScale = 1;
  double _renderQualityScale = 1;
  bool _initialPositionScheduled = false;
  bool _isPinching = false;
  bool _isZoomed = false;
  int _lastReportedPage = -1;
  Offset _doubleTapPosition = Offset.zero;
  Offset _pinchStartSceneFocalPoint = Offset.zero;
  Size _viewportSize = Size.zero;

  @override
  void didUpdateWidget(covariant PdfReaderContinuousView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.path != widget.state.path) {
      _initialPositionScheduled = false;
      _lastReportedPage = -1;
    }
    if (!oldWidget.inkMode && widget.inkMode) {
      _resetZoomImmediately();
    }
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    _transformationController
      ..removeListener(_handleTransformationChanged)
      ..dispose();
    _zoomScale.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Axis axis =
        widget.scrollDirection == PdfReaderScrollDirection.vertical
            ? Axis.vertical
            : Axis.horizontal;
    final Map<int, List<PdfInkStroke>> strokesByPage =
        <int, List<PdfInkStroke>>{};
    for (final PdfInkStroke stroke in widget.inkStrokes) {
      strokesByPage
          .putIfAbsent(stroke.pageIndex, () => <PdfInkStroke>[])
          .add(stroke);
    }

    return ColoredBox(
      color: const Color(0xFFF8F8F8),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final _PageGeometry geometry = _geometry(constraints, axis);
          _viewportSize = constraints.biggest;
          _itemExtent = geometry.itemExtent;
          _scheduleInitialPosition();

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _handlePointerDown,
                onPointerMove: _handlePointerMove,
                onPointerUp: _handlePointerEnded,
                onPointerCancel: _handlePointerEnded,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTapDown: widget.inkMode
                      ? null
                      : (TapDownDetails details) {
                          _doubleTapPosition = details.localPosition;
                        },
                  onDoubleTap: widget.inkMode ? null : _handleDoubleTap,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: _minZoomScale,
                    maxScale: _maxZoomScale,
                    boundaryMargin: EdgeInsets.zero,
                    panEnabled: false,
                    scaleEnabled: false,
                    clipBehavior: Clip.hardEdge,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _handleScrollNotification,
                      child: ListView.builder(
                        controller: _controller,
                        scrollDirection: axis,
                        physics: _isZoomed || _isPinching
                            ? const NeverScrollableScrollPhysics()
                            : _physicsFor(axis),
                        itemExtent: geometry.itemExtent,
                        scrollCacheExtent: ScrollCacheExtent.pixels(
                          geometry.itemExtent * 2.25,
                        ),
                        itemCount: widget.state.pageCount,
                        itemBuilder: (BuildContext context, int pageIndex) {
                          final List<PdfTextNote> pageNotes =
                              widget.state.notesByPage[pageIndex] ??
                                  const <PdfTextNote>[];
                          final List<PdfInkStroke> pageStrokes =
                              strokesByPage[pageIndex] ??
                                  const <PdfInkStroke>[];

                          return Center(
                            child: Padding(
                              padding: axis == Axis.vertical
                                  ? const EdgeInsets.only(bottom: 8)
                                  : const EdgeInsets.symmetric(horizontal: 5),
                              child: SizedBox(
                                width: geometry.pageWidth,
                                height: geometry.pageHeight,
                                child: PdfPageImage(
                                  key: ValueKey<String>(
                                    '${widget.state.path}:$pageIndex',
                                  ),
                                  renderPage: widget.renderPage,
                                  getTextLayer: widget.getTextLayer,
                                  shareText: widget.shareText,
                                  path: widget.state.path,
                                  pageIndex: pageIndex,
                                  highlights: _highlightsFromNotes(pageNotes),
                                  notes: pageNotes,
                                  canGoPrevious: false,
                                  canGoNext: false,
                                  onPreviousPageTurn: _noop,
                                  onNextPageTurn: _noop,
                                  onNoteRequested: ({
                                    required PdfPageAnchor? anchor,
                                    required List<PdfTextBounds> bounds,
                                    required String selectedText,
                                  }) {
                                    widget.onNoteRequested(
                                      anchor: anchor,
                                      pageIndex: pageIndex,
                                      selectedText: selectedText,
                                      bounds: bounds,
                                    );
                                  },
                                  onSavedNotePressed: widget.onSavedNotePressed,
                                  onMessage: widget.onMessage,
                                  enablePageTurnGestures: false,
                                  continuousScrolling: true,
                                  renderQualityScale: _renderQualityScale,
                                  inkMode: widget.inkMode,
                                  inkColorValue: widget.inkColorValue,
                                  inkTool: widget.inkTool,
                                  inkStrokes: pageStrokes,
                                  onInkStrokeCompleted:
                                      widget.onInkStrokeCompleted,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (!widget.inkMode)
                PositionedDirectional(
                  end: 12,
                  bottom: 12,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _zoomScale,
                    builder: (
                      BuildContext context,
                      double scale,
                      Widget? child,
                    ) {
                      return PdfReaderZoomControls(
                        scale: scale,
                        minScale: _minZoomScale,
                        maxScale: _maxZoomScale,
                        zoomInLabel:
                            LocalizationConstants.pdfReaderZoomInKey.tr(),
                        zoomOutLabel:
                            LocalizationConstants.pdfReaderZoomOutKey.tr(),
                        resetZoomLabel:
                            LocalizationConstants.pdfReaderResetZoomKey.tr(),
                        onZoomIn: _zoomIn,
                        onZoomOut: _zoomOut,
                        onResetZoom: _resetZoom,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification &&
        notification is! ScrollEndNotification) {
      return false;
    }
    final double focusOffset = notification.metrics.pixels +
        notification.metrics.viewportDimension * 0.38;
    final int pageIndex = (focusOffset / math.max(_itemExtent, 1))
        .floor()
        .clamp(0, widget.state.pageCount - 1)
        .toInt();
    if (pageIndex != _lastReportedPage) {
      _lastReportedPage = pageIndex;
      widget.onPageChanged(pageIndex);
    }
    return false;
  }

  void _scheduleInitialPosition() {
    if (_initialPositionScheduled) {
      return;
    }
    _initialPositionScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }
      final double target =
          widget.state.currentPageIndex * math.max(_itemExtent, 1);
      _controller.jumpTo(
        target.clamp(
          0.0,
          _controller.position.maxScrollExtent,
        ),
      );
      _lastReportedPage = widget.state.currentPageIndex;
    });
  }

  _PageGeometry _geometry(BoxConstraints constraints, Axis axis) {
    const double aspectRatio = 0.72;
    if (axis == Axis.vertical) {
      final double pageWidth = math.max(120, constraints.maxWidth - 8);
      final double pageHeight = pageWidth / aspectRatio;
      return _PageGeometry(
        pageWidth: pageWidth,
        pageHeight: pageHeight,
        itemExtent: pageHeight + 8,
      );
    }

    final double availableHeight = math.max(120, constraints.maxHeight - 8);
    final double pageWidth = math.min(
      math.max(120, constraints.maxWidth - 10),
      availableHeight * aspectRatio,
    );
    final double pageHeight = pageWidth / aspectRatio;
    return _PageGeometry(
      pageWidth: pageWidth,
      pageHeight: pageHeight,
      itemExtent: math.max(120, constraints.maxWidth),
    );
  }

  List<PdfTextHighlight> _highlightsFromNotes(List<PdfTextNote> notes) {
    return notes
        .where((PdfTextNote note) => note.bounds.isNotEmpty)
        .map(
          (PdfTextNote note) => PdfTextHighlight(
            text: note.selectedText,
            bounds: note.bounds,
          ),
        )
        .toList(growable: false);
  }

  static void _noop() {}

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.inkMode || event.kind != PointerDeviceKind.touch) {
      return;
    }
    _activePointers[event.pointer] = event.localPosition;
    _stopZoomAnimation();
    if (_activePointers.length >= 2) {
      _beginPinch();
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final Offset? previousPosition = _activePointers[event.pointer];
    if (previousPosition == null) {
      return;
    }
    _activePointers[event.pointer] = event.localPosition;

    if (_isPinching && _activePointers.length >= 2) {
      _updatePinch();
      return;
    }
    if (_isZoomed && _activePointers.length == 1) {
      _panViewport(event.localPosition - previousPosition);
    }
  }

  void _handlePointerEnded(PointerEvent event) {
    if (_activePointers.remove(event.pointer) == null) {
      return;
    }
    if (_activePointers.length >= 2) {
      _beginPinch();
      return;
    }

    final bool wasPinching = _isPinching;
    if (wasPinching && mounted) {
      setState(() => _isPinching = false);
    }
    if (wasPinching || _activePointers.isEmpty) {
      _commitZoomState();
    }
  }

  void _beginPinch() {
    final List<Offset> points = _activePointers.values.take(2).toList();
    if (points.length < 2) {
      return;
    }
    final Offset focalPoint = Offset.lerp(points[0], points[1], 0.5)!;
    _pinchStartDistance = math.max((points[0] - points[1]).distance, 1);
    _pinchStartScale = _currentZoomScale;
    _pinchStartSceneFocalPoint = _transformationController.toScene(focalPoint);
    if (!_isPinching && mounted) {
      setState(() => _isPinching = true);
    }
  }

  void _updatePinch() {
    final List<Offset> points = _activePointers.values.take(2).toList();
    if (points.length < 2) {
      return;
    }
    final Offset focalPoint = Offset.lerp(points[0], points[1], 0.5)!;
    final double distance = math.max((points[0] - points[1]).distance, 1);
    final double targetScale =
        (_pinchStartScale * distance / _pinchStartDistance)
            .clamp(_minZoomScale, _maxZoomScale)
            .toDouble();
    _transformationController.value = _matrixForSceneAnchor(
      targetScale,
      focalPoint: focalPoint,
      scenePoint: _pinchStartSceneFocalPoint,
    );
  }

  void _panViewport(Offset delta) {
    if (delta == Offset.zero) {
      return;
    }
    final double scale = _currentZoomScale;
    final translation = _transformationController.value.getTranslation();
    final double minX = _viewportSize.width * (1 - scale);
    final double minY = _viewportSize.height * (1 - scale);
    final double translationX =
        (translation.x + delta.dx).clamp(minX, 0.0).toDouble();
    final double translationY =
        (translation.y + delta.dy).clamp(minY, 0.0).toDouble();
    _transformationController.value = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(translationX, translationY, 0);
  }

  void _handleTransformationChanged() {
    final double scale = _currentZoomScale;
    if ((_zoomScale.value - scale).abs() > 0.001) {
      _zoomScale.value = scale;
    }
    if (!_isZoomed &&
        scale > _minZoomScale + 0.01 &&
        !_zoomAnimationController.isAnimating &&
        mounted) {
      setState(() => _isZoomed = true);
    }
  }

  void _handleZoomAnimationTick() {
    final Animation<Matrix4>? animation = _zoomAnimation;
    if (animation != null) {
      _transformationController.value = animation.value;
    }
  }

  void _handleZoomAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    _zoomAnimation = null;
    _commitZoomState();
  }

  void _handleDoubleTap() {
    final double targetScale = _isZoomed ? _minZoomScale : 2;
    _animateToScale(targetScale, focalPoint: _doubleTapPosition);
  }

  void _zoomIn() {
    final double currentScale = _currentZoomScale;
    final double targetScale = _zoomStops.firstWhere(
      (double scale) => scale > currentScale + 0.01,
      orElse: () => _maxZoomScale,
    );
    _animateToScale(targetScale, focalPoint: _viewportCenter);
  }

  void _zoomOut() {
    final double currentScale = _currentZoomScale;
    final double targetScale = _zoomStops.lastWhere(
      (double scale) => scale < currentScale - 0.01,
      orElse: () => _minZoomScale,
    );
    _animateToScale(targetScale, focalPoint: _viewportCenter);
  }

  void _resetZoom() {
    _animateToScale(_minZoomScale, focalPoint: _viewportCenter);
  }

  void _animateToScale(double targetScale, {required Offset focalPoint}) {
    final double safeScale =
        targetScale.clamp(_minZoomScale, _maxZoomScale).toDouble();
    final Matrix4 target = _matrixForScale(safeScale, focalPoint);
    _stopZoomAnimation();

    if (safeScale > _minZoomScale + 0.01 && !_isZoomed) {
      setState(() => _isZoomed = true);
    }

    _zoomAnimation = Matrix4Tween(
      begin: Matrix4.copy(_transformationController.value),
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _zoomAnimationController.forward(from: 0);
  }

  Matrix4 _matrixForScale(double targetScale, Offset focalPoint) {
    if (targetScale <= _minZoomScale + 0.001) {
      return Matrix4.identity();
    }

    return _matrixForSceneAnchor(
      targetScale,
      focalPoint: focalPoint,
      scenePoint: _transformationController.toScene(focalPoint),
    );
  }

  Matrix4 _matrixForSceneAnchor(
    double targetScale, {
    required Offset focalPoint,
    required Offset scenePoint,
  }) {
    final double minX = _viewportSize.width * (1 - targetScale);
    final double minY = _viewportSize.height * (1 - targetScale);
    final double translationX = (focalPoint.dx - scenePoint.dx * targetScale)
        .clamp(minX, 0.0)
        .toDouble();
    final double translationY = (focalPoint.dy - scenePoint.dy * targetScale)
        .clamp(minY, 0.0)
        .toDouble();

    return Matrix4.diagonal3Values(targetScale, targetScale, 1)
      ..setTranslationRaw(translationX, translationY, 0);
  }

  void _stopZoomAnimation() {
    if (_zoomAnimationController.isAnimating) {
      _zoomAnimationController.stop();
    }
    _zoomAnimation = null;
  }

  void _commitZoomState() {
    final double scale = _currentZoomScale;
    final bool isZoomed = scale > _minZoomScale + 0.01;
    final double renderQualityScale = _qualityScaleFor(scale);

    if (!isZoomed) {
      _transformationController.value = Matrix4.identity();
    }
    if (_isZoomed == isZoomed &&
        (_renderQualityScale - renderQualityScale).abs() < 0.01) {
      return;
    }
    setState(() {
      _isZoomed = isZoomed;
      _renderQualityScale = renderQualityScale;
    });
  }

  void _resetZoomImmediately() {
    _stopZoomAnimation();
    _activePointers.clear();
    _transformationController.value = Matrix4.identity();
    _zoomScale.value = _minZoomScale;
    _isPinching = false;
    _isZoomed = false;
    _renderQualityScale = 1;
  }

  double _qualityScaleFor(double scale) {
    if (scale < 1.2) {
      return 1;
    }
    if (scale < 1.75) {
      return 1.5;
    }
    if (scale < 2.5) {
      return 2;
    }
    return 2.25;
  }

  double get _currentZoomScale => _transformationController.value
      .getMaxScaleOnAxis()
      .clamp(
        _minZoomScale,
        _maxZoomScale,
      )
      .toDouble();

  Offset get _viewportCenter => Offset(
        _viewportSize.width / 2,
        _viewportSize.height / 2,
      );

  ScrollPhysics _physicsFor(Axis axis) {
    const ScrollPhysics base = BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
    return axis == Axis.horizontal
        ? const PageScrollPhysics(parent: base)
        : base;
  }
}

class _PageGeometry {
  const _PageGeometry({
    required this.pageWidth,
    required this.pageHeight,
    required this.itemExtent,
  });

  final double pageWidth;
  final double pageHeight;
  final double itemExtent;
}
