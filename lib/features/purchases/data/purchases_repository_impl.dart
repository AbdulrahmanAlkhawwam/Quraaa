import '../../../core/architecture/result.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../domain/purchases.dart';
import 'purchases_local_data_source.dart';
import 'purchases_remote_data_source.dart';
import 'secure_purchase_book_data_source.dart';

class PurchasesRepositoryImpl implements PurchasesRepository {
  const PurchasesRepositoryImpl(
    this._remote,
    this._local,
    this._secureBooks,
  );

  final PurchasesRemoteDataSource _remote;
  final PurchasesLocalDataSource _local;
  final SecurePurchaseBookDataSource _secureBooks;

  @override
  Future<Result<List<PurchasedBook>>> getLibrary({String query = ''}) async {
    try {
      final List<PurchasedBook> books = await _remote.getLibrary(query: query);
      if (query.trim().isEmpty) await _local.save(books);
      return Success<List<PurchasedBook>>(books);
    } catch (error) {
      if (_local.hasCache) {
        return Success<List<PurchasedBook>>(_local.load(query: query));
      }
      return _failure<List<PurchasedBook>>(error);
    }
  }

  @override
  Future<Result<PurchaseBookSession>> openForReading(String purchaseId) =>
      _result(() => _secureBooks.open(purchaseId));

  @override
  Future<Result<PreparedPurchaseBook>> prepareForReading(String purchaseId) =>
      _result(() => _secureBooks.prepareForNativeReader(purchaseId));

  @override
  Future<Result<bool>> isAvailableOffline(String purchaseId) =>
      _result(() => _secureBooks.isAvailableOffline(purchaseId));

  @override
  Future<Result<void>> downloadForOffline(String purchaseId) =>
      _result(() => _secureBooks.downloadForOffline(purchaseId));

  Future<Result<T>> _result<T>(Future<T> Function() request) async {
    try {
      return Success<T>(await request());
    } catch (error) {
      return _failure<T>(error);
    }
  }

  Result<T> _failure<T>(Object error) {
    final Failure failure = ErrorMapper.map(error);
    return ResultFailure<T>(failure.message, cause: failure);
  }
}
