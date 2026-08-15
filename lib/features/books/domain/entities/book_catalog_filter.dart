import 'package:equatable/equatable.dart';

enum ListingFormat {
  digital(1),
  physical(2);

  const ListingFormat(this.apiValue);
  final int apiValue;
}

enum SellerType {
  library(1),
  user(2);

  const SellerType(this.apiValue);
  final int apiValue;
}

enum BookCondition {
  newBook(1),
  likeNew(2),
  good(3),
  acceptable(4);

  const BookCondition(this.apiValue);
  final int apiValue;
}

class BookCatalogFilter extends Equatable {
  const BookCatalogFilter({
    this.libraryId,
    this.categoryId,
    this.format,
    this.sellerType,
    this.condition,
    this.minPrice,
    this.maxPrice,
  });

  final String? libraryId;
  final String? categoryId;
  final ListingFormat? format;
  final SellerType? sellerType;
  final BookCondition? condition;
  final double? minPrice;
  final double? maxPrice;

  bool get hasValidPriceRange {
    if ((minPrice != null && minPrice! < 0) ||
        (maxPrice != null && maxPrice! < 0)) {
      return false;
    }
    return minPrice == null || maxPrice == null || minPrice! <= maxPrice!;
  }

  bool get isEmpty =>
      libraryId == null &&
      categoryId == null &&
      format == null &&
      sellerType == null &&
      condition == null &&
      minPrice == null &&
      maxPrice == null;

  @override
  List<Object?> get props => <Object?>[
        libraryId,
        categoryId,
        format,
        sellerType,
        condition,
        minPrice,
        maxPrice,
      ];
}
