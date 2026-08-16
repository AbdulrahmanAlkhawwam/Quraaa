import '../../../core/architecture/result.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../domain/purchases.dart';
import 'purchases_remote_data_source.dart';
import 'secure_purchase_book_data_source.dart';

class PurchasesRepositoryImpl implements PurchasesRepository {
  const PurchasesRepositoryImpl(this._remote, this._secureBooks);

  final PurchasesRemoteDataSource _remote;
  final SecurePurchaseBookDataSource _secureBooks;

  @override
  Future<Result<List<PurchasedBook>>> getLibrary({String query = ''}) =>
      _result(() => _remote.getLibrary(query: query));

  @override
  Future<Result<PurchaseBookSession>> openForReading(String purchaseId) =>
      _result(() => _secureBooks.open(purchaseId));

  @override
  Future<Result<PreparedPurchaseBook>> prepareForReading(String purchaseId) =>
      _result(() => _secureBooks.prepareForNativeReader(purchaseId));

  Future<Result<T>> _result<T>(Future<T> Function() request) async {
    try {
      return Success<T>(await request());
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<T>(failure.message, cause: failure);
    }
  }
}
