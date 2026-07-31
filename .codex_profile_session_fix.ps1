$ErrorActionPreference = 'Stop'

$sessionPath = 'lib\features\auth\data\services\auth_session_service.dart'
$session = Get-Content -Raw -LiteralPath $sessionPath
if (-not $session.Contains('Future<void> Function()? afterAuthentication,')) {
  $session = $session.Replace(
    '    required UserContextProvider userContextProvider,' + "`r`n" + '  })',
    '    required UserContextProvider userContextProvider,' + "`r`n" + '    Future<void> Function()? afterAuthentication,' + "`r`n" + '  })'
  )
}
$session = $session.Replace('      );      try {', '      );' + "`r`n" + '      try {')
Set-Content -LiteralPath $sessionPath -Value $session -NoNewline

$headerPath = 'lib\features\settings\presentation\widgets\personal_information_header.dart'
$header = Get-Content -Raw -LiteralPath $headerPath
$header = [regex]::Replace(
  $header,
  "\r?\n  void _openEditProfile\(BuildContext context\) \{[\s\S]*?\r?\n  \}\r?\n\}",
  "`r`n}",
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)
Set-Content -LiteralPath $headerPath -Value $header -NoNewline

$diPath = 'lib\core\di\injection_container.dart'
$di = Get-Content -Raw -LiteralPath $diPath
if (-not $di.Contains('afterAuthentication:')) {
  $di = $di.Replace(
    '      userContextProvider: sl<UserContextProvider>(),' + "`r`n" + '    ),',
    '      userContextProvider: sl<UserContextProvider>(),' + "`r`n" + '      afterAuthentication: () =>' + "`r`n" + '          sl<ProfileBootstrapService>().refreshAfterLogin(),' + "`r`n" + '    ),'
  )
}
if (-not $di.Contains('registerLazySingleton<ProfileBootstrapService>')) {
  $anchor = '  sl.registerFactory<ProfileBloc>('
  $registration = @'
  sl.registerLazySingleton<ProfileBootstrapService>(
    () => ProfileBootstrapService(
      sl<ProfileRepository>(),
      sl<UserContextProvider>(),
    ),
  );

'@
  $di = $di.Replace($anchor, $registration + $anchor)
}
$accountPattern = "(?s)(sl\.registerLazySingleton<AccountRepository>\(\s*\(\) => AccountRepositoryImpl\(\s*sl<UserDataLocalDataSource>\(\),\s*sl<AuthLocalDataSource>\(\),\s*)sl<UserLocalDataSource>\(\)"
$di = [regex]::Replace($di, $accountPattern, '${1}sl<ProfileLocalDataSource>()', 1)
if (-not $di.Contains('registerFactoryParam<ProfileEditCubit')) {
  $anchor = '  sl.registerFactory<EditProfileBloc>(EditProfileBloc.new);'
  $registrations = $anchor + @'

  sl.registerFactoryParam<ProfileEditCubit, Profile, void>(
    (Profile profile, _) => ProfileEditCubit(
      sl<ProfileRepository>(),
      sl<UserContextProvider>(),
      profile,
    ),
  );

  sl.registerFactory<ProfileLocationCubit>(
    () => ProfileLocationCubit(sl<ProfileRepository>()),
  );
'@
  $di = $di.Replace($anchor, $registrations)
}
if (-not $di.Contains("presentation/cubit/profile_edit_cubit.dart")) {
  $di = $di.Replace(
    "import '../../features/profile/presentation/bloc/edit_profile_bloc.dart';",
    "import '../../features/profile/presentation/bloc/edit_profile_bloc.dart';`r`nimport '../../features/profile/presentation/cubit/profile_edit_cubit.dart';`r`nimport '../../features/profile/presentation/cubit/profile_location_cubit.dart';`r`nimport '../../features/profile/domain/entities/profile.dart';"
  )
}
Set-Content -LiteralPath $diPath -Value $di -NoNewline
