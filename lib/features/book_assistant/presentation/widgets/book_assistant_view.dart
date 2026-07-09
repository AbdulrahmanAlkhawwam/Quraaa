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
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness: overlayBrightness,
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1),
        ),
        child: Scaffold(
          backgroundColor: background,
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
                          AssistantHeader(scale: scale),
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
      padding: EdgeInsets.only(top: 44 * scale, bottom: 16 * scale),
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: AssistantSparkle(scale: scale * 0.72),
        ),
        SizedBox(height: 18 * scale),
        if (state.isAnswering)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary600),
          )
        else if (state.response != null)
          AssistantAnswerCard(response: state.response!, scale: scale),
        SizedBox(height: 18 * scale),
        AssistantPromptChips(
          scale: scale,
          onPromptSelected: onPromptSelected,
        ),
      ],
    );
  }
}
