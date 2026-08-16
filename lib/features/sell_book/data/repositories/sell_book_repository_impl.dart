import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sell_book.dart';
import '../../domain/entities/my_listing.dart';
import '../../domain/repositories/sell_book_repository.dart';
import '../datasources/sell_book_remote_data_source.dart';

class SellBookRepositoryImpl implements SellBookRepository {
  const SellBookRepositoryImpl(this._remote);

  final SellBookRemoteDataSource _remote;

  @override
  Future<Result<List<MyListing>>> getMyListings({String query = ''}) async {
    try {
      return Success<List<MyListing>>(
        await _remote.getMyListings(query: query),
      );
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<List<MyListing>>(failure.message, cause: failure);
    }
  }

  @override
  Future<SellBookPreview?> findByIsbn(String isbn) async => null;

  @override
  Future<Result<String>> submit(SellBookDraft draft) async {
    try {
      return Success<String>(await _remote.submitPhysicalBook(draft));
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<String>(failure.message, cause: failure);
    }
  }
}
