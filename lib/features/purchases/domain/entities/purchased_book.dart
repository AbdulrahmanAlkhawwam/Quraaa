import 'package:equatable/equatable.dart';

class PurchasedBook extends Equatable {
  const PurchasedBook({
    required this.purchaseId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.purchasedAt,
    required this.digital,
    this.description = '',
    this.language = '',
    this.isbn = '',
    this.categoryId = '',
  });

  final String purchaseId;
  final String bookId;
  final String title;
  final String author;
  final String coverImageUrl;
  final DateTime? purchasedAt;

  /// Whether the purchase includes a readable digital copy.
  final bool digital;
  final String description;
  final String language;
  final String isbn;
  final String categoryId;

  @override
  List<Object?> get props => <Object?>[
    purchaseId,
    bookId,
    title,
    author,
    coverImageUrl,
    purchasedAt,
    digital,
    description,
    language,
    isbn,
    categoryId,
  ];
}
