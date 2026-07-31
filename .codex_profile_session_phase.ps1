$ErrorActionPreference = 'Stop'

$eventPath = 'lib\features\profile\presentation\bloc\profile_event.dart'
$event = @'
import 'package:equatable/equatable.dart';

import '../../domain/entities/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads a fresh profile from the API and refreshes the cache.
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// Loads only the profile cached immediately after authentication.
class ProfileCachedLoadRequested extends ProfileEvent {
  const ProfileCachedLoadRequested();
}

/// Replaces the visible profile after a successful edit or location change.
class ProfileReplaced extends ProfileEvent {
  const ProfileReplaced(this.profile);

  final Profile profile;

  @override
  List<Object?> get props => <Object?>[profile];
}
'@
Set-Content -LiteralPath $eventPath -Value $event -NoNewline

$statePath = 'lib\features\profile\presentation\bloc\profile_state.dart'
$state = @'
import 'package:equatable/equatable.dart';

import '../../domain/entities/profile.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.loading = false,
    this.error,
    this.profile,
    this.requiresLogin = false,
  });

  final bool loading;
  final Object? error;
  final Profile? profile;
  final bool requiresLogin;

  bool get hasError => error != null;

  ProfileState copyWith({
    bool? loading,
    Object? error,
    Profile? profile,
    bool? requiresLogin,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      profile: clearProfile ? null : profile ?? this.profile,
      requiresLogin: requiresLogin ?? this.requiresLogin,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    loading,
    error,
    profile,
    requiresLogin,
  ];
}
'@
Set-Content -LiteralPath $statePath -Value $state -NoNewline

$blocPath = 'lib\features\profile\presentation\bloc\profile_bloc.dart'
$bloc = Get-Content -Raw -LiteralPath $blocPath
$bloc = $bloc.Replace("import '../../data/models/profile_model.dart';", "import '../../domain/entities/profile.dart';")
$bloc = $bloc.Replace("    on<ProfileLoadRequested>(_onLoadRequested);", "    on<ProfileLoadRequested>(_onLoadRequested);`r`n    on<ProfileCachedLoadRequested>(_onCachedLoadRequested);`r`n    on<ProfileReplaced>(`r`n      (ProfileReplaced event, Emitter<ProfileState> emit) =>`r`n          emit(state.copyWith(profile: event.profile, clearError: true)),`r`n    );")
$insertBefore = '  /// Loads the user''s profile when the device is online and the user is'
$cachedHandler = @'
  Future<void> _onCachedLoadRequested(
    ProfileCachedLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final Profile? profile = await profileRepository.getCachedProfile();
      emit(state.copyWith(loading: false, profile: profile));
    } catch (error) {
      emit(state.copyWith(loading: false, error: _mapToFailure(error)));
    }
  }

'@
if (-not $bloc.Contains('_onCachedLoadRequested(')) {
  $bloc = $bloc.Replace($insertBefore, $cachedHandler + $insertBefore)
}
$bloc = $bloc.Replace('final ProfileModel? cachedProfile =', 'final Profile? cachedProfile =')
$bloc = $bloc.Replace('final ProfileModel profile = await profileRepository.getMyProfile();', 'final Profile profile = await profileRepository.getMyProfile();')
$bloc = $bloc.Replace("      await profileLocalDataSource.cacheProfile(profile);`r`n", '')
Set-Content -LiteralPath $blocPath -Value $bloc -NoNewline

$sessionPath = 'lib\features\auth\data\services\auth_session_service.dart'
$session = Get-Content -Raw -LiteralPath $sessionPath
$session = $session.Replace("    required UserContextProvider userContextProvider,`r`n  })", "    required UserContextProvider userContextProvider,`r`n    Future<void> Function()? afterAuthentication,`r`n  })")
$session = $session.Replace("       _userContextProvider = userContextProvider;", "       _userContextProvider = userContextProvider,`r`n       _afterAuthentication = afterAuthentication;")
$session = $session.Replace("  final UserContextProvider _userContextProvider;", "  final UserContextProvider _userContextProvider;`r`n  final Future<void> Function()? _afterAuthentication;")
$markNeedle = @'
      await _authLocalDataSource.markAuthenticatedSession(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
        accessTokenExpiration: user.accessTokenExpiration,
      );
'@
$markReplacement = $markNeedle + @'
      try {
        await _afterAuthentication?.call();
      } catch (_) {
        // Profile bootstrapping must never turn a valid login into a failure.
      }
'@
$session = $session.Replace($markNeedle, $markReplacement)
Set-Content -LiteralPath $sessionPath -Value $session -NoNewline

$accountPath = 'lib\features\account\data\repositories\account_repository_impl.dart'
$account = @'
import '../../../../config/env/env.dart';
import '../../../auth/auth.dart';
import '../../../profile/profile.dart';
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
'@
Set-Content -LiteralPath $accountPath -Value $account -NoNewline

$diPath = 'lib\core\di\injection_container.dart'
$di = Get-Content -Raw -LiteralPath $diPath
if (-not $di.Contains("profile_bootstrap_service.dart")) {
  $di = $di.Replace("import '../../features/profile/data/repositories/profile_repository_impl.dart';", "import '../../features/profile/data/repositories/profile_repository_impl.dart';`r`nimport '../../features/profile/data/services/profile_bootstrap_service.dart';")
}
$di = $di.Replace("      userContextProvider: sl<UserContextProvider>(),`r`n    ),", "      userContextProvider: sl<UserContextProvider>(),`r`n      afterAuthentication: () =>`r`n          sl<ProfileBootstrapService>().refreshAfterLogin(),`r`n    ),")
$di = $di.Replace("    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),", "    () => ProfileRepositoryImpl(`r`n      sl<ProfileRemoteDataSource>(),`r`n      sl<ProfileLocalDataSource>(),`r`n    ),")
if (-not $di.Contains('registerLazySingleton<ProfileBootstrapService>')) {
  $profileRepoRegistration = @'
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      sl<ProfileRemoteDataSource>(),
      sl<ProfileLocalDataSource>(),
    ),
  );
'@
  $withBootstrap = $profileRepoRegistration + @'

  sl.registerLazySingleton<ProfileBootstrapService>(
    () => ProfileBootstrapService(
      sl<ProfileRepository>(),
      sl<UserContextProvider>(),
    ),
  );
'@
  $di = $di.Replace($profileRepoRegistration, $withBootstrap)
}
$di = $di.Replace("      sl<UserLocalDataSource>(),`r`n    ),`r`n  );`r`n`r`n  sl.registerFactory<LoadAccountUserSnapshotUseCase>", "      sl<ProfileLocalDataSource>(),`r`n    ),`r`n  );`r`n`r`n  sl.registerFactory<LoadAccountUserSnapshotUseCase>")
Set-Content -LiteralPath $diPath -Value $di -NoNewline
