import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/entities/pdf_text_note.dart';
import '../../domain/use_cases/get_pdf_text_layer_use_case.dart';
import '../../domain/use_cases/render_pdf_page_use_case.dart';
import '../../domain/use_cases/share_pdf_text_use_case.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../widgets/pdf_note_dialog.dart';
import '../widgets/pdf_reader_header.dart';
import '../widgets/pdf_reader_message_view.dart';
import '../widgets/pdf_reader_controls.dart';
import '../widgets/pdf_reader_spread_view.dart';
import '../widgets/pdf_saved_note_sheet.dart';

class PdfReaderPage extends StatefulWidget {
  const PdfReaderPage({
    required this.path,
    required this.name,
    this.bloc,
    this.renderPage,
    this.getTextLayer,
    this.shareText,
    super.key,
  });

  final String path;
  final String name;
  final PdfReaderBloc? bloc;
  final RenderPdfPageUseCase? renderPage;
  final GetPdfTextLayerUseCase? getTextLayer;
  final SharePdfTextUseCase? shareText;

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
        name: widget.name,
        renderPage: _renderPage,
        getTextLayer: _getTextLayer,
        shareText: _shareText,
      ),
    );
  }
}

class _PdfReaderBody extends StatelessWidget {
  const _PdfReaderBody({
    required this.name,
    required this.renderPage,
    required this.getTextLayer,
    required this.shareText,
  });

  final String name;
  final RenderPdfPageUseCase renderPage;
  final GetPdfTextLayerUseCase getTextLayer;
  final SharePdfTextUseCase shareText;

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
                      fileName: name,
                      currentPage: (readyState?.currentPageIndex ?? 0) + 1,
                      pageCount: readyState?.pageCount,
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
      PdfReaderLoadFailure(message: final message) => PdfReaderMessageView(
          icon: HugeIcons.strokeRoundedCancelCircle,
          message: message ??
              LocalizationConstants.pdfReaderUnsupportedKey.tr(),
        ),
      PdfReaderReady readyState => _readyContent(context, readyState),
    };
  }

  Widget _readyContent(BuildContext context, PdfReaderReady state) {
    final bool isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    if (!isLandscape && state.spreadMode == PdfReaderSpreadMode.twoPages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }

        context.read<PdfReaderBloc>().add(
              const PdfReaderSpreadModeChanged(
                PdfReaderSpreadMode.singlePage,
              ),
            );
      });
    }
    final PdfReaderReady visibleState =
        !isLandscape && state.spreadMode == PdfReaderSpreadMode.twoPages
            ? state.copyWith(spreadMode: PdfReaderSpreadMode.singlePage)
            : state;

    return Column(
      children: <Widget>[
        Expanded(
          child: PdfReaderSpreadView(
            state: visibleState,
            renderPage: renderPage,
            getTextLayer: getTextLayer,
            shareText: shareText,
            onPrevious: () {
              context.read<PdfReaderBloc>().add(
                    const PdfReaderPreviousPageRequested(),
                  );
            },
            onNext: () {
              context.read<PdfReaderBloc>().add(
                    const PdfReaderNextPageRequested(),
                  );
            },
            onNoteRequested: ({
              required PdfPageAnchor? anchor,
              required List<PdfTextBounds> bounds,
              required int pageIndex,
              required String selectedText,
            }) {
              _showNoteDialog(
                context,
                anchor: anchor,
                pageIndex: pageIndex,
                selectedText: selectedText,
                bounds: bounds,
              );
            },
            onSavedNotePressed: (PdfTextNote note) {
              _showSavedNoteSheet(context, note);
            },
            onMessage: (String message) => _showMessage(context, message),
          ),
        ),
        PdfReaderControls(
          state: visibleState,
          isLandscape: isLandscape,
          onPrevious: () {
            context.read<PdfReaderBloc>().add(
                  const PdfReaderPreviousPageRequested(),
                );
          },
          onNext: () {
            context.read<PdfReaderBloc>().add(
                  const PdfReaderNextPageRequested(),
                );
          },
          onSpreadModeChanged: (PdfReaderSpreadMode mode) {
            context.read<PdfReaderBloc>().add(
                  PdfReaderSpreadModeChanged(mode),
                );
          },
        ),
      ],
    );
  }

  Future<void> _showNoteDialog(
    BuildContext context, {
    required PdfPageAnchor? anchor,
    required int pageIndex,
    required String selectedText,
    required List<PdfTextBounds> bounds,
  }) async {
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

    context.read<PdfReaderBloc>().add(
          PdfReaderNoteSaveRequested(
            pageIndex: pageIndex,
            selectedText: selectedText,
            note: note,
            bounds: bounds,
            anchor: anchor,
          ),
        );
    _showMessage(context, LocalizationConstants.pdfReaderNoteSavedKey.tr());
  }

  Future<void> _showSavedNoteSheet(
    BuildContext context,
    PdfTextNote note,
  ) async {
    final PdfTextNote? deletedNote = await showModalBottomSheet<PdfTextNote>(
      context: context,
      backgroundColor: context.appCard,
      barrierColor: const Color(0x55000000),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return PdfSavedNoteSheet(note: note);
      },
    );

    if (!context.mounted || deletedNote == null) {
      return;
    }

    context.read<PdfReaderBloc>().add(
          PdfReaderNoteDeleteRequested(deletedNote),
        );
    _showMessage(context, LocalizationConstants.pdfReaderNoteDeletedKey.tr());
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
