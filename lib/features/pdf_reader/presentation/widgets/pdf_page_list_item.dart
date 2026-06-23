import 'package:flutter/material.dart';

import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/use_cases/get_pdf_text_layer_use_case.dart';
import '../../domain/use_cases/render_pdf_page_use_case.dart';
import '../../domain/use_cases/share_pdf_text_use_case.dart';
import 'pdf_page_image.dart';
import 'pdf_page_number_label.dart';

class PdfPageListItem extends StatelessWidget {
  const PdfPageListItem({
    required this.renderPage,
    required this.getTextLayer,
    required this.shareText,
    required this.path,
    required this.pageIndex,
    required this.pageCount,
    required this.highlights,
    required this.onHighlightAdded,
    required this.onMessage,
    super.key,
  });

  final RenderPdfPageUseCase renderPage;
  final GetPdfTextLayerUseCase getTextLayer;
  final SharePdfTextUseCase shareText;
  final String path;
  final int pageIndex;
  final int pageCount;
  final List<PdfTextHighlight> highlights;
  final ValueChanged<PdfTextHighlight> onHighlightAdded;
  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PdfPageNumberLabel(
          pageIndex: pageIndex,
          pageCount: pageCount,
        ),
        PdfPageImage(
          renderPage: renderPage,
          getTextLayer: getTextLayer,
          shareText: shareText,
          path: path,
          pageIndex: pageIndex,
          highlights: highlights,
          onHighlightAdded: onHighlightAdded,
          onMessage: onMessage,
        ),
      ],
    );
  }
}
