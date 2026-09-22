import '../../../../core/use_cases/use_case.dart';
import '../entities/my_listing.dart';
import '../repositories/sell_book_repository.dart';

class GetMyListingsUseCase extends UseCase<List<MyListing>, String> {
  const GetMyListingsUseCase(this._repository);

  final SellBookRepository _repository;

  /// [query] filters by title; pass `''` for everything.
  @override
  FutureEither<List<MyListing>> call(String query) =>
      _repository.getMyListings(query: query);
}
