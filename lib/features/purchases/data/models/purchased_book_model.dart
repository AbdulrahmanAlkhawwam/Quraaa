import '../../domain/entities/purchased_book.dart';

class PurchasedBookModel extends PurchasedBook {
  const PurchasedBookModel({
    required super.purchaseId,
    required super.bookId,
    required super.title,
    required super.author,
    required super.coverImageUrl,
    required super.purchasedAt,
    required super.digital,
    super.description,
    super.language,
    super.isbn,
    super.categoryId,
  });

  /// One item of the buy-history endpoint: purchase fields at the top level,
  /// book details nested under `book`, the category under `book.category`.
  /// A purchase is digital when it carries a digital asset URL.
  factory PurchasedBookModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> book = json['book'] is Map
        ? Map<String, dynamic>.from(json['book'] as Map)
        : const <String, dynamic>{};
    final Map<String, dynamic> category = book['category'] is Map
        ? Map<String, dynamic>.from(book['category'] as Map)
        : const <String, dynamic>{};
    final String asset = json['purchasedDigitalAssetUrl']?.toString() ?? '';
    return PurchasedBookModel(
      purchaseId: json['purchaseId']?.toString() ?? '',
      bookId: book['bookId']?.toString() ?? '',
      title: book['title']?.toString() ?? '',
      author: book['author']?.toString() ?? '',
      coverImageUrl: book['coverImageUrl']?.toString() ?? '',
      purchasedAt: DateTime.tryParse(json['purchasedAt']?.toString() ?? ''),
      digital: asset.isNotEmpty,
      description: book['description']?.toString() ?? '',
      language: book['language']?.toString() ?? '',
      isbn: book['isbn']?.toString() ?? '',
      categoryId: category['id']?.toString() ?? '',
    );
  }

  /// The flat shape written by [toCacheJson].
  factory PurchasedBookModel.fromCacheJson(Map<String, dynamic> json) {
    return PurchasedBookModel(
      purchaseId: json['purchaseId']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      coverImageUrl: json['coverImageUrl']?.toString() ?? '',
      purchasedAt: DateTime.tryParse(json['purchasedAt']?.toString() ?? ''),
      digital: json['digital'] == true,
      description: json['description']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
    );
  }

  /// Plain entity for everything above the data layer.
  PurchasedBook toEntity() => PurchasedBook(
    purchaseId: purchaseId,
    bookId: bookId,
    title: title,
    author: author,
    coverImageUrl: coverImageUrl,
    purchasedAt: purchasedAt,
    digital: digital,
    description: description,
    language: language,
    isbn: isbn,
    categoryId: categoryId,
  );

  static Map<String, Object?> toCacheJson(PurchasedBook book) =>
      <String, Object?>{
        'purchaseId': book.purchaseId,
        'bookId': book.bookId,
        'title': book.title,
        'author': book.author,
        'coverImageUrl': book.coverImageUrl,
        'purchasedAt': book.purchasedAt?.toIso8601String(),
        'digital': book.digital,
        'description': book.description,
        'language': book.language,
        'isbn': book.isbn,
        'categoryId': book.categoryId,
      };
}
