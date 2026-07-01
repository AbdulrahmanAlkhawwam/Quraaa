import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/entities/pdf_text_note.dart';
import '../../domain/use_cases/delete_pdf_text_note_use_case.dart';
import '../../domain/use_cases/get_pdf_page_count_use_case.dart';
import '../../domain/use_cases/load_pdf_text_notes_use_case.dart';
import '../../domain/use_cases/save_pdf_text_note_use_case.dart';
import '../../domain/value_objects/pdf_reader_result.dart';

enum PdfReaderSpreadMode { singlePage, twoPages }

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

final class PdfReaderPreviousPageRequested extends PdfReaderEvent {
  const PdfReaderPreviousPageRequested();
}

final class PdfReaderNextPageRequested extends PdfReaderEvent {
  const PdfReaderNextPageRequested();
}

final class PdfReaderSpreadModeChanged extends PdfReaderEvent {
  const PdfReaderSpreadModeChanged(this.mode);

  final PdfReaderSpreadMode mode;
}

final class PdfReaderNoteSaveRequested extends PdfReaderEvent {
  const PdfReaderNoteSaveRequested({
    required this.pageIndex,
    required this.selectedText,
    required this.note,
    required this.bounds,
    this.anchor,
  });

  final int pageIndex;
  final String selectedText;
  final String note;
  final List<PdfTextBounds> bounds;
  final PdfPageAnchor? anchor;
}

final class PdfReaderNoteDeleteRequested extends PdfReaderEvent {
  const PdfReaderNoteDeleteRequested(this.note);

  final PdfTextNote note;
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
    required this.path,
    required this.pageCount,
    this.currentPageIndex = 0,
    this.spreadMode = PdfReaderSpreadMode.singlePage,
    this.notesByPage = const <int, List<PdfTextNote>>{},
  });

  final String path;
  final int pageCount;
  final int currentPageIndex;
  final PdfReaderSpreadMode spreadMode;
  final Map<int, List<PdfTextNote>> notesByPage;

  int get spreadSize =>
      spreadMode == PdfReaderSpreadMode.twoPages ? 2 : 1;

  bool get canGoPrevious => currentPageIndex > 0;

  bool get canGoNext => currentPageIndex + spreadSize < pageCount;

  List<int> get visiblePageIndexes {
    final int secondPageIndex = currentPageIndex + 1;
    if (spreadMode == PdfReaderSpreadMode.twoPages &&
        secondPageIndex < pageCount) {
      return <int>[currentPageIndex, secondPageIndex];
    }

    return <int>[currentPageIndex];
  }

  PdfReaderReady copyWith({
    String? path,
    int? pageCount,
    int? currentPageIndex,
    PdfReaderSpreadMode? spreadMode,
    Map<int, List<PdfTextNote>>? notesByPage,
  }) {
    return PdfReaderReady(
      path: path ?? this.path,
      pageCount: pageCount ?? this.pageCount,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      spreadMode: spreadMode ?? this.spreadMode,
      notesByPage: notesByPage ?? this.notesByPage,
    );
  }
}

final class PdfReaderLoadFailure extends PdfReaderState {
  const PdfReaderLoadFailure({this.message});

  final String? message;
}

class PdfReaderBloc extends Bloc<PdfReaderEvent, PdfReaderState> {
  PdfReaderBloc({
    required this._getPageCount,
    required this._loadNotes,
    required this._saveNote,
    required this._deleteNote,
  }) : super(const PdfReaderInitial()) {
    on<PdfReaderStarted>(_onStarted);
    on<PdfReaderPageChanged>(_onPageChanged);
    on<PdfReaderPreviousPageRequested>(_onPreviousPageRequested);
    on<PdfReaderNextPageRequested>(_onNextPageRequested);
    on<PdfReaderSpreadModeChanged>(_onSpreadModeChanged);
    on<PdfReaderNoteSaveRequested>(_onNoteSaveRequested);
    on<PdfReaderNoteDeleteRequested>(_onNoteDeleteRequested);
  }

