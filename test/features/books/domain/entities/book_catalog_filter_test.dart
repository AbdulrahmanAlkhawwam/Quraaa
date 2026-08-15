import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/books/books.dart';

void main() {
  test('accepts empty and ordered price ranges', () {
    expect(const BookCatalogFilter().hasValidPriceRange, isTrue);
    expect(
      const BookCatalogFilter(minPrice: 0, maxPrice: 20).hasValidPriceRange,
      isTrue,
    );
  });

  test('rejects negative and inverted price ranges', () {
    expect(
      const BookCatalogFilter(minPrice: -1).hasValidPriceRange,
      isFalse,
    );
    expect(
      const BookCatalogFilter(minPrice: 20, maxPrice: 10).hasValidPriceRange,
      isFalse,
    );
  });
}
