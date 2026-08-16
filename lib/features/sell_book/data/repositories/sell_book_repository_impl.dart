import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sell_book.dart';
import '../../domain/repositories/sell_book_repository.dart';
import '../datasources/sell_book_remote_data_source.dart';

class SellBookRepositoryImpl implements SellBookRepository {
  const SellBookRepositoryImpl(this._remote);

  final SellBookRemoteDataSource _remote;

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
