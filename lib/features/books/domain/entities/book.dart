import 'package:equatable/equatable.dart';

enum BookFormat { audio, ebook, free, used }

class Book extends Equatable {
  const Book({
    required this.id,
    required this.title,
    required this.price,
    required this.format,
    this.listingId = '',
    this.subtitle = '',
    this.author = '',
    this.description = '',
    this.coverImageUrl = '',
    this.coverAsset = '',
    this.language = '',
    this.isbn = '',
    this.categoryId = '',
    this.publisher = '',
    this.version = '',
    this.condition,
    this.previewImageUrls = const <String>[],
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

  /// Kept as a local-development fallback for the existing bundled covers.
  final String coverAsset;
  final String language;
  final String isbn;
  final String categoryId;
  final String publisher;
  final String version;
  final int? condition;
  final List<String> previewImageUrls;

  String get displayCover =>
      coverImageUrl.trim().isNotEmpty ? coverImageUrl : coverAsset;

  @override
  List<Object?> get props => <Object?>[
        id,
        listingId,
        title,
        subtitle,
        author,
        description,
        price,
        format,
        coverImageUrl,
        coverAsset,
        language,
        isbn,
        categoryId,
        publisher,
        version,
        condition,
        previewImageUrls,
      ];
}
