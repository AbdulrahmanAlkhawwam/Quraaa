import 'package:equatable/equatable.dart';

class PdfTextBounds extends Equatable {
  const PdfTextBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  bool get isValid => right > left && bottom > top;

  @override
  List<Object?> get props => <Object?>[left, top, right, bottom];
}

class PdfTextContentInfo extends Equatable {
  const PdfTextContentInfo({
    required this.text,
    required this.bounds,
  });

  final String text;
  final List<PdfTextBounds> bounds;

  @override
  List<Object?> get props => <Object?>[text, bounds];
}

class PdfTextHighlight extends Equatable {
  const PdfTextHighlight({
    required this.text,
    required this.bounds,
  });

  final String text;
  final List<PdfTextBounds> bounds;

  @override
  List<Object?> get props => <Object?>[text, bounds];
}

class PdfPageTextLayer extends Equatable {
  const PdfPageTextLayer({
    required this.width,
    required this.height,
    required this.contents,
  });

  const PdfPageTextLayer.empty({
    this.width = 1,
    this.height = 1,
  }) : contents = const <PdfTextContentInfo>[];

  final double width;
  final double height;
  final List<PdfTextContentInfo> contents;

  bool get hasText => contents.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[width, height, contents];
}
