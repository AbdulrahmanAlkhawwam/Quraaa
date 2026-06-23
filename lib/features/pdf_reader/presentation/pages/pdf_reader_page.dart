import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/use_cases/get_pdf_text_layer_use_case.dart';
import '../../domain/use_cases/render_pdf_page_use_case.dart';
import '../../domain/use_cases/share_pdf_text_use_case.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../widgets/pdf_page_list.dart';
import '../widgets/pdf_reader_header.dart';
import '../widgets/pdf_reader_message_view.dart';
import '../widgets/pdf_scroll_to_top_button.dart';

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
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_handleScroll);

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
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
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
        controller: _scrollController,
        renderPage: _renderPage,
        getTextLayer: _getTextLayer,
        shareText: _shareText,
        onScrollToTop: _scrollToTop,
      ),
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    _bloc.add(PdfReaderScrolled(_scrollController.offset));
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }
}

class _PdfReaderBody extends StatelessWidget {
  const _PdfReaderBody({
    required this.path,
    required this.name,
    required this.controller,
    required this.renderPage,
    required this.getTextLayer,
    required this.shareText,
    required this.onScrollToTop,
  });

  final String path;
  final String name;
  final ScrollController controller;
  final RenderPdfPageUseCase renderPage;
  final GetPdfTextLayerUseCase getTextLayer;
  final SharePdfTextUseCase shareText;
  final VoidCallback onScrollToTop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
    return Stack(
      children: <Widget>[
        PdfPageList(
          controller: controller,
          renderPage: renderPage,
          getTextLayer: getTextLayer,
          shareText: shareText,
          path: path,
          pageCount: state.pageCount,
          highlightsByPage: state.highlightsByPage,
          onHighlightAdded: (int pageIndex, PdfTextHighlight highlight) {
            context.read<PdfReaderBloc>().add(
                  PdfReaderHighlightAdded(
                    pageIndex: pageIndex,
                    highlight: highlight,
                  ),
                );
          },
          onMessage: (String message) => _showMessage(context, message),
          onPageChanged: (int pageIndex) {
            context.read<PdfReaderBloc>().add(
                  PdfReaderPageChanged(pageIndex),
                );
          },
        ),
        if (state.showScrollToTopButton)
          PositionedDirectional(
            end: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: PdfScrollToTopButton(onPressed: onScrollToTop),
          ),
      ],
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
