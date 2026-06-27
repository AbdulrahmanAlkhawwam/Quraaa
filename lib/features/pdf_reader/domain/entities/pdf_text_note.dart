import 'package:equatable/equatable.dart';

import 'pdf_text_layer.dart';

class PdfPageAnchor extends Equatable {
  const PdfPageAnchor({
    required this.xRatio,
    required this.yRatio,
  });

  final double xRatio;
  final double yRatio;

  @override
  List<Object?> get props => <Object?>[xRatio, yRatio];
}

class PdfTextNote extends Equatable {
  const PdfTextNote({
    required this.id,
    required this.path,
    required this.pageIndex,
    required this.selectedText,
    required this.note,
    required this.bounds,
    required this.createdAt,
    this.anchor,
  });

  final String id;
  final String path;
  final int pageIndex;
  final String selectedText;
  final String note;
  final List<PdfTextBounds> bounds;
  final DateTime createdAt;
  final PdfPageAnchor? anchor;

  bool get isTextSelectionNote => selectedText.trim().isNotEmpty;

  bool get isPageAnchorNote => anchor != null;

  @override
  List<Object?> get props => <Object?>[
        id,
        path,
        pageIndex,
        selectedText,
        note,
        bounds,
        createdAt,
        anchor,
      ];
}
