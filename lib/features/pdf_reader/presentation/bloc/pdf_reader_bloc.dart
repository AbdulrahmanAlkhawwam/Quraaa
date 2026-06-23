import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/use_cases/get_pdf_page_count_use_case.dart';
import '../../domain/value_objects/pdf_reader_result.dart';

sealed class PdfReaderEvent {
  const PdfReaderEvent();
}

final class PdfReaderStarted extends PdfReaderEvent {
  const PdfReaderStarted(this.path);

  final String path;
}

final class PdfReaderPageChanged extends PdfReaderEvent {
  const PdfReaderPageChanged(this.pageIndex);

  final int pageIndex;
}

final class PdfReaderHighlightAdded extends PdfReaderEvent {
  const PdfReaderHighlightAdded({
    required this.pageIndex,
    required this.highlight,
  });

  final int pageIndex;
  final PdfTextHighlight highlight;
}

final class PdfReaderScrolled extends PdfReaderEvent {
  const PdfReaderScrolled(this.offset);

  final double offset;
}

sealed class PdfReaderState {
  const PdfReaderState();
}

final class PdfReaderInitial extends PdfReaderState {
  const PdfReaderInitial();
}

final class PdfReaderLoading extends PdfReaderState {
  const PdfReaderLoading();
}

final class PdfReaderReady extends PdfReaderState {
  const PdfReaderReady({
    required this.pageCount,
    this.currentPageIndex = 0,
    this.highlightsByPage = const <int, List<PdfTextHighlight>>{},
    this.showScrollToTopButton = false,
  });

  final int pageCount;
  final int currentPageIndex;
  final Map<int, List<PdfTextHighlight>> highlightsByPage;
  final bool showScrollToTopButton;

  PdfReaderReady copyWith({
    int? pageCount,
    int? currentPageIndex,
    Map<int, List<PdfTextHighlight>>? highlightsByPage,
    bool? showScrollToTopButton,
  }) {
    return PdfReaderReady(
      pageCount: pageCount ?? this.pageCount,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      highlightsByPage: highlightsByPage ?? this.highlightsByPage,
      showScrollToTopButton:
          showScrollToTopButton ?? this.showScrollToTopButton,
    );
  }
}

final class PdfReaderLoadFailure extends PdfReaderState {
  const PdfReaderLoadFailure({this.message});

  final String? message;
}

class PdfReaderBloc extends Bloc<PdfReaderEvent, PdfReaderState> {
  PdfReaderBloc({
    required GetPdfPageCountUseCase getPageCount,
  })  : _getPageCount = getPageCount,
        super(const PdfReaderInitial()) {
    on<PdfReaderStarted>(_onStarted);
    on<PdfReaderPageChanged>(_onPageChanged);
    on<PdfReaderHighlightAdded>(_onHighlightAdded);
    on<PdfReaderScrolled>(_onScrolled);
  }

  static const double _scrollTopThreshold = 360;

  final GetPdfPageCountUseCase _getPageCount;

  Future<void> _onStarted(
    PdfReaderStarted event,
    Emitter<PdfReaderState> emit,
  ) async {
    emit(const PdfReaderLoading());

    final PdfReaderResult<int> result = await _getPageCount(
      GetPdfPageCountParams(path: event.path),
    );

    result.fold(
      onSuccess: (int pageCount) {
        if (pageCount <= 0) {
          emit(const PdfReaderLoadFailure());
          return;
        }

        emit(PdfReaderReady(pageCount: pageCount));
      },
      onFailure: (failure) {
        emit(PdfReaderLoadFailure(message: failure.message));
      },
    );
  }

  void _onPageChanged(
    PdfReaderPageChanged event,
    Emitter<PdfReaderState> emit,
  ) {
    final PdfReaderState currentState = state;
    if (currentState is! PdfReaderReady ||
        currentState.currentPageIndex == event.pageIndex) {
      return;
    }

    emit(currentState.copyWith(currentPageIndex: event.pageIndex));
  }

  void _onHighlightAdded(
    PdfReaderHighlightAdded event,
    Emitter<PdfReaderState> emit,
  ) {
    final PdfReaderState currentState = state;
    if (currentState is! PdfReaderReady) {
      return;
    }

    final Map<int, List<PdfTextHighlight>> highlightsByPage =
        Map<int, List<PdfTextHighlight>>.of(currentState.highlightsByPage);
    final List<PdfTextHighlight> pageHighlights =
        List<PdfTextHighlight>.of(highlightsByPage[event.pageIndex] ?? const []);

    pageHighlights.add(event.highlight);
    highlightsByPage[event.pageIndex] = pageHighlights;

    emit(currentState.copyWith(highlightsByPage: highlightsByPage));
  }

  void _onScrolled(
    PdfReaderScrolled event,
    Emitter<PdfReaderState> emit,
  ) {
    final PdfReaderState currentState = state;
    if (currentState is! PdfReaderReady) {
      return;
    }

    final bool shouldShow = event.offset > _scrollTopThreshold;
    if (currentState.showScrollToTopButton == shouldShow) {
      return;
    }

    emit(currentState.copyWith(showScrollToTopButton: shouldShow));
  }
}
