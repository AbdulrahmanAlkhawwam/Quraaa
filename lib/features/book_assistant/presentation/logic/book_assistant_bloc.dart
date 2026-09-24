import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
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
    final Either<Failure, List<AssistantBook>> result = await _getBooks();
    final List<AssistantBook>? books = result.toNullable();
    if (books == null) {
      emit(BookAssistantFailure(result.getLeft().toNullable()!.message));
      return;
    }

    final BookAssistantNavigationData? request = event.initialRequest;
    if (request == null) {
      emit(BookAssistantLoaded(books: books));
      return;
    }

    final List<AssistantBook> availableBooks =
        books.any((AssistantBook book) => book.id == request.book.id)
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

    final Either<Failure, String> result = await _summarizePurchase(
      SummarizePurchaseParams(purchaseId),
    );
    emit(
      result.fold(
        (Failure failure) => conversation.copyWith(
          isAnswering: false,
          errorMessage: failure.message,
        ),
        (String summary) => conversation.copyWith(
          response: AssistantResponse(
            question: request.question,
            answer: summary,
            books: <AssistantBook>[request.book],
          ),
          clearPendingQuestion: true,
          isAnswering: false,
        ),
      ),
    );
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

    final Either<Failure, AssistantResponse> result = await _askAssistant(
      AskBookAssistantParams(
        question: trimmedQuestion,
        books: current.selectedBooks,
      ),
    );

    emit(
      result.fold(
        (Failure failure) =>
            answering.copyWith(isAnswering: false, errorMessage: failure.message),
        (AssistantResponse response) => answering.copyWith(
          response: response,
          clearPendingQuestion: true,
          isAnswering: false,
        ),
      ),
    );
  }
}
