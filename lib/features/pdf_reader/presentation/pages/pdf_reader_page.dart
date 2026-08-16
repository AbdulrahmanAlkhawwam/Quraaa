import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../book_assistant/domain/repositories/book_assistant_repository.dart';
import '../../data/datasources/local/pdf_reader_local_state_datasource.dart';
import '../../domain/entities/pdf_reader_local_state.dart';
import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/entities/pdf_text_note.dart';
import '../../domain/use_cases/get_pdf_text_layer_use_case.dart';
import '../../domain/use_cases/render_pdf_page_use_case.dart';
import '../../domain/use_cases/share_pdf_text_use_case.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../widgets/pdf_note_dialog.dart';
import '../widgets/pdf_reader_continuous_view.dart';
import '../widgets/pdf_reader_header.dart';
import '../widgets/pdf_reader_layout_sheet.dart';
import '../widgets/pdf_reader_message_view.dart';
import '../widgets/pdf_reader_progress_sheet.dart';
import '../widgets/pdf_saved_note_sheet.dart';

class PdfReaderPage extends StatefulWidget {
  const PdfReaderPage({
    required this.path,
    required this.name,
    this.purchaseId = '',
    this.bloc,
    this.renderPage,
    this.getTextLayer,
    this.shareText,
    this.localStateDataSource,
    super.key,
  });

  final String path;
  final String name;
  final String purchaseId;
  final PdfReaderBloc? bloc;
  final RenderPdfPageUseCase? renderPage;
  final GetPdfTextLayerUseCase? getTextLayer;
  final SharePdfTextUseCase? shareText;
  final PdfReaderLocalStateDataSource? localStateDataSource;

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  late final PdfReaderBloc _bloc = widget.bloc ?? sl<PdfReaderBloc>();
  late final bool _ownsBloc = widget.bloc == null;
  late final RenderPdfPageUseCase _renderPage =
      widget.renderPage ?? sl<RenderPdfPageUseCase>();
  late final GetPdfTextLayerUseCase _getTextLayer =
      widget.getTextLayer ?? sl<GetPdfTextLayerUseCase>();
  late final SharePdfTextUseCase _shareText =
      widget.shareText ?? sl<SharePdfTextUseCase>();
  late final PdfReaderLocalStateDataSource _localStateDataSource =
      widget.localStateDataSource ?? sl<PdfReaderLocalStateDataSource>();

  @override
  void initState() {
    super.initState();
    _bloc.add(PdfReaderStarted(widget.path));
  }

  @override
  void didUpdateWidget(covariant PdfReaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path == widget.path) {
      return;
    }
    _bloc.add(PdfReaderStarted(widget.path));
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PdfReaderBloc>.value(
      value: _bloc,
      child: _PdfReaderBody(
        path: widget.path,
        name: widget.name,
        purchaseId: widget.purchaseId,
        renderPage: _renderPage,
        getTextLayer: _getTextLayer,
        shareText: _shareText,
        localStateDataSource: _localStateDataSource,
      ),
    );
  }
}

class _PdfReaderBody extends StatefulWidget {
  const _PdfReaderBody({
    required this.path,
    required this.name,
    required this.purchaseId,
    required this.renderPage,
    required this.getTextLayer,
    required this.shareText,
    required this.localStateDataSource,
  });

  final String path;
  final String name;
  final String purchaseId;
  final RenderPdfPageUseCase renderPage;
  final GetPdfTextLayerUseCase getTextLayer;
  final SharePdfTextUseCase shareText;
  final PdfReaderLocalStateDataSource localStateDataSource;

  @override
  State<_PdfReaderBody> createState() => _PdfReaderBodyState();
}

class _PdfReaderBodyState extends State<_PdfReaderBody> {
  static const List<int> _highlighterColors = <int>[
    0xFFF5C242,
    0xFFF08C86,
    0xFF74C14C,
    0xFF69B7E8,
    0xFFB58CE6,
  ];

  static const List<int> _penColors = <int>[
    0xFF243B53,
    0xFF2563EB,
    0xFFDC2626,
    0xFF15803D,
    0xFF7E22CE,
  ];

  PdfReaderLocalState _localState = const PdfReaderLocalState();
  List<PdfInkStroke> _editingStrokes = <PdfInkStroke>[];
  List<PdfInkStroke> _redoStrokes = <PdfInkStroke>[];
  bool _annotationMode = false;
  bool _translating = false;
  PdfInkTool _inkTool = PdfInkTool.highlighter;
  int _highlighterColorValue = _highlighterColors.first;
  int _penColorValue = _penColors.first;
  int _readerRevision = 0;
  String _fileSizeLabel = '—';

