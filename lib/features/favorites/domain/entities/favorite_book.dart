import 'package:equatable/equatable.dart';

class FavoriteBook extends Equatable {
  const FavoriteBook({
    required this.favoriteId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.categoryId,
    required this.language,
    required this.isbn,
    required this.favoritedAt,
  });

  final String favoriteId;
  final String bookId;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final String categoryId;
  final String language;
  final String isbn;
  final DateTime? favoritedAt;

  @override
  List<Object?> get props => <Object?>[
    favoriteId,
    bookId,
    title,
    author,
    description,
    coverImageUrl,
    categoryId,
    language,
    isbn,
    favoritedAt,
  ];
}

class FavoriteBooksPage extends Equatable {
  const FavoriteBooksPage({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<FavoriteBook> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  @override
  List<Object?> get props => <Object?>[
    items,
    pageNumber,
    pageSize,
    totalCount,
    totalPages,
    hasNextPage,
    hasPreviousPage,
  ];
}
