import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/assistant_book.dart';
import '../../domain/entities/assistant_response.dart';
import '../../domain/use_cases/ask_book_assistant_use_case.dart';
import '../../domain/use_cases/get_assistant_books_use_case.dart';

sealed class BookAssistantEvent {
  const BookAssistantEvent();
}

final class BookAssistantStarted extends BookAssistantEvent {
  const BookAssistantStarted();
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
    this.isAnswering = false,
  });

  final List<AssistantBook> books;
  final List<AssistantBook> selectedBooks;
  final AssistantResponse? response;
  final bool isAnswering;

  BookAssistantLoaded copyWith({
    List<AssistantBook>? books,
    List<AssistantBook>? selectedBooks,
    AssistantResponse? response,
    bool? clearResponse,
    bool? isAnswering,
  }) {
    return BookAssistantLoaded(
      books: books ?? this.books,
      selectedBooks: selectedBooks ?? this.selectedBooks,
      response: clearResponse == true ? null : response ?? this.response,
      isAnswering: isAnswering ?? this.isAnswering,
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
  })  : _getBooks = getBooks,
        _askAssistant = askAssistant,
        super(const BookAssistantInitial()) {
    on<BookAssistantStarted>(_onStarted);
    on<BookAssistantPromptSelected>(_onPromptSelected);
    on<BookAssistantQuestionSubmitted>(_onQuestionSubmitted);
    on<BookAssistantBookToggled>(_onBookToggled);
  }

  final GetAssistantBooksUseCase _getBooks;
  final AskBookAssistantUseCase _askAssistant;

  Future<void> _onStarted(
    BookAssistantStarted event,
    Emitter<BookAssistantState> emit,
  ) async {
    emit(const BookAssistantLoading());
    switch (await _getBooks(const NoParams())) {
      case Success<List<AssistantBook>>(value: final List<AssistantBook> books):
        emit(BookAssistantLoaded(books: books));
      case ResultFailure<List<AssistantBook>>(message: final String message):
        emit(BookAssistantFailure(message));
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

    emit(current.copyWith(isAnswering: true));
    final Result<AssistantResponse> result = await _askAssistant(
      AskBookAssistantParams(
        question: question,
        books: current.selectedBooks,
      ),
    );

    switch (result) {
      case Success<AssistantResponse>(value: final AssistantResponse response):
        emit(current.copyWith(response: response, isAnswering: false));
      case ResultFailure<AssistantResponse>(message: final String message):
        emit(BookAssistantFailure(message));
    }
  }
}
