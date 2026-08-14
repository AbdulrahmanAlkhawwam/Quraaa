import '../../domain/entities/favorite_book.dart';

class FavoriteBookModel {
  const FavoriteBookModel({
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

  factory FavoriteBookModel.fromJson(Map<String, dynamic> json) {
    return FavoriteBookModel(
      favoriteId: json['favoriteId']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverImageUrl: json['coverImageUrl']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      favoritedAt: DateTime.tryParse(json['favoritedAt']?.toString() ?? ''),
    );
  }

  FavoriteBook toEntity() => FavoriteBook(
    favoriteId: favoriteId,
    bookId: bookId,
    title: title,
    author: author,
    description: description,
    coverImageUrl: coverImageUrl,
    categoryId: categoryId,
    language: language,
    isbn: isbn,
    favoritedAt: favoritedAt,
  );
}

class FavoriteBooksPageModel {
  const FavoriteBooksPageModel({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<FavoriteBookModel> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory FavoriteBooksPageModel.fromJson(Map<String, dynamic> json) {
    int number(Object? value) => value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    final Object? rawItems = json['items'];
    return FavoriteBooksPageModel(
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => FavoriteBookModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const <FavoriteBookModel>[],
      pageNumber: number(json['pageNumber']),
      pageSize: number(json['pageSize']),
      totalCount: number(json['totalCount']),
      totalPages: number(json['totalPages']),
      hasNextPage: json['hasNextPage'] == true,
      hasPreviousPage: json['hasPreviousPage'] == true,
    );
  }
}