  final GetPdfPageCountUseCase _getPageCount;
  final LoadPdfTextNotesUseCase _loadNotes;
  final SavePdfTextNoteUseCase _saveNote;
  final DeletePdfTextNoteUseCase _deleteNote;

  Future<void> _onStarted(
    PdfReaderStarted event,
    Emitter<PdfReaderState> emit,
  ) async {
    emit(const PdfReaderLoading());

    final PdfReaderResult<int> result = await _getPageCount(
      GetPdfPageCountParams(path: event.path),
    );

    await result.fold(
      onSuccess: (int pageCount) async {
        if (pageCount <= 0) {
          emit(const PdfReaderLoadFailure());
          return;
        }

        final Map<int, List<PdfTextNote>> notesByPage =
            await _loadNotesByPage(event.path);
        emit(
          PdfReaderReady(
            path: event.path,
            pageCount: pageCount,
            notesByPage: notesByPage,
          ),
        );
      },
      onFailure: (failure) async {
        emit(PdfReaderLoadFailure(message: failure.message));
      },
    );
  }

  void _onPageChanged(
    PdfReaderPageChanged event,
    Emitter<PdfReaderState> emit,
  ) {
    final PdfReaderReady? readyState = _readyState;
    if (readyState == null) {
      return;
    }

    emit(
      readyState.copyWith(
        currentPageIndex: _normalizedPageIndex(
          pageIndex: event.pageIndex,
          pageCount: readyState.pageCount,
          spreadMode: readyState.spreadMode,
        ),
      ),
    );
  }

  void _onPreviousPageRequested(
    PdfReaderPreviousPageRequested event,
    Emitter<PdfReaderState> emit,
  ) {
    final PdfReaderReady? readyState = _readyState;
    if (readyState == null || !readyState.canGoPrevious) {
      return;
    }

    emit(
      readyState.copyWith(
        currentPageIndex: math.max(
          0,
          readyState.currentPageIndex - readyState.spreadSize,
        ),
      ),
    );
  }

  void _onNextPageRequested(
    PdfReaderNextPageRequested event,
    Emitter<PdfReaderState> emit,
  ) {
    final PdfReaderReady? readyState = _readyState;
    if (readyState == null || !readyState.canGoNext) {
      return;
    }

    emit(
      readyState.copyWith(
        currentPageIndex: _normalizedPageIndex(
          pageIndex: readyState.currentPageIndex + readyState.spreadSize,
          pageCount: readyState.pageCount,
          spreadMode: readyState.spreadMode,
        ),
      ),
    );
  }

  void _onSpreadModeChanged(
    PdfReaderSpreadModeChanged event,
    Emitter<PdfReaderState> emit,
  ) {
    final PdfReaderReady? readyState = _readyState;
    if (readyState == null || readyState.spreadMode == event.mode) {
      return;
    }

    emit(
      readyState.copyWith(
        spreadMode: event.mode,
        currentPageIndex: _normalizedPageIndex(
          pageIndex: readyState.currentPageIndex,
          pageCount: readyState.pageCount,
          spreadMode: event.mode,
        ),
      ),
    );
  }

  Future<void> _onNoteSaveRequested(
    PdfReaderNoteSaveRequested event,
    Emitter<PdfReaderState> emit,
  ) async {
    final PdfReaderReady? readyState = _readyState;
    final String noteText = event.note.trim();
    if (readyState == null || noteText.isEmpty) {
      return;
    }

    final PdfTextNote note = PdfTextNote(
      id: '${readyState.path}-${event.pageIndex}-'
          '${DateTime.now().microsecondsSinceEpoch}',
      path: readyState.path,
      pageIndex: event.pageIndex,
      selectedText: event.selectedText,
      note: noteText,
      bounds: event.bounds,
      createdAt: DateTime.now(),
      anchor: event.anchor,
    );
    final PdfReaderResult<PdfTextNote> result = await _saveNote(
      SavePdfTextNoteParams(note: note),
    );

    result.fold(
      onSuccess: (PdfTextNote savedNote) {
        emit(
          readyState.copyWith(
            notesByPage: _notesWithAddedNote(
              readyState.notesByPage,
              savedNote,
            ),
          ),
        );
      },
      onFailure: (_) {},
    );
  }

