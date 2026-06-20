import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../data/datasources/local/pdf_render_datasource.dart';
import '../widgets/pdf_page_list.dart';
import '../widgets/pdf_reader_header.dart';
import '../widgets/pdf_reader_message_view.dart';
import '../widgets/pdf_scroll_to_top_button.dart';

class PdfReaderPage extends StatefulWidget {
  const PdfReaderPage({
    required this.path,
    required this.name,
    super.key,
  });

  final String path;
  final String name;

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  static const double _scrollTopThreshold = 360;

  late final PdfRenderDataSource _renderer = sl<PdfRenderDataSource>();
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_handleScroll);
  late Future<int> _pageCountFuture;
  final Map<int, List<PdfTextHighlight>> _highlightsByPage =
      <int, List<PdfTextHighlight>>{};

  int _currentPageIndex = 0;
  int? _pageCount;
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _pageCountFuture = _renderer.pageCount(widget.path);
  }

  @override
  void didUpdateWidget(covariant PdfReaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _pageCountFuture = _renderer.pageCount(widget.path);
      _highlightsByPage.clear();
      _currentPageIndex = 0;
      _pageCount = null;
      _showScrollToTopButton = false;

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

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
            child: Column(
              children: <Widget>[
                PdfReaderHeader(
                  fileName: widget.name,
                  currentPage: _currentPageIndex + 1,
                  pageCount: _pageCount,
                ),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _pageCountFuture,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return PdfReaderMessageView(
                          icon: HugeIcons.strokeRoundedPdf02,
                          message:
                              LocalizationConstants.pdfReaderLoadingKey.tr(),
                        );
                      }

                      if (snapshot.hasError || (snapshot.data ?? 0) <= 0) {
                        return PdfReaderMessageView(
                          icon: HugeIcons.strokeRoundedCancelCircle,
                          message:
                              LocalizationConstants.pdfReaderUnsupportedKey.tr(),
                        );
                      }

                      final int pageCount = snapshot.data!;
                      _schedulePageCountUpdate(pageCount);

                      return Stack(
                        children: <Widget>[
                          PdfPageList(
                            controller: _scrollController,
                            renderer: _renderer,
                            path: widget.path,
                            pageCount: pageCount,
                            highlightsByPage: _highlightsByPage,
                            onHighlightAdded: _addHighlight,
                            onMessage: _showMessage,
                            onPageChanged: _setCurrentPage,
                          ),
                          if (_showScrollToTopButton)
                            PositionedDirectional(
                              end: AppSpacing.lg,
                              bottom: AppSpacing.lg,
                              child: PdfScrollToTopButton(
                                onPressed: _scrollToTop,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addHighlight(int pageIndex, PdfTextHighlight highlight) {
    setState(() {
      final List<PdfTextHighlight> highlights = List<PdfTextHighlight>.of(
        _highlightsByPage[pageIndex] ?? const <PdfTextHighlight>[],
      );
      highlights.add(highlight);
      _highlightsByPage[pageIndex] = highlights;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _setCurrentPage(int pageIndex) {
    if (_currentPageIndex == pageIndex) {
      return;
    }

    setState(() {
      _currentPageIndex = pageIndex;
    });
  }

  void _handleScroll() {
    final bool shouldShow =
        _scrollController.hasClients &&
        _scrollController.offset > _scrollTopThreshold;

    if (_showScrollToTopButton == shouldShow) {
      return;
    }

    setState(() {
      _showScrollToTopButton = shouldShow;
    });
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

  void _schedulePageCountUpdate(int pageCount) {
    if (_pageCount == pageCount) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _pageCount = pageCount;
        if (_currentPageIndex >= pageCount) {
          _currentPageIndex = pageCount - 1;
        }
      });
    });
  }
}
