import '../entities/account_user_snapshot.dart';

abstract class AccountRepository {
  Future<AccountUserSnapshot> loadUserSnapshot();
}