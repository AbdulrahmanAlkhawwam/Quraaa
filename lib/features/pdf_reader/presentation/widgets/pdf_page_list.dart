import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/use_cases/get_pdf_text_layer_use_case.dart';
import '../../domain/use_cases/render_pdf_page_use_case.dart';
import '../../domain/use_cases/share_pdf_text_use_case.dart';
import 'pdf_page_list_item.dart';

typedef PdfPageHighlightAdded = void Function(
  int pageIndex,
  PdfTextHighlight highlight,
);

class PdfPageList extends StatelessWidget {
  const PdfPageList({
    required this.controller,
    required this.renderPage,
    required this.getTextLayer,
    required this.shareText,
    required this.path,
    required this.pageCount,
    required this.highlightsByPage,
    required this.onHighlightAdded,
    required this.onMessage,
    required this.onPageChanged,
    super.key,
  });

  final ScrollController controller;
  final RenderPdfPageUseCase renderPage;
  final GetPdfTextLayerUseCase getTextLayer;
  final SharePdfTextUseCase shareText;
  final String path;
  final int pageCount;
  final Map<int, List<PdfTextHighlight>> highlightsByPage;
  final PdfPageHighlightAdded onHighlightAdded;
  final ValueChanged<String> onMessage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scrollbar(
          controller: controller,
          thumbVisibility: pageCount > 1,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              _reportVisiblePage(
                notification.metrics,
                constraints.maxWidth,
              );
              return false;
            },
            child: ListView.builder(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              itemBuilder: (BuildContext context, int index) {
                return PdfPageListItem(
                  renderPage: renderPage,
                  getTextLayer: getTextLayer,
                  shareText: shareText,
                  path: path,
                  pageIndex: index,
                  pageCount: pageCount,
                  highlights:
                      highlightsByPage[index] ?? const <PdfTextHighlight>[],
                  onHighlightAdded: (PdfTextHighlight highlight) {
                    onHighlightAdded(index, highlight);
                  },
                  onMessage: onMessage,
                );
              },
              itemCount: pageCount,
            ),
          ),
        );
      },
    );
  }

  void _reportVisiblePage(ScrollMetrics metrics, double viewportWidth) {
    if (pageCount <= 0) {
      return;
    }

    final double pageWidth = viewportWidth.clamp(260.0, 4200.0).toDouble();
    final double estimatedPageHeight = (pageWidth / 0.72) + 48;
    final int pageIndex = (metrics.pixels / estimatedPageHeight)
        .round()
        .clamp(0, pageCount - 1)
        .toInt();

    onPageChanged(pageIndex);
  }
}
