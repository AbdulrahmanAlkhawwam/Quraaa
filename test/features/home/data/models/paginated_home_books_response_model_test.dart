import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/home/data/models/paginated_home_books_response_model.dart';

void main() {
  test('parses book fields and preserves huge numeric strings', () {
    const String hugeNumber =
        '-288309521794527709682421938838958739147789977246935422199417142093237378725';
    final PaginatedHomeBooksResponseModel model =
        PaginatedHomeBooksResponseModel.fromJson(<String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'bookId': 'book-id',
              'title': 'Book title',
              'author': 'Book author',
              'description': 'Description',
              'coverImageUrl': 'https://example.com/cover.jpg',
              'categoryId': 'category-id',
              'language': 'ar',
              'isbn': '123',
              'purchaseCount': '-0',
              'ratingCount': 12,
              'averageRating': hugeNumber,
              'activeListingCount': hugeNumber,
            },
          ],
          'pageNumber': hugeNumber,
          'pageSize': '-0',
          'totalCount': 1,
          'totalPages': '0',
          'hasNextPage': true,
          'hasPreviousPage': 'false',
        });

    expect(model.items, hasLength(1));
    expect(model.items.single.title, 'Book title');
    expect(model.items.single.ratingCount, '12');
    expect(model.items.single.averageRating, hugeNumber);
    expect(model.pageNumber, hugeNumber);
    expect(model.totalCount, '1');
    expect(model.hasNextPage, isTrue);
    expect(model.hasPreviousPage, isFalse);
  });

  test('uses safe defaults for missing values', () {
    final PaginatedHomeBooksResponseModel model =
        PaginatedHomeBooksResponseModel.fromJson(<String, dynamic>{});

    expect(model.items, isEmpty);
    expect(model.pageNumber, '0');
    expect(model.pageSize, '0');
    expect(model.hasNextPage, isFalse);
  });
}
