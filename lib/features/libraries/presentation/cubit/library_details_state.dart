import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/library_book_entity.dart';

@immutable
class LibraryDetailsState extends Equatable {
  const LibraryDetailsState({
    this.status = LibraryDetailsStatus.initial,
    this.books = const <LibraryBookEntity>[],
    this.authors = const <LibraryAuthorViewModel>[],
    this.hasMore = false,
    this.errorMessage,
  });

  final LibraryDetailsStatus status;
  final List<LibraryBookEntity> books;
  final List<LibraryAuthorViewModel> authors;
  final bool hasMore;
  final String? errorMessage;

  LibraryDetailsState copyWith({
    LibraryDetailsStatus? status,
    List<LibraryBookEntity>? books,
    bool? hasMore,
    String? errorMessage,
  }) {
    return LibraryDetailsState(
      status: status ?? this.status,
      books: books ?? this.books,
      authors: books != null ? _deriveAuthors(books) : authors,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static List<LibraryAuthorViewModel> _deriveAuthors(
    List<LibraryBookEntity> books,
  ) {
    final Map<String, LibraryAuthorViewModel> authorsByName =
        <String, LibraryAuthorViewModel>{};

    for (final LibraryBookEntity book in books) {
      if (book.author.isEmpty) continue;
      authorsByName.putIfAbsent(
        book.author,
        () => LibraryAuthorViewModel(
          name: book.author,
          imageUrl: book.coverImageUrl,
        ),
      );
    }

    return authorsByName.values.toList(growable: false);
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        books,
        authors,
        hasMore,
        errorMessage,
      ];
}

enum LibraryDetailsStatus { initial, loading, success, error }

@immutable
class LibraryAuthorViewModel extends Equatable {
  const LibraryAuthorViewModel({
    required this.name,
    required this.imageUrl,
  });

  final String name;
  final String imageUrl;

  @override
  List<Object?> get props => <Object?>[name, imageUrl];
}
