import 'package:flutter/material.dart';

import '../../data/datasources/local/pdf_render_datasource.dart';
import 'pdf_page_image.dart';
import 'pdf_page_number_label.dart';

class PdfPageListItem extends StatelessWidget {
  const PdfPageListItem({
    required this.renderer,
    required this.path,
    required this.pageIndex,
    required this.pageCount,
    required this.highlights,
    required this.onHighlightAdded,
    required this.onMessage,
    super.key,
  });

  final PdfRenderDataSource renderer;
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
          renderer: renderer,
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