  Future<void> _onNoteDeleteRequested(
    PdfReaderNoteDeleteRequested event,
    Emitter<PdfReaderState> emit,
  ) async {
    final PdfReaderReady? readyState = _readyState;
    if (readyState == null) {
      return;
    }

    final PdfReaderResult<bool> result = await _deleteNote(
      DeletePdfTextNoteParams(note: event.note),
    );

    result.fold(
      onSuccess: (bool deleted) {
        if (!deleted) {
          return;
        }

        emit(
          readyState.copyWith(
            notesByPage: _notesWithoutNote(
              readyState.notesByPage,
              event.note,
            ),
          ),
        );
      },
      onFailure: (_) {},
    );
  }

  PdfReaderReady? get _readyState {
    final PdfReaderState currentState = state;
    return currentState is PdfReaderReady ? currentState : null;
  }

  int _normalizedPageIndex({
    required int pageIndex,
    required int pageCount,
    required PdfReaderSpreadMode spreadMode,
  }) {
    final int clampedIndex = pageIndex.clamp(0, pageCount - 1).toInt();
    if (spreadMode == PdfReaderSpreadMode.twoPages) {
      return clampedIndex.isOdd ? clampedIndex - 1 : clampedIndex;
    }

    return clampedIndex;
  }

  Future<Map<int, List<PdfTextNote>>> _loadNotesByPage(String path) async {
    final PdfReaderResult<List<PdfTextNote>> result = await _loadNotes(
      LoadPdfTextNotesParams(path: path),
    );

    return result.fold(
      onSuccess: _groupNotesByPage,
      onFailure: (_) => const <int, List<PdfTextNote>>{},
    );
  }

  Map<int, List<PdfTextNote>> _groupNotesByPage(List<PdfTextNote> notes) {
    final Map<int, List<PdfTextNote>> notesByPage =
        <int, List<PdfTextNote>>{};
    for (final PdfTextNote note in notes) {
      notesByPage.putIfAbsent(note.pageIndex, () => <PdfTextNote>[]).add(note);
    }

    return notesByPage;
  }

  Map<int, List<PdfTextNote>> _notesWithAddedNote(
    Map<int, List<PdfTextNote>> currentNotesByPage,
    PdfTextNote note,
  ) {
    final Map<int, List<PdfTextNote>> notesByPage =
        Map<int, List<PdfTextNote>>.of(currentNotesByPage);
    final List<PdfTextNote> pageNotes = List<PdfTextNote>.of(
      notesByPage[note.pageIndex] ?? const <PdfTextNote>[],
    );

    pageNotes.add(note);
    notesByPage[note.pageIndex] = pageNotes;
    return notesByPage;
  }

  Map<int, List<PdfTextNote>> _notesWithoutNote(
    Map<int, List<PdfTextNote>> currentNotesByPage,
    PdfTextNote note,
  ) {
    final Map<int, List<PdfTextNote>> notesByPage =
        Map<int, List<PdfTextNote>>.of(currentNotesByPage);
    final List<PdfTextNote> pageNotes = List<PdfTextNote>.of(
      notesByPage[note.pageIndex] ?? const <PdfTextNote>[],
    )..removeWhere((PdfTextNote currentNote) => currentNote.id == note.id);

    if (pageNotes.isEmpty) {
      notesByPage.remove(note.pageIndex);
    } else {
      notesByPage[note.pageIndex] = pageNotes;
    }

    return notesByPage;
  }
}
