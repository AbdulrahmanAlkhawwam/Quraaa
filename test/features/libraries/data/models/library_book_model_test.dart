import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/libraries/data/models/library_book_model.dart';

void main() {
  test('parses the listing details response contract', () {
    const String listingId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
    final LibraryBookModel model = LibraryBookModel.fromJson(
      <String, dynamic>{
        'listingId': listingId,
        'price': '-0',
        'stock': '-9224619187929065465',
        'condition': 'New',
        'status': 0,
        'format': 'Digital',
        'version': '-4369571523189312289476208670808831096325620137',
        'book': <String, dynamic>{
          'bookId': listingId,
          'title': 'Book title',
          'author': 'Writer',
          'description': 'Description',
          'coverImageUrl': 'https://example.com/cover.jpg',
          'language': 'Arabic',
          'isbn': '123',
          'category': <String, dynamic>{
            'id': listingId,
            'nameAr': 'أدب',
            'nameEn': 'Literature',
          },
        },
      },
    );

    expect(model.listingId, listingId);
    expect(model.condition, 1);
    expect(model.format, 'Digital');
    expect(model.version, startsWith('-436957'));
    expect(model.stock, '-9224619187929065465');
    expect(model.bookId, listingId);
    expect(model.categoryNameAr, 'أدب');
    expect(model.toEntity().listingId, listingId);
  });

  test('parses the flat response currently returned by listing details', () {
    final LibraryBookModel model = LibraryBookModel.fromJson(
      <String, dynamic>{
        'id': 'listing-4',
        'title': 'book4',
        'coverImageUrl': 'https://example.com/book.webp',
        'format': 'Physical',
        'condition': 'New',
        'language': 'Other',
        'publisher': 'Library name',
        'writer': 'Author name',
        'version': 1,
        'price': 123.00,
        'previewImageUrls': <String>[],
      },
    );

    expect(model.listingId, 'listing-4');
    expect(model.title, 'book4');
    expect(model.author, 'Author name');
    expect(model.publisher, 'Library name');
    expect(model.coverImageUrl, 'https://example.com/book.webp');
    expect(model.price, '123.0');
    expect(model.condition, 1);
    expect(model.format, 'Physical');
  });
}
