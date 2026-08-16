import '../../domain/entities/book.dart';

class HomeCatalogBookModel {
  const HomeCatalogBookModel({
    required this.id,
    required this.listingId,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.description,
    required this.price,
    required this.format,
    required this.coverImageUrl,
    required this.language,
    required this.isbn,
    required this.categoryId,
    required this.publisher,
    required this.version,
    required this.condition,
    required this.previewImageUrls,
  });

  final String id;
  final String listingId;
  final String title;
  final String subtitle;
  final String author;
  final String description;
  final String price;
  final BookFormat format;
  final String coverImageUrl;
  final String language;
  final String isbn;
  final String categoryId;
  final String publisher;
  final String version;
  final int? condition;
  final List<String> previewImageUrls;

  factory HomeCatalogBookModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> book = _asMap(json['book']) ?? json;
    final Map<String, dynamic> category =
        _asMap(book['category']) ?? const <String, dynamic>{};
    final String price = _asString(
      json['startingPrice'] ??
          json['price'] ??
          json['unitPrice'] ??
          book['startingPrice'] ??
          book['price'],
    );
    final int? condition = _asInt(json['condition'] ?? book['condition']);

    return HomeCatalogBookModel(
      id: _asString(
        book['bookId'] ??
            book['id'] ??
            json['bookId'] ??
            json['id'] ??
            json['listingId'],
      ),
      listingId: _asString(
        json['listingId'] ?? json['listing'] ?? book['listingId'],
      ),
      title: _asString(book['title'] ?? json['title']),
      subtitle: _asString(book['subtitle'] ?? json['subtitle']),
      author: _asString(
        book['authorName'] ??
            book['author'] ??
            json['authorName'] ??
            json['author'],
      ),
      description: _asString(book['description'] ?? json['description']),
      price: price,
      format: json['isFree'] == true || book['isFree'] == true
          ? BookFormat.free
          : _parseFormat(
              json['format'] ??
                  json['listingFormat'] ??
                  book['format'] ??
                  book['listingFormat'],
              price: price,
              condition: condition,
            ),
      coverImageUrl: _asString(
        book['coverImageUrl'] ??
            book['coverUrl'] ??
            json['coverImageUrl'] ??
            json['coverUrl'],
      ),
      language: _asString(book['language'] ?? json['language']),
      isbn: _asString(book['isbn'] ?? json['isbn']),
      categoryId: _asString(
        category['id'] ?? book['categoryId'] ?? json['categoryId'],
      ),
      publisher: _asString(book['publisher'] ?? json['publisher']),
      version: _asString(
        book['version'] ??
            book['edition'] ??
            json['version'] ??
            json['edition'],
      ),
      condition: condition,
      previewImageUrls: _asStringList(
        book['previewImageUrls'] ??
            book['previewImages'] ??
            json['previewImageUrls'] ??
            json['previewImages'],
      ),
    );
  }

  Book toEntity() {
    return Book(
      id: id,
      listingId: listingId,
      title: title,
      subtitle: subtitle,
      author: author,
      description: description,
      price: price,
      format: format,
      coverImageUrl: coverImageUrl,
      language: language,
      isbn: isbn,
      categoryId: categoryId,
      publisher: publisher,
      version: version,
      condition: condition,
      previewImageUrls: previewImageUrls,
    );
  }

  static BookFormat _parseFormat(
    Object? raw, {
    required String price,
    required int? condition,
  }) {
    final String value = _asString(raw).trim().toLowerCase();
    final double? numericPrice = double.tryParse(price);

    if (numericPrice == 0 || value.contains('free')) {
      return BookFormat.free;
    }
    if (value.contains('audio') || value.contains('sound')) {
      return BookFormat.audio;
    }
    if (value.contains('ebook') ||
        value.contains('e-book') ||
        value.contains('digital') ||
        value.contains('pdf')) {
      return BookFormat.ebook;
    }
    if (value.contains('used') || (condition != null && condition > 0)) {
      return BookFormat.used;
    }

    final int? numericFormat = _asInt(raw);
    return switch (numericFormat) {
      2 => BookFormat.used,
      1 => BookFormat.ebook,
      _ => BookFormat.used,
    };
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (Object? key, Object? item) =>
            MapEntry<String, dynamic>(key.toString(), item),
      );
    }
    return null;
  }

  static List<String> _asStringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map((Object? item) => _asString(item).trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(_asString(value));
  }

  static String _asString(Object? value) => value?.toString() ?? '';
}
