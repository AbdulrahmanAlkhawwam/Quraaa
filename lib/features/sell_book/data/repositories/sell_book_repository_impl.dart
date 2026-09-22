import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/my_listing.dart';
import '../../domain/entities/sell_book.dart';
import '../../domain/repositories/sell_book_repository.dart';
import '../data_sources/sell_book_remote_data_source.dart';

class SellBookRepositoryImpl implements SellBookRepository {
  const SellBookRepositoryImpl(this._remote);

  final SellBookRemoteDataSource _remote;

  @override
  FutureEither<List<MyListing>> getMyListings({String query = ''}) =>
      _guard(() => _remote.getMyListings(query: query));

  @override
  FutureEither<SellBookPreview?> findByIsbn(String isbn) async =>
      const Right(null);

  @override
  FutureEither<String> submit(SellBookDraft draft) =>
      _guard(() => _remote.submitPhysicalBook(draft));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}
