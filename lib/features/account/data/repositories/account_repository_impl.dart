import '../../../../config/env/env.dart';
import '../../../auth/auth.dart';
import '../../../profile/data/datasources/profile_local_data_source.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/account_user_snapshot.dart';
import '../../domain/repositories/account_repository.dart';
import '../user_data_local_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(
    this._localDataSource,
    this._authLocalDataSource,
    this._profileLocalDataSource,
  );

  final UserDataLocalDataSource _localDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final ProfileLocalDataSource _profileLocalDataSource;

  @override
  Future<AccountUserSnapshot> loadUserSnapshot() async {
    final UserDataSnapshot localSnapshot = await _localDataSource.load();
    final bool isAuthenticated = await _authLocalDataSource
        .isAuthenticatedSession();
    if (!isAuthenticated) {
      return AccountUserSnapshot(
        fullName: Env.appName,
        profileImage: localSnapshot.profileImage,
      );
    }

    final Profile? profile = await _profileLocalDataSource.getCachedProfile();
    final String fullName = profile?.fullName.trim() ?? '';
    return AccountUserSnapshot(
      fullName: fullName.isEmpty ? Env.appName : fullName,
      profileImage: profile?.profileImageUrl ?? localSnapshot.profileImage,
    );
  }
}
