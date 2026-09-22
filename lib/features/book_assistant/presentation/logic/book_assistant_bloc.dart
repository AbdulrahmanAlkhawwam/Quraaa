import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/assistant_book.dart';
import '../../domain/entities/assistant_response.dart';
import '../../domain/use_cases/ask_book_assistant_use_case.dart';
import '../../domain/use_cases/get_assistant_books_use_case.dart';
import '../../domain/use_cases/summarize_purchase_use_case.dart';
import '../models/book_assistant_navigation_data.dart';

sealed class BookAssistantEvent {
  const BookAssistantEvent();
}

final class BookAssistantStarted extends BookAssistantEvent {
  const BookAssistantStarted([this.initialRequest]);

  final BookAssistantNavigationData? initialRequest;
}

final class BookAssistantPromptSelected extends BookAssistantEvent {
  const BookAssistantPromptSelected(this.prompt);

  final String prompt;
}

final class BookAssistantQuestionSubmitted extends BookAssistantEvent {
  const BookAssistantQuestionSubmitted(this.question);

  final String question;
}

final class BookAssistantBookToggled extends BookAssistantEvent {
  const BookAssistantBookToggled(this.book);

  final AssistantBook book;
}

sealed class BookAssistantState {
  const BookAssistantState();
}

final class BookAssistantInitial extends BookAssistantState {
  const BookAssistantInitial();
}

final class BookAssistantLoading extends BookAssistantState {
  const BookAssistantLoading();
}

final class BookAssistantLoaded extends BookAssistantState {
  const BookAssistantLoaded({
    required this.books,
    this.selectedBooks = const <AssistantBook>[],
    this.response,
    this.pendingQuestion,
    this.isAnswering = false,
    this.errorMessage,
  });

  final List<AssistantBook> books;
  final List<AssistantBook> selectedBooks;
  final AssistantResponse? response;
  final String? pendingQuestion;
  final bool isAnswering;
  final String? errorMessage;

  BookAssistantLoaded copyWith({
    List<AssistantBook>? books,
    List<AssistantBook>? selectedBooks,
    AssistantResponse? response,
    bool clearResponse = false,
    String? pendingQuestion,
    bool clearPendingQuestion = false,
    bool? isAnswering,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookAssistantLoaded(
      books: books ?? this.books,
      selectedBooks: selectedBooks ?? this.selectedBooks,
      response: clearResponse ? null : response ?? this.response,
      pendingQuestion:
          clearPendingQuestion ? null : pendingQuestion ?? this.pendingQuestion,
      isAnswering: isAnswering ?? this.isAnswering,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final class BookAssistantFailure extends BookAssistantState {
  const BookAssistantFailure(this.message);

  final String message;
}

class BookAssistantBloc extends Bloc<BookAssistantEvent, BookAssistantState> {
  BookAssistantBloc({
    required GetAssistantBooksUseCase getBooks,
    required AskBookAssistantUseCase askAssistant,
    required SummarizePurchaseUseCase summarizePurchase,
  })  : _getBooks = getBooks,
        _askAssistant = askAssistant,
        _summarizePurchase = summarizePurchase,
        super(const BookAssistantInitial()) {
    on<BookAssistantStarted>(_onStarted);
    on<BookAssistantPromptSelected>(_onPromptSelected);
    on<BookAssistantQuestionSubmitted>(_onQuestionSubmitted);
    on<BookAssistantBookToggled>(_onBookToggled);
  }

  final GetAssistantBooksUseCase _getBooks;
  final AskBookAssistantUseCase _askAssistant;
  final SummarizePurchaseUseCase _summarizePurchase;

  Future<void> _onStarted(
    BookAssistantStarted event,
    Emitter<BookAssistantState> emit,
  ) async {
    emit(const BookAssistantLoading());
    switch (await _getBooks(const NoParams())) {
      case Success<List<AssistantBook>>(value: final List<AssistantBook> books):
        final BookAssistantNavigationData? request = event.initialRequest;
        if (request == null) {
          emit(BookAssistantLoaded(books: books));
          return;
        }

        final List<AssistantBook> availableBooks = books.any(
          (AssistantBook book) => book.id == request.book.id,
        )
            ? books
            : <AssistantBook>[request.book, ...books];
        final BookAssistantLoaded initialConversation = BookAssistantLoaded(
          books: availableBooks,
          selectedBooks: <AssistantBook>[request.book],
          pendingQuestion: request.question,
          isAnswering: true,
        );
        emit(initialConversation);
        await _summarizeInitialRequest(request, initialConversation, emit);
      case ResultFailure<List<AssistantBook>>(message: final String message):
        emit(BookAssistantFailure(message));
    }
  }

  Future<void> _summarizeInitialRequest(
    BookAssistantNavigationData request,
    BookAssistantLoaded conversation,
    Emitter<BookAssistantState> emit,
  ) async {
    final String purchaseId = request.purchaseId.trim();
    if (purchaseId.isEmpty) {
      emit(
        conversation.copyWith(
          isAnswering: false,
          errorMessage: 'The purchase identifier is unavailable.',
        ),
      );
      return;
    }

    final Result<String> result = await _summarizePurchase(
      SummarizePurchaseParams(purchaseId),
    );
    switch (result) {
      case Success<String>(value: final String summary):
        emit(
          conversation.copyWith(
            response: AssistantResponse(
              question: request.question,
              answer: summary,
              books: <AssistantBook>[request.book],
            ),
            clearPendingQuestion: true,
            isAnswering: false,
          ),
        );
      case ResultFailure<String>(message: final String message):
        emit(
          conversation.copyWith(
            isAnswering: false,
            errorMessage: message,
          ),
        );
    }
  }

  Future<void> _onPromptSelected(
    BookAssistantPromptSelected event,
    Emitter<BookAssistantState> emit,
  ) async {
    await _submitQuestion(event.prompt, emit);
  }

  Future<void> _onQuestionSubmitted(
    BookAssistantQuestionSubmitted event,
    Emitter<BookAssistantState> emit,
  ) async {
    await _submitQuestion(event.question, emit);
  }

  void _onBookToggled(
    BookAssistantBookToggled event,
    Emitter<BookAssistantState> emit,
  ) {
    final BookAssistantState current = state;
    if (current is! BookAssistantLoaded) {
      return;
    }

    final bool isSelected = current.selectedBooks.contains(event.book);
    final List<AssistantBook> selected = isSelected
        ? current.selectedBooks
            .where((AssistantBook book) => book.id != event.book.id)
            .toList()
        : <AssistantBook>[...current.selectedBooks, event.book];

    emit(current.copyWith(selectedBooks: selected));
  }

  Future<void> _submitQuestion(
    String question,
    Emitter<BookAssistantState> emit,
  ) async {
    final BookAssistantState current = state;
    if (current is! BookAssistantLoaded) {
      return;
    }

    final String trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty) {
      return;
    }

    final BookAssistantLoaded answering = current.copyWith(
      clearResponse: true,
      clearError: true,
      isAnswering: true,
      pendingQuestion: trimmedQuestion,
    );
    emit(answering);

    final Result<AssistantResponse> result = await _askAssistant(
      AskBookAssistantParams(
        question: trimmedQuestion,
        books: current.selectedBooks,
      ),
    );

    switch (result) {
      case Success<AssistantResponse>(value: final AssistantResponse response):
        emit(
          answering.copyWith(
            response: response,
            clearPendingQuestion: true,
            isAnswering: false,
          ),
        );
      case ResultFailure<AssistantResponse>(message: final String message):
        emit(
          answering.copyWith(
            isAnswering: false,
            errorMessage: message,
          ),
        );
    }
  }
}
