import '../../../../core/architecture/result.dart';
import '../entities/sell_book.dart';
import '../entities/my_listing.dart';

abstract interface class SellBookRepository {
  Future<SellBookPreview?> findByIsbn(String isbn);

  Future<Result<String>> submit(SellBookDraft draft);

  Future<Result<List<MyListing>>> getMyListings({String query = ''});
}
