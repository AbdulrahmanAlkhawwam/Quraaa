import 'package:equatable/equatable.dart';

/// A book summary displayed in a home feed section.
class HomeBookEntity extends Equatable {
  const HomeBookEntity({
    required this.bookId,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.categoryId,
    required this.language,
    required this.isbn,
    required this.purchaseCount,
    required this.ratingCount,
    required this.averageRating,
    required this.activeListingCount,
  });

  final String bookId;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final String categoryId;
  final String language;
  final String isbn;

  /// Numeric API fields are preserved as strings because the backend can
  /// return values larger than the platform integer range.
  final String purchaseCount;
  final String ratingCount;
  final String averageRating;
  final String activeListingCount;

  @override
  List<Object?> get props => <Object?>[
    bookId,
    title,
    author,
    description,
    coverImageUrl,
    categoryId,
    language,
    isbn,
    purchaseCount,
    ratingCount,
    averageRating,
    activeListingCount,
  ];
}
