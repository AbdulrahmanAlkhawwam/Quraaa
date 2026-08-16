import 'package:equatable/equatable.dart';

enum PdfReaderScrollDirection { vertical, horizontal }

enum PdfInkTool { highlighter, pen }

class PdfInkPoint extends Equatable {
  const PdfInkPoint({required this.xRatio, required this.yRatio});

  final double xRatio;
  final double yRatio;

  @override
  List<Object?> get props => <Object?>[xRatio, yRatio];
}

class PdfInkStroke extends Equatable {
  const PdfInkStroke({
    required this.id,
    required this.pageIndex,
    required this.colorValue,
    required this.points,
    this.tool = PdfInkTool.highlighter,
    this.widthRatio = 0.018,
  });

  final String id;
  final int pageIndex;
  final int colorValue;
  final PdfInkTool tool;
  final double widthRatio;
  final List<PdfInkPoint> points;

  @override
  List<Object?> get props => <Object?>[
        id,
        pageIndex,
        colorValue,
        tool,
        widthRatio,
        points,
      ];
}

class PdfReaderLocalState extends Equatable {
  const PdfReaderLocalState({
    this.currentPageIndex = 0,
    this.scrollDirection = PdfReaderScrollDirection.vertical,
    this.inkStrokes = const <PdfInkStroke>[],
    this.readingDays = const <DateTime>[],
  });

  final int currentPageIndex;
  final PdfReaderScrollDirection scrollDirection;
  final List<PdfInkStroke> inkStrokes;
  final List<DateTime> readingDays;

  PdfReaderLocalState copyWith({
    int? currentPageIndex,
    PdfReaderScrollDirection? scrollDirection,
    List<PdfInkStroke>? inkStrokes,
    List<DateTime>? readingDays,
  }) {
    return PdfReaderLocalState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      inkStrokes: inkStrokes ?? this.inkStrokes,
      readingDays: readingDays ?? this.readingDays,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        currentPageIndex,
        scrollDirection,
        inkStrokes,
        readingDays,
      ];
}
