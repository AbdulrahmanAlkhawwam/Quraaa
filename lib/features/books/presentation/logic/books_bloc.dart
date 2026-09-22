import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/book_catalog_filter.dart';
import '../../domain/use_cases/get_books_use_case.dart';

sealed class BooksEvent {
  const BooksEvent();
}

class BooksRequested extends BooksEvent {
  const BooksRequested();
}

class BooksQueryChanged extends BooksEvent {
  const BooksQueryChanged(this.query);

  final String query;
}

class BooksFilterChanged extends BooksEvent {
  const BooksFilterChanged(this.format);

  final BookFormat? format;
}

class BooksCatalogFilterApplied extends BooksEvent {
  const BooksCatalogFilterApplied(this.filter);

  final BookCatalogFilter filter;
}

enum BooksStatus { initial, loading, success, failure }

class BooksState {
  const BooksState({
    this.status = BooksStatus.initial,
    this.catalog = const <Book>[],
    this.books = const <Book>[],
    this.query = '',
    this.format,
    this.catalogFilter = const BookCatalogFilter(),
    this.errorMessage,
  });

  final BooksStatus status;
  final List<Book> catalog;
  final List<Book> books;
  final String query;
  final BookFormat? format;
  final BookCatalogFilter catalogFilter;
  final String? errorMessage;

  BooksState copyWith({
    BooksStatus? status,
    List<Book>? catalog,
    List<Book>? books,
    String? query,
    BookFormat? format,
    bool clearFormat = false,
    BookCatalogFilter? catalogFilter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BooksState(
      status: status ?? this.status,
      catalog: catalog ?? this.catalog,
      books: books ?? this.books,
      query: query ?? this.query,
      format: clearFormat ? null : format ?? this.format,
      catalogFilter: catalogFilter ?? this.catalogFilter,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  BooksBloc({required GetBooksUseCase getBooks})
      : _getBooks = getBooks,
        super(const BooksState()) {
    on<BooksRequested>(_onRequested);
    on<BooksQueryChanged>(_onQueryChanged);
    on<BooksFilterChanged>(_onFilterChanged);
    on<BooksCatalogFilterApplied>(_onCatalogFilterApplied);
  }

  final GetBooksUseCase _getBooks;

  Future<void> _onRequested(
    BooksRequested event,
    Emitter<BooksState> emit,
  ) async {
    emit(state.copyWith(status: BooksStatus.loading, clearError: true));
    try {
      final List<Book> catalog = await _getBooks(
        catalogFilter: state.catalogFilter,
      );
      emit(
        state.copyWith(
          status: BooksStatus.success,
          catalog: catalog,
          books: _filter(
            catalog,
            query: state.query,
            format: state.format,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BooksStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onQueryChanged(
    BooksQueryChanged event,
    Emitter<BooksState> emit,
  ) {
    emit(
      state.copyWith(
        query: event.query,
        books: _filter(
          state.catalog,
          query: event.query,
          format: state.format,
        ),
      ),
    );
  }

  void _onFilterChanged(
    BooksFilterChanged event,
    Emitter<BooksState> emit,
  ) {
    emit(
      state.copyWith(
        format: event.format,
        clearFormat: event.format == null,
        books: _filter(
          state.catalog,
          query: state.query,
          format: event.format,
        ),
      ),
    );
  }

  Future<void> _onCatalogFilterApplied(
    BooksCatalogFilterApplied event,
    Emitter<BooksState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BooksStatus.loading,
        catalogFilter: event.filter,
        clearError: true,
      ),
    );
    try {
      final List<Book> catalog = await _getBooks(catalogFilter: event.filter);
      emit(
        state.copyWith(
          status: BooksStatus.success,
          catalog: catalog,
          books: _filter(
            catalog,
            query: state.query,
            format: state.format,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BooksStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  List<Book> _filter(
    List<Book> books, {
    required String query,
    required BookFormat? format,
  }) {
    final String normalizedQuery = query.trim().toLowerCase();
    return books.where((Book book) {
      final bool matchesQuery = normalizedQuery.isEmpty ||
          book.title.toLowerCase().contains(normalizedQuery) ||
          book.subtitle.toLowerCase().contains(normalizedQuery) ||
          book.author.toLowerCase().contains(normalizedQuery);
      return matchesQuery && (format == null || book.format == format);
    }).toList(growable: false);
  }
}
