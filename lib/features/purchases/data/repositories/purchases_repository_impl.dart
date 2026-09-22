import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/prepared_purchase_book.dart';
import '../../domain/entities/purchase_book_session.dart';
import '../../domain/entities/purchased_book.dart';
import '../../domain/repositories/purchases_repository.dart';
import '../data_sources/purchases_local_data_source.dart';
import '../data_sources/purchases_remote_data_source.dart';
import '../data_sources/secure_purchase_book_data_source.dart';
import '../models/purchased_book_model.dart';

class PurchasesRepositoryImpl implements PurchasesRepository {
  const PurchasesRepositoryImpl(this._remote, this._local, this._secureBooks);

  final PurchasesRemoteDataSource _remote;
  final PurchasesLocalDataSource _local;
  final SecurePurchaseBookDataSource _secureBooks;

  @override
  FutureEither<List<PurchasedBook>> getLibrary({String query = ''}) async {
    try {
      final List<PurchasedBookModel> books = await _remote.getLibrary(
        query: query,
      );
      // Only the unfiltered list is cached, so a search never shrinks it.
      if (query.trim().isEmpty) await _local.save(books);
      return Right(_toEntities(books));
    } catch (error) {
      if (_local.hasCache) return Right(_toEntities(_local.load(query: query)));
      return Left(ErrorMapper.map(error));
    }
  }

  List<PurchasedBook> _toEntities(List<PurchasedBookModel> models) =>
      models.map((PurchasedBookModel m) => m.toEntity()).toList(growable: false);

  @override
  FutureEither<PurchaseBookSession> openForReading(String purchaseId) =>
      _guard(() => _secureBooks.open(purchaseId));

  @override
  FutureEither<PreparedPurchaseBook> prepareForReading(String purchaseId) =>
      _guard(() => _secureBooks.prepareForNativeReader(purchaseId));

  @override
  FutureEither<bool> isAvailableOffline(String purchaseId) =>
      _guard(() => _secureBooks.isAvailableOffline(purchaseId));

  @override
  FutureEither<Unit> downloadForOffline(String purchaseId) => _guard(() async {
    await _secureBooks.downloadForOffline(purchaseId);
    return unit;
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}
