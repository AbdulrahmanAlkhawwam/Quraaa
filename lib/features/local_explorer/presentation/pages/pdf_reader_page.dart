import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../data/datasources/local/pdf_render_datasource.dart';
import '../widgets/pdf_page_image.dart';

class PdfReaderPage extends StatefulWidget {
  const PdfReaderPage({
    required this.path,
    required this.name,
    super.key,
  });

  final String path;
  final String name;

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  static const double _minZoom = 0.75;
  static const double _maxZoom = 2.25;
  static const double _zoomStep = 0.25;

  late final PdfRenderDataSource _renderer = sl<PdfRenderDataSource>();
  late Future<int> _pageCountFuture;
  final Map<int, List<PdfTextHighlight>> _highlightsByPage =
      <int, List<PdfTextHighlight>>{};
  double _zoom = 1;

  @override
  void initState() {
    super.initState();
    _pageCountFuture = _renderer.pageCount(widget.path);
  }

  @override
  void didUpdateWidget(covariant PdfReaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _pageCountFuture = _renderer.pageCount(widget.path);
      _highlightsByPage.clear();
      _zoom = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.pageMaxWidth,
            ),
            child: Column(
              children: <Widget>[
                _PdfHeader(
                  fileName: widget.name,
                  zoom: _zoom,
                  canZoomIn: _zoom < _maxZoom,
                  canZoomOut: _zoom > _minZoom,
                  onZoomIn: () => _changeZoom(_zoomStep),
                  onZoomOut: () => _changeZoom(-_zoomStep),
                  onResetZoom: _resetZoom,
                ),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _pageCountFuture,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return _MessageView(
                          icon: HugeIcons.strokeRoundedPdf02,
                          message:
                              LocalizationConstants.pdfReaderLoadingKey.tr(),
                        );
                      }

                      if (snapshot.hasError || (snapshot.data ?? 0) <= 0) {
                        return _MessageView(
                          icon: HugeIcons.strokeRoundedCancelCircle,
                          message:
                              LocalizationConstants.pdfReaderUnsupportedKey.tr(),
                        );
                      }

                      final int pageCount = snapshot.data!;
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Text(
                                  '${index + 1} / $pageCount',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                              ),
                              PdfPageImage(
                                renderer: _renderer,
                                path: widget.path,
                                pageIndex: index,
                                zoom: _zoom,
                                highlights: _highlightsByPage[index] ??
                                    const <PdfTextHighlight>[],
                                onHighlightAdded: (PdfTextHighlight highlight) {
                                  _addHighlight(index, highlight);
                                },
                                onMessage: _showMessage,
                              ),
                            ],
                          );
                        },
                        itemCount: pageCount,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeZoom(double amount) {
    setState(() {
      _zoom = (_zoom + amount).clamp(_minZoom, _maxZoom).toDouble();
    });
  }

  void _resetZoom() {
    setState(() {
      _zoom = 1;
    });
  }

  void _addHighlight(int pageIndex, PdfTextHighlight highlight) {
    setState(() {
      final List<PdfTextHighlight> highlights = List<PdfTextHighlight>.of(
        _highlightsByPage[pageIndex] ?? const <PdfTextHighlight>[],
      );
      highlights.add(highlight);
      _highlightsByPage[pageIndex] = highlights;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PdfHeader extends StatelessWidget {
  const _PdfHeader({
    required this.fileName,
    required this.zoom,
    required this.canZoomIn,
    required this.canZoomOut,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  final String fileName;
  final double zoom;
  final bool canZoomIn;
  final bool canZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget leading = IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: context.canPop() ? () => context.pop() : null,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: AppColors.secondary,
              size: 34,
            ),
            color: AppColors.secondary,
            iconSize: 34,
          );
          final Widget title = _PdfTitleBlock(fileName: fileName);
          final Widget controls = _ZoomControls(
            zoom: zoom,
            canZoomIn: canZoomIn,
            canZoomOut: canZoomOut,
            onZoomIn: onZoomIn,
            onZoomOut: onZoomOut,
            onResetZoom: onResetZoom,
          );

          if (constraints.maxWidth < 430) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    leading,
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: title),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: controls,
                ),
              ],
            );
          }

          return Row(
            children: <Widget>[
              leading,
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: title),
              const SizedBox(width: AppSpacing.md),
              controls,
            ],
          );
        },
      ),
    );
  }
}

class _PdfTitleBlock extends StatelessWidget {
  const _PdfTitleBlock({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          LocalizationConstants.pdfReaderTitleKey.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.zoom,
    required this.canZoomIn,
    required this.canZoomOut,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  final double zoom;
  final bool canZoomIn;
  final bool canZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ZoomButton(
              tooltip: LocalizationConstants.pdfReaderZoomOutKey.tr(),
              icon: HugeIcons.strokeRoundedRemove01,
              onPressed: canZoomOut ? onZoomOut : null,
            ),
            Tooltip(
              message: LocalizationConstants.pdfReaderResetZoomKey.tr(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onResetZoom,
                child: SizedBox(
                  width: 54,
                  height: 38,
                  child: Center(
                    child: Text(
                      '${(zoom * 100).round()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            _ZoomButton(
              tooltip: LocalizationConstants.pdfReaderZoomInKey.tr(),
              icon: HugeIcons.strokeRoundedAdd01,
              onPressed: canZoomIn ? onZoomIn : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final List<List<dynamic>> icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: 38, height: 38),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: HugeIcon(
        icon: icon,
        color: onPressed == null ? AppColors.textMuted : AppColors.secondary,
        size: 21,
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.message,
  });

  final List<List<dynamic>> icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HugeIcon(icon: icon, color: AppColors.secondary, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
