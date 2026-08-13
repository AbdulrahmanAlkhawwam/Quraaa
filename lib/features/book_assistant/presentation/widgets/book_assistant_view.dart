import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/assistant_book.dart';
import '../bloc/book_assistant_bloc.dart';
import 'assistant_answer_card.dart';
import 'assistant_book_picker_sheet.dart';
import 'assistant_composer.dart';
import 'assistant_header.dart';
import 'assistant_prompt_chips.dart';
import 'assistant_selected_books.dart';
import 'assistant_sparkle.dart';

class BookAssistantView extends StatefulWidget {
  const BookAssistantView({super.key});

  @override
  State<BookAssistantView> createState() => _BookAssistantViewState();
}

class _BookAssistantViewState extends State<BookAssistantView> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color background = context.appBackground;
    final Brightness overlayBrightness =
        context.isDark ? Brightness.light : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: overlayBrightness,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: overlayBrightness,
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: background,
          endDrawer: const _AssistantHistoryDrawer(),
          body: BlocBuilder<BookAssistantBloc, BookAssistantState>(
            builder: (BuildContext context, BookAssistantState state) {
              if (state is BookAssistantLoading ||
                  state is BookAssistantInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary600),
                );
              }

              if (state is BookAssistantFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error500,
                      ),
                    ),
                  ),
                );
              }

              if (state is! BookAssistantLoaded) {
                return const SizedBox.shrink();
              }

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double scale = constraints.compactFeatureScale;
                  final double horizontal =
                      (constraints.maxWidth * 0.058).clamp(22.0, 28.0);
                  final double topPadding =
                      (constraints.maxHeight * 0.04).clamp(20.0, 34.0);

                  return SafeArea(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        horizontal,
                        topPadding,
                        horizontal,
                        10 * scale,
                      ),
                      child: Column(
                        children: <Widget>[
                          AssistantHeader(
                            scale: scale,
                            onMenuPressed: () =>
                                _scaffoldKey.currentState?.openEndDrawer(),
                          ),
                          Expanded(
                            child: _AssistantMainContent(
                              state: state,
                              scale: scale,
                              onPromptSelected: (String prompt) {
                                context.read<BookAssistantBloc>().add(
                                      BookAssistantPromptSelected(prompt),
                                    );
                              },
                            ),
                          ),
                          AssistantSelectedBooks(
                            books: state.selectedBooks,
                            scale: scale,
                          ),
                          if (state.selectedBooks.isNotEmpty)
                            SizedBox(height: 8 * scale),
                          AssistantComposer(
                            controller: _controller,
                            scale: scale,
                            onSubmit: _submitQuestion,
                            onPickBooks: () => _showBookPicker(state),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _submitQuestion(String value) {
    context.read<BookAssistantBloc>().add(
          BookAssistantQuestionSubmitted(value),
        );
    _controller.clear();
  }

  void _showBookPicker(BookAssistantLoaded state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appCard,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return BlocProvider<BookAssistantBloc>.value(
          value: context.read<BookAssistantBloc>(),
          child: BlocBuilder<BookAssistantBloc, BookAssistantState>(
            builder: (BuildContext context, BookAssistantState sheetState) {
              final BookAssistantLoaded current =
                  sheetState is BookAssistantLoaded ? sheetState : state;

              return AssistantBookPickerSheet(
                books: current.books,
                selectedBooks: current.selectedBooks,
                onBookToggled: (AssistantBook book) {
                  context.read<BookAssistantBloc>().add(
                        BookAssistantBookToggled(book),
                      );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _AssistantMainContent extends StatelessWidget {
  const _AssistantMainContent({
    required this.state,
    required this.scale,
    required this.onPromptSelected,
  });

  final BookAssistantLoaded state;
  final double scale;
  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: state.response == null && !state.isAnswering
          ? _AssistantEmptyContent(
              scale: scale,
              onPromptSelected: onPromptSelected,
            )
          : _AssistantAnswerContent(
              state: state,
              scale: scale,
              onPromptSelected: onPromptSelected,
            ),
    );
  }
}

class _AssistantEmptyContent extends StatelessWidget {
  const _AssistantEmptyContent({
    required this.scale,
    required this.onPromptSelected,
  });

  final double scale;
  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: Offset(0, 28 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AssistantSparkle(scale: scale),
            SizedBox(height: 22 * scale),
            AssistantPromptChips(
              scale: scale,
              onPromptSelected: onPromptSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantAnswerContent extends StatelessWidget {
  const _AssistantAnswerContent({
    required this.state,
    required this.scale,
    required this.onPromptSelected,
  });

  final BookAssistantLoaded state;
  final double scale;
  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 18 * scale, bottom: 16 * scale),
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        _UserMessageBubble(
          question: state.pendingQuestion ?? state.response?.question ?? '',
          scale: scale,
        ),
        SizedBox(height: 20 * scale),
        if (state.isAnswering)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              width: 32 * scale,
              height: 32 * scale,
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary600,
              ),
            ),
          )
        else if (state.response != null)
          AssistantAnswerCard(response: state.response!, scale: scale),
        SizedBox(height: 12 * scale),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Icon(
            Icons.auto_awesome_outlined,
            size: 25 * scale,
            color: AppColors.primary600,
          ),
        ),
      ],
    );
  }
}

class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({required this.question, required this.scale});

  final String question;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  question,
                  textAlign: TextAlign.end,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary900,
                    fontSize: 14 * scale,
                  ),
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                '4:56 PM',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary600,
                  fontSize: 10 * scale,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8 * scale),
        Container(
          width: 32 * scale,
          height: 32 * scale,
          decoration: const BoxDecoration(
            color: AppColors.primary50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline,
            color: AppColors.primary900,
            size: 20 * scale,
          ),
        ),
      ],
    );
  }
}

class _AssistantHistoryDrawer extends StatelessWidget {
  const _AssistantHistoryDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 289,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('History', style: AppTextStyles.h3.copyWith(color: AppColors.primary900, fontSize: 22, fontWeight: FontWeight.w400)),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _HistoryAction(icon: Icons.menu_book_outlined, label: 'Convert\nbook'),
                  _HistoryAction(icon: Icons.search_outlined, label: 'Search\nbook'),
                  _HistoryAction(icon: Icons.account_tree_outlined, label: 'Learn\nflow'),
                  _HistoryAction(icon: Icons.translate_outlined, label: 'Translate\ntext'),
                ],
              ),
              const SizedBox(height: 32),
              const _HistorySection(label: 'Today', items: <String>[
                'English Learning book',
                'Summarize Home Notes Book',
                'Translate Global English Cour...',
              ]),
              const SizedBox(height: 16),
              const _HistorySection(label: 'Yesterday', items: <String>['Review Ahmed Khaled writer']),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryAction extends StatelessWidget {
  const _HistoryAction({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppColors.primary50, shape: BoxShape.circle), child: Icon(icon, size: 24, color: AppColors.primary900)),
        const SizedBox(height: 10),
        Text(label, textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.primary900, fontSize: 12)),
      ]);
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.label, required this.items});
  final String label;
  final List<String> items;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.primary700, fontSize: 12)),
          const SizedBox(height: 8),
          ...items.map((String item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(item, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary900, fontSize: 16)))),
        ],
      );
}
