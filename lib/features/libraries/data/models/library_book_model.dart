import '../../domain/entities/library_book_entity.dart';

class LibraryBookModel {
  const LibraryBookModel({
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

  factory LibraryBookModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> bookJson =
        json['book'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> categoryJson =
        bookJson['category'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return LibraryBookModel(
      listingId: json['listingId'] as String? ?? '',
      price: json['price']?.toString() ?? '',
      stock: json['stock']?.toString() ?? '',
      condition: json['condition'] as int? ?? 0,
      bookId: bookJson['bookId'] as String? ?? '',
      title: bookJson['title'] as String? ?? '',
      author: bookJson['author'] as String? ?? '',
      description: bookJson['description'] as String? ?? '',
      coverImageUrl: bookJson['coverImageUrl'] as String? ?? '',
      language: bookJson['language'] as String? ?? '',
      isbn: bookJson['isbn'] as String? ?? '',
      categoryId: categoryJson['id'] as String? ?? '',
      categoryNameAr: categoryJson['nameAr'] as String? ?? '',
      categoryNameEn: categoryJson['nameEn'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'listingId': listingId,
      'price': price,
      'stock': stock,
      'condition': condition,
      'book': <String, dynamic>{
        'bookId': bookId,
        'title': title,
        'author': author,
        'description': description,
        'coverImageUrl': coverImageUrl,
        'language': language,
        'isbn': isbn,
        'category': <String, dynamic>{
          'id': categoryId,
          'nameAr': categoryNameAr,
          'nameEn': categoryNameEn,
        },
      },
    };
  }

  LibraryBookEntity toEntity() {
    return LibraryBookEntity(
      listingId: listingId,
      price: price,
      stock: stock,
      condition: condition,
      bookId: bookId,
      title: title,
      author: author,
      description: description,
      coverImageUrl: coverImageUrl,
      language: language,
      isbn: isbn,
      categoryId: categoryId,
      categoryNameAr: categoryNameAr,
      categoryNameEn: categoryNameEn,
    );
  }
}
