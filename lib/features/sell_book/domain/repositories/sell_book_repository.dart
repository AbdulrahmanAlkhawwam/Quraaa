import '../../../../core/use_cases/use_case.dart';
import '../entities/my_listing.dart';
import '../entities/sell_book.dart';

abstract interface class SellBookRepository {
  /// Looks a book up by ISBN. Not backed by the API yet: always `Right(null)`.
  FutureEither<SellBookPreview?> findByIsbn(String isbn);

  /// Publishes the listing; `Right` carries the new listing id.
  FutureEither<String> submit(SellBookDraft draft);

  FutureEither<List<MyListing>> getMyListings({String query = ''});
}
