import 'package:fpdart/fpdart.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../../auth/domain/repositories/auth_session_repository.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/account_user_snapshot.dart';
import '../../domain/repositories/account_repository.dart';
import '../data_sources/user_data_local_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(
    this._localDataSource,
    this._authSession,
    this._profileRepository,
  );

  final UserDataLocalDataSource _localDataSource;
  final AuthSessionRepository _authSession;
  final ProfileRepository _profileRepository;

  @override
  FutureEither<AccountUserSnapshot> loadUserSnapshot() async {
    try {
      final UserDataSnapshot localSnapshot = await _localDataSource.load();
      if (!await _authSession.isAuthenticatedSession()) {
        return Right(
          AccountUserSnapshot(
            fullName: AppConfig.appName,
            profileImage: localSnapshot.profileImage,
          ),
        );
      }

      // A missing or unreadable cached profile falls back to the app name and
      // local avatar, exactly like a profile that was never cached.
      final Profile? profile = (await _profileRepository.getCachedProfile())
          .getOrElse((_) => null);
      final String fullName = profile?.fullName.trim() ?? '';
      return Right(
        AccountUserSnapshot(
          fullName: fullName.isEmpty ? AppConfig.appName : fullName,
          profileImage: profile?.profileImageUrl ?? localSnapshot.profileImage,
        ),
      );
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}