  List<int> get _activeInkColors =>
      _inkTool == PdfInkTool.highlighter ? _highlighterColors : _penColors;

  int get _inkColorValue => _inkTool == PdfInkTool.highlighter
      ? _highlighterColorValue
      : _penColorValue;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocalState());
    unawaited(_loadFileSize());
  }

  @override
  void didUpdateWidget(covariant _PdfReaderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path == widget.path) {
      return;
    }
    _localState = const PdfReaderLocalState();
    _editingStrokes = <PdfInkStroke>[];
    _redoStrokes = <PdfInkStroke>[];
    _annotationMode = false;
    _inkTool = PdfInkTool.highlighter;
    _readerRevision++;
    unawaited(_loadLocalState());
    unawaited(_loadFileSize());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.pageMaxWidth,
            ),
            child: BlocBuilder<PdfReaderBloc, PdfReaderState>(
              builder: (BuildContext context, PdfReaderState state) {
                final PdfReaderReady? readyState =
                    state is PdfReaderReady ? state : null;

                return Column(
                  children: <Widget>[
                    PdfReaderHeader(
                      annotationMode: _annotationMode,
                      inkTool: _inkTool,
                      inkColor: Color(_inkColorValue),
                      canUndo: _annotationMode && _editingStrokes.isNotEmpty,
                      canRedo: _annotationMode && _redoStrokes.isNotEmpty,
                      onBack: _onBack,
                      onInfo: readyState == null
                          ? () {}
                          : () => _showProgress(readyState),
                      // Temporarily hidden until the translation flow is re-enabled.
                      translateAvailable: false,
                      onTranslate: readyState == null || _translating
                          ? null
                          : () => _translateCurrentPage(readyState),
                      onHighlight: () =>
                          _enterAnnotationMode(PdfInkTool.highlighter),
                      onAddNote: readyState == null
                          ? () {}
                          : () => _addPageNote(readyState),
                      onLayout:
                          readyState == null ? () {} : _showLayoutSettings,
                      onEdit: () => _enterAnnotationMode(PdfInkTool.pen),
                      onUndo: _undoInk,
                      onRedo: _redoInk,
                      onChooseColor: _showColorPicker,
                      onSave: _saveAnnotations,
                    ),
                    Expanded(child: _content(context, state)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, PdfReaderState state) {
    return switch (state) {
      PdfReaderInitial() || PdfReaderLoading() => PdfReaderMessageView(
          icon: HugeIcons.strokeRoundedPdf02,
          message: LocalizationConstants.pdfReaderLoadingKey.tr(),
        ),
      PdfReaderLoadFailure(message: final String? message) =>
        PdfReaderMessageView(
          icon: HugeIcons.strokeRoundedCancelCircle,
          message:
              message ?? LocalizationConstants.pdfReaderUnsupportedKey.tr(),
        ),
      PdfReaderReady readyState => _readyContent(context, readyState),
    };
  }

  Widget _readyContent(BuildContext context, PdfReaderReady state) {
    final int currentPageIndex =
        _localState.currentPageIndex.clamp(0, state.pageCount - 1).toInt();
    final PdfReaderReady visibleState = state.copyWith(
      currentPageIndex: currentPageIndex,
      spreadMode: PdfReaderSpreadMode.singlePage,
    );

    return PdfReaderContinuousView(
      key: ValueKey<String>(
        widget.path +
            ':' +
            _localState.scrollDirection.name +
            ':' +
            _readerRevision.toString(),
      ),
      state: visibleState,
      scrollDirection: _localState.scrollDirection,
      inkStrokes: _annotationMode ? _editingStrokes : _localState.inkStrokes,
      inkMode: _annotationMode,
      inkColorValue: _inkColorValue,
      inkTool: _inkTool,
      renderPage: widget.renderPage,
      getTextLayer: widget.getTextLayer,
      shareText: widget.shareText,
      onPageChanged: _onPageChanged,
      onInkStrokeCompleted: _addInkStroke,
      onNoteRequested: ({
        required PdfPageAnchor? anchor,
        required List<PdfTextBounds> bounds,
        required int pageIndex,
        required String selectedText,
      }) {
        _showNoteDialog(
          anchor: anchor,
          pageIndex: pageIndex,
          selectedText: selectedText,
          bounds: bounds,
        );
      },
      onSavedNotePressed: (PdfTextNote note) {
        _showSavedNoteSheet(note);
      },
      onMessage: _showMessage,
    );
  }

  Future<void> _loadLocalState() async {
    PdfReaderLocalState loaded =
        await widget.localStateDataSource.loadState(widget.path);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final Map<String, DateTime> days = <String, DateTime>{
      for (final DateTime day in loaded.readingDays)
        _dayKey(day): DateTime(day.year, day.month, day.day),
      _dayKey(today): today,
    };
    loaded = loaded.copyWith(
      readingDays: days.values.toList(growable: false),
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _localState = loaded;
      _readerRevision++;
    });
    _persistLocalState();
  }

  Future<void> _loadFileSize() async {
    try {
      final int bytes = await File(widget.path).length();
      if (!mounted) {
        return;
      }
      setState(() {
        _fileSizeLabel = _formatFileSize(bytes);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _fileSizeLabel = '—';
        });
      }
    }
  }

  void _onPageChanged(int pageIndex) {
    if (pageIndex == _localState.currentPageIndex) {
      return;
    }
    setState(() {
      _localState = _localState.copyWith(currentPageIndex: pageIndex);
    });
    context.read<PdfReaderBloc>().add(PdfReaderPageChanged(pageIndex));
    _persistLocalState();
  }

  void _enterAnnotationMode(PdfInkTool tool) {
    if (_annotationMode && _inkTool == tool) {
      return;
    }
    setState(() {
      _inkTool = tool;
      if (!_annotationMode) {
        _annotationMode = true;
        _editingStrokes = List<PdfInkStroke>.of(_localState.inkStrokes);
        _redoStrokes = <PdfInkStroke>[];
      }
    });
  }

  void _addInkStroke(PdfInkStroke stroke) {
    if (!_annotationMode) {
      return;
    }
    setState(() {
      _editingStrokes = <PdfInkStroke>[..._editingStrokes, stroke];
      _redoStrokes = <PdfInkStroke>[];
    });
  }

  void _undoInk() {
    if (!_annotationMode || _editingStrokes.isEmpty) {
      return;
    }
    final PdfInkStroke removed = _editingStrokes.last;
    setState(() {
      _editingStrokes = _editingStrokes.sublist(
        0,
        _editingStrokes.length - 1,
      );
      _redoStrokes = <PdfInkStroke>[..._redoStrokes, removed];
    });
  }

  void _redoInk() {
    if (!_annotationMode || _redoStrokes.isEmpty) {
      return;
    }
    final PdfInkStroke restored = _redoStrokes.last;
    setState(() {
      _editingStrokes = <PdfInkStroke>[..._editingStrokes, restored];
      _redoStrokes = _redoStrokes.sublist(0, _redoStrokes.length - 1);
    });
  }

  void _saveAnnotations() {
    if (!_annotationMode) {
      return;
    }
    setState(() {
      _localState = _localState.copyWith(
        inkStrokes: List<PdfInkStroke>.unmodifiable(_editingStrokes),
      );
      _annotationMode = false;
      _redoStrokes = <PdfInkStroke>[];
    });
    _persistLocalState();
    _showMessage(
      LocalizationConstants.pdfReaderAnnotationsSavedKey.tr(),
    );
  }

  void _cancelAnnotations() {
    setState(() {
      _annotationMode = false;
      _editingStrokes = <PdfInkStroke>[];
      _redoStrokes = <PdfInkStroke>[];
    });
  }

  void _onBack() {
    if (_annotationMode) {
      _cancelAnnotations();
      return;
    }
    context.back();
  }

  Future<void> _showColorPicker() async {
    final int? selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: context.appCard,
      barrierColor: const Color(0x55000000),
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _activeInkColors
                  .map(
                    (int colorValue) => InkWell(
                      onTap: () => Navigator.of(sheetContext).pop(colorValue),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Color(colorValue),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorValue == _inkColorValue
                                ? AppColors.secondary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        );
      },
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      if (_inkTool == PdfInkTool.highlighter) {
        _highlighterColorValue = selected;
      } else {
        _penColorValue = selected;
      }
    });
  }

  Future<void> _translateCurrentPage(PdfReaderReady state) async {
    if (_translating || widget.purchaseId.trim().isEmpty) return;
    setState(() => _translating = true);
    final Result<String> result = await sl<BookAssistantRepository>().translate(
      purchaseId: widget.purchaseId.trim(),
      pageNumber:
          _localState.currentPageIndex.clamp(0, state.pageCount - 1) + 1,
      targetLanguage:
          context.locale.languageCode == 'ar' ? 'Arabic' : 'English',
    );
    if (!mounted) return;
    setState(() => _translating = false);
    result.fold(
      (failure) => _showMessage(failure.message),
      (translation) => _showTranslation(translation),
    );
  }

  Future<void> _showTranslation(String translation) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.appCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            8,
            24,
            24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.translate, color: AppColors.primary600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      LocalizationConstants.pdfReaderTranslationKey.tr(),
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.62,
                ),
                child: SingleChildScrollView(
                  child: SelectableText(translation),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showProgress(PdfReaderReady state) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appCard,
      barrierColor: const Color(0x55000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) => PdfReaderProgressSheet(
        fileName: widget.name,
        fileSizeLabel: _fileSizeLabel,
        currentPage: _localState.currentPageIndex + 1,
        pageCount: state.pageCount,
        readingDays: _localState.readingDays,
      ),
    );
  }

  Future<void> _showLayoutSettings() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appCard,
      barrierColor: const Color(0x55000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) => PdfReaderLayoutSheet(
        initialDirection: _localState.scrollDirection,
        onDirectionChanged: _changeScrollDirection,
        onReset: () => _changeScrollDirection(
          PdfReaderScrollDirection.vertical,
        ),
      ),
    );
  }

  void _changeScrollDirection(PdfReaderScrollDirection direction) {
    if (_localState.scrollDirection == direction) {
      return;
    }
    setState(() {
      _localState = _localState.copyWith(scrollDirection: direction);
      _readerRevision++;
    });
    _persistLocalState();
  }

  void _addPageNote(PdfReaderReady state) {
    final int pageIndex =
        _localState.currentPageIndex.clamp(0, state.pageCount - 1).toInt();
    _showNoteDialog(
      anchor: const PdfPageAnchor(xRatio: 0.5, yRatio: 0.5),
      pageIndex: pageIndex,
      selectedText: '',
      bounds: const <PdfTextBounds>[],
    );
  }

  Future<void> _showNoteDialog({
    required PdfPageAnchor? anchor,
    required int pageIndex,
    required String selectedText,
    required List<PdfTextBounds> bounds,
  }) async {
    final PdfReaderBloc bloc = context.read<PdfReaderBloc>();
    final String? note = await showDialog<String>(
      context: context,
      barrierColor: const Color(0x55000000),
      builder: (BuildContext dialogContext) {
        return PdfNoteDialog(selectedText: selectedText);
      },
    );

    if (!context.mounted || note == null || note.trim().isEmpty) {
      return;
    }

    bloc.add(
      PdfReaderNoteSaveRequested(
        pageIndex: pageIndex,
        selectedText: selectedText,
        note: note,
        bounds: bounds,
        anchor: anchor,
      ),
    );
    _showMessage(LocalizationConstants.pdfReaderNoteSavedKey.tr());
  }

  Future<void> _showSavedNoteSheet(PdfTextNote note) async {
    final PdfReaderBloc bloc = context.read<PdfReaderBloc>();
    final PdfTextNote? deletedNote = await showModalBottomSheet<PdfTextNote>(
      context: context,
      backgroundColor: context.appCard,
      barrierColor: const Color(0x55000000),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return PdfSavedNoteSheet(note: note);
      },
    );

    if (!context.mounted || deletedNote == null) {
      return;
    }

    bloc.add(PdfReaderNoteDeleteRequested(deletedNote));
    _showMessage(LocalizationConstants.pdfReaderNoteDeletedKey.tr());
  }

  void _persistLocalState() {
    unawaited(_persistLocalStateSafely());
  }

  Future<void> _persistLocalStateSafely() async {
    try {
      await widget.localStateDataSource.saveState(widget.path, _localState);
    } catch (_) {
      // Reading remains available even if local progress cannot be persisted.
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _dayKey(DateTime date) {
    final DateTime local = date.toLocal();
    return local.year.toString() +
        '-' +
        local.month.toString() +
        '-' +
        local.day.toString();
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return (bytes / (1024 * 1024)).toStringAsFixed(1) + ' MB';
    }
    if (bytes >= 1024) {
      return (bytes / 1024).toStringAsFixed(1) + ' KB';
    }
    return bytes.toString() + ' B';
  }
}
