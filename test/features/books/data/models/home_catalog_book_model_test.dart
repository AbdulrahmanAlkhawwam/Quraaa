import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/books/books.dart';

void main() {
  test('parses a nested listing returned by the home catalog', () {
    final HomeCatalogBookModel model = HomeCatalogBookModel.fromJson(
      <String, dynamic>{
        'listingId': 'listing-1',
        'price': 13.5,
        'format': 'E-book',
        'condition': 0,
        'book': <String, dynamic>{
          'bookId': 'book-1',
          'title': 'Global English Course Book 11',
          'author': 'Cambridge',
          'coverImageUrl': 'https://example.com/cover.jpg',
          'language': 'English',
          'publisher': 'Cambridge University',
          'edition': 2025,
          'category': <String, dynamic>{'id': 'category-1'},
          'previewImages': <String>['https://example.com/page-1.jpg'],
        },
      },
    );

    expect(model.id, 'book-1');
    expect(model.listingId, 'listing-1');
    expect(model.price, '13.5');
    expect(model.format, BookFormat.ebook);
    expect(model.publisher, 'Cambridge University');
    expect(model.version, '2025');
    expect(model.previewImageUrls, hasLength(1));
  });

  test('parses the flat home catalog response fields', () {
    final HomeCatalogBookModel model = HomeCatalogBookModel.fromJson(
      <String, dynamic>{
        'listingId': 'listing-4',
        'title': 'book4',
        'authorName': 'Author name',
        'coverImageUrl': 'https://example.com/book.webp',
        'category': <String, dynamic>{'id': 'category-1'},
        'format': 'Physical',
        'startingPrice': 123,
        'isFree': false,
      },
    );

    expect(model.id, 'listing-4');
    expect(model.listingId, 'listing-4');
    expect(model.author, 'Author name');
    expect(model.price, '123');
    expect(model.categoryId, 'category-1');
    expect(model.format, BookFormat.used);
  });
  test('recognizes free, audio, and used catalog entries', () {
    BookFormat parse(Map<String, dynamic> json) =>
        HomeCatalogBookModel.fromJson(json).format;

    expect(
      parse(<String, dynamic>{'bookId': '1', 'price': 0}),
      BookFormat.free,
    );
    expect(
      parse(<String, dynamic>{
        'bookId': '2',
        'price': 4,
        'format': 'Sound Book',
      }),
      BookFormat.audio,
    );
    expect(
      parse(<String, dynamic>{
        'bookId': '3',
        'price': 4,
        'condition': 1,
      }),
      BookFormat.used,
    );
  });
}
