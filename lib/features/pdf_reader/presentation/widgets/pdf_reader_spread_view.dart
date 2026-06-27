import 'package:flutter/material.dart';

import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/entities/pdf_text_note.dart';
import '../../domain/use_cases/get_pdf_text_layer_use_case.dart';
import '../../domain/use_cases/render_pdf_page_use_case.dart';
import '../../domain/use_cases/share_pdf_text_use_case.dart';
import '../bloc/pdf_reader_bloc.dart';
import 'pdf_page_image.dart';

class PdfReaderSpreadView extends StatelessWidget {
  const PdfReaderSpreadView({
    required this.state,
    required this.renderPage,
    required this.getTextLayer,
    required this.shareText,
    required this.onPrevious,
    required this.onNext,
    required this.onNoteRequested,
    required this.onSavedNotePressed,
    required this.onMessage,
    super.key,
  });

  final PdfReaderReady state;
  final RenderPdfPageUseCase renderPage;
  final GetPdfTextLayerUseCase getTextLayer;
  final SharePdfTextUseCase shareText;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final PdfPageNoteRequested onNoteRequested;
  final ValueChanged<PdfTextNote> onSavedNotePressed;
  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context) {
    final List<int> visiblePageIndexes = state.visiblePageIndexes;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _pageWidgets(visiblePageIndexes),
      ),
    );
  }

  List<Widget> _pageWidgets(List<int> visiblePageIndexes) {
    final List<Widget> children = <Widget>[];
    for (int position = 0; position < visiblePageIndexes.length; position++) {
      final int pageIndex = visiblePageIndexes[position];
      final List<PdfTextNote> pageNotes = _notesForPage(pageIndex);
      if (position > 0) {
        children.add(const SizedBox(width: 10));
      }

      children.add(
        Expanded(
          child: PdfPageImage(
            renderPage: renderPage,
            getTextLayer: getTextLayer,
            shareText: shareText,
            path: state.path,
            pageIndex: pageIndex,
            highlights: _highlightsFromNotes(pageNotes),
            notes: pageNotes,
            canGoPrevious: position == 0 && state.canGoPrevious,
            canGoNext: position == visiblePageIndexes.length - 1 &&
                state.canGoNext,
            onPreviousPageTurn: onPrevious,
            onNextPageTurn: onNext,
            onNoteRequested: ({
              required PdfPageAnchor? anchor,
              required List<PdfTextBounds> bounds,
              required String selectedText,
            }) {
              onNoteRequested(
                anchor: anchor,
                pageIndex: pageIndex,
                selectedText: selectedText,
                bounds: bounds,
              );
            },
            onSavedNotePressed: onSavedNotePressed,
            onMessage: onMessage,
          ),
        ),
      );
    }

    return children;
  }

  List<PdfTextNote> _notesForPage(int pageIndex) {
    return state.notesByPage[pageIndex] ?? const <PdfTextNote>[];
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
}

typedef PdfPageNoteRequested = void Function({
  required PdfPageAnchor? anchor,
  required int pageIndex,
  required String selectedText,
  required List<PdfTextBounds> bounds,
});
