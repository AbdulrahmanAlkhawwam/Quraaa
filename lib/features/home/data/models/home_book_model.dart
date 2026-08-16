import '../../domain/entities/home_book_entity.dart';

class HomeBookModel {
  const HomeBookModel({
    required this.listingId,
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

  final String listingId;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final String categoryId;
  final String language;
  final String isbn;
  final String purchaseCount;
  final String ratingCount;
  final String averageRating;
  final String activeListingCount;

  factory HomeBookModel.fromJson(Map<String, dynamic> json) {
    return HomeBookModel(
      listingId: _asString(json['listingId']),
      title: _asString(json['title']),
      author: _asString(json['author']),
      description: _asString(json['description']),
      coverImageUrl: _asString(json['coverImageUrl']),
      categoryId: _asString(json['categoryId']),
      language: _asString(json['language']),
      isbn: _asString(json['isbn']),
      purchaseCount: _asString(json['purchaseCount']),
      ratingCount: _asString(json['ratingCount']),
      averageRating: _asString(json['averageRating']),
      activeListingCount: _asString(json['activeListingCount']),
    );
  }

  HomeBookEntity toEntity() {
    return HomeBookEntity(
      listingId: listingId,
      title: title,
      author: author,
      description: description,
      coverImageUrl: coverImageUrl,
      categoryId: categoryId,
      language: language,
      isbn: isbn,
      purchaseCount: purchaseCount,
      ratingCount: ratingCount,
      averageRating: averageRating,
      activeListingCount: activeListingCount,
    );
  }

  static String _asString(Object? value) => value?.toString() ?? '';
}
