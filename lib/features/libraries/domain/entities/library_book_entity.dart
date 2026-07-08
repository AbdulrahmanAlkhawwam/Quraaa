import 'package:equatable/equatable.dart';

/// A book listing returned by `/Libraries/{libraryId}/books`.
class LibraryBookEntity extends Equatable {
  const LibraryBookEntity({
    required this.listingId,
    required this.price,
    required this.stock,
    required this.condition,
    required this.bookId,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.language,
    required this.isbn,
    required this.categoryId,
    required this.categoryNameAr,
    required this.categoryNameEn,
  });

  final String listingId;
  final String price;
  final String stock;
  final int condition;
  final String bookId;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final String language;
  final String isbn;
  final String categoryId;
  final String categoryNameAr;
  final String categoryNameEn;

  @override
  List<Object?> get props => <Object?>[
        listingId,
        price,
        stock,
        condition,
        bookId,
        title,
        author,
        description,
        coverImageUrl,
        language,
        isbn,
        categoryId,
        categoryNameAr,
        categoryNameEn,
      ];
}
