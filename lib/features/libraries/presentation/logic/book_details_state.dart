import 'package:equatable/equatable.dart';

import '../../domain/entities/library_book_entity.dart';

enum BookDetailsStatus { initial, loading, success, error }

class BookDetailsState extends Equatable {
  const BookDetailsState({
    this.status = BookDetailsStatus.initial,
    this.book,
    this.errorMessage,
  });

  final BookDetailsStatus status;
  final LibraryBookEntity? book;
  final String? errorMessage;

  BookDetailsState copyWith({
    BookDetailsStatus? status,
    LibraryBookEntity? book,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookDetailsState(
      status: status ?? this.status,
      book: book ?? this.book,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, book, errorMessage];
}
