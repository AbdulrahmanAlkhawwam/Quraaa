import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../domain/use_cases/get_books_use_case.dart';

sealed class BooksEvent { const BooksEvent(); }
class BooksRequested extends BooksEvent { const BooksRequested(); }
class BooksQueryChanged extends BooksEvent { const BooksQueryChanged(this.query); final String query; }
class BooksFilterChanged extends BooksEvent { const BooksFilterChanged(this.format); final BookFormat? format; }

enum BooksStatus { initial, loading, success, failure }

class BooksState {
  const BooksState({this.status = BooksStatus.initial, this.books = const <Book>[], this.query = '', this.format, this.errorMessage});
  final BooksStatus status;
  final List<Book> books;
  final String query;
  final BookFormat? format;
  final String? errorMessage;
  BooksState copyWith({BooksStatus? status, List<Book>? books, String? query, BookFormat? format, bool clearFormat = false, String? errorMessage, bool clearError = false}) => BooksState(status: status ?? this.status, books: books ?? this.books, query: query ?? this.query, format: clearFormat ? null : format ?? this.format, errorMessage: clearError ? null : errorMessage ?? this.errorMessage);
}

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  BooksBloc({required GetBooksUseCase getBooks}) : _getBooks = getBooks, super(const BooksState()) {
    on<BooksRequested>(_onRequested);
    on<BooksQueryChanged>(_onQueryChanged);
    on<BooksFilterChanged>(_onFilterChanged);
  }
  final GetBooksUseCase _getBooks;
  Future<void> _onRequested(BooksEvent event, Emitter<BooksState> emit) async {
    emit(state.copyWith(status: BooksStatus.loading, clearError: true));
    try {
      final books = await _getBooks(query: state.query, format: state.format);
      emit(state.copyWith(status: BooksStatus.success, books: books));
    } catch (_) { emit(state.copyWith(status: BooksStatus.failure, errorMessage: 'Unable to load books.')); }
  }
  Future<void> _onQueryChanged(BooksQueryChanged event, Emitter<BooksState> emit) async { emit(state.copyWith(query: event.query)); add(const BooksRequested()); }
  Future<void> _onFilterChanged(BooksFilterChanged event, Emitter<BooksState> emit) async { emit(state.copyWith(format: event.format, clearFormat: event.format == null)); add(const BooksRequested()); }
}
