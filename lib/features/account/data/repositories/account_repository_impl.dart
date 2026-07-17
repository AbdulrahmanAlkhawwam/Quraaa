import '../../domain/entities/account_user_snapshot.dart';
import '../../domain/repositories/account_repository.dart';
import '../user_data_local_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._localDataSource);

  final UserDataLocalDataSource _localDataSource;

  @override
  Future<AccountUserSnapshot> loadUserSnapshot() async {
    final UserDataSnapshot snapshot = await _localDataSource.load();
    return AccountUserSnapshot(
      fullName: snapshot.fullName,
      profileImage: snapshot.profileImage,
    );
  }
}