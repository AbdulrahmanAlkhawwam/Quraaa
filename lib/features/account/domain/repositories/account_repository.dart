import '../../../../core/use_cases/use_case.dart';
import '../entities/account_user_snapshot.dart';

abstract class AccountRepository {
  /// Name and avatar for the account header: the cached profile for a signed
  /// in user, the app name and local avatar for a guest.
  FutureEither<AccountUserSnapshot> loadUserSnapshot();
}
