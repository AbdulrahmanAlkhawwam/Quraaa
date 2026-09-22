import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/prepared_purchase_book.dart';
import '../entities/purchase_book_session.dart';
import '../entities/purchased_book.dart';

abstract class PurchasesRepository {
  /// The user's purchases. When the network fails, falls back to the last
  /// cached list (filtered by [query]) if one exists.
  FutureEither<List<PurchasedBook>> getLibrary({String query = ''});

  FutureEither<PurchaseBookSession> openForReading(String purchaseId);

  FutureEither<PreparedPurchaseBook> prepareForReading(String purchaseId);

  FutureEither<bool> isAvailableOffline(String purchaseId);

  FutureEither<Unit> downloadForOffline(String purchaseId);
}
