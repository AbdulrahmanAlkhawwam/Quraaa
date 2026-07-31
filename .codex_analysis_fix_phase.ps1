$ErrorActionPreference = 'Stop'

$languagePath = 'lib\core\network\language_interceptor.dart'
$language = Get-Content -Raw -LiteralPath $languagePath
$language = $language.Replace("options.headers.putIfAbsent('Accept-Language', _currentLanguage);", "options.headers.putIfAbsent('Accept-Language', () => _currentLanguage);")
Set-Content -LiteralPath $languagePath -Value $language -NoNewline

$httpPath = 'lib\core\network\http_helper.dart'
$http = Get-Content -Raw -LiteralPath $httpPath
if (-not $http.Contains('Future<Response<dynamic>> put(')) {
  $anchor = '  static Dio buildDio(List<Interceptor> interceptors) {'
  $methods = @'
  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.put<dynamic>(path, data: data, options: options);
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.delete<dynamic>(path, data: data, options: options);
  }

'@
  $http = $http.Replace($anchor, $methods + $anchor)
  Set-Content -LiteralPath $httpPath -Value $http -NoNewline
}

$sessionPath = 'lib\features\auth\data\services\auth_session_service.dart'
$session = Get-Content -Raw -LiteralPath $sessionPath
if (-not $session.Contains('Future<void> Function()? afterAuthentication,')) {
  $session = $session.Replace(
    "    required UserContextProvider userContextProvider,`n  })",
    "    required UserContextProvider userContextProvider,`n    Future<void> Function()? afterAuthentication,`n  })"
  )
  Set-Content -LiteralPath $sessionPath -Value $session -NoNewline
}

$diPath = 'lib\core\di\injection_container.dart'
$di = Get-Content -Raw -LiteralPath $diPath
if (-not $di.Contains('afterAuthentication:')) {
  $di = $di.Replace(
    "      userContextProvider: sl<UserContextProvider>(),`n    ),",
    "      userContextProvider: sl<UserContextProvider>(),`n      afterAuthentication: () =>`n          sl<ProfileBootstrapService>().refreshAfterLogin(),`n    ),"
  )
}
if (-not $di.Contains('registerLazySingleton<LanguageInterceptor>')) {
  $anchor = @'
  sl.registerLazySingleton<ConnectivityInterceptor>(
    () => ConnectivityInterceptor(sl<ConnectivityService>()),
  );
'@
  $registration = $anchor + @'
  sl.registerLazySingleton<LanguageInterceptor>(
    () => LanguageInterceptor(sl<StorageService>()),
  );
'@
  $di = $di.Replace($anchor, $registration)
}
if (-not $di.Contains('sl<LanguageInterceptor>()')) {
  $di = $di.Replace(
    "      sl<ConnectivityInterceptor>(),`n      sl<AuthInterceptor>(),",
    "      sl<ConnectivityInterceptor>(),`n      sl<LanguageInterceptor>(),`n      sl<AuthInterceptor>(),"
  )
}
Set-Content -LiteralPath $diPath -Value $di -NoNewline

$navPath = 'lib\shared\widgets\primary_bottom_nav.dart'
$nav = Get-Content -Raw -LiteralPath $navPath
$nav = $nav.Replace("import '../theme/app_spacing.dart';`n", '')
$nav = $nav.Replace(
  'minimum: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 12),',
  'minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),'
)
Set-Content -LiteralPath $navPath -Value $nav -NoNewline

$locationPath = 'lib\features\profile\presentation\pages\profile_locations_screen.dart'
$location = Get-Content -Raw -LiteralPath $locationPath
$location = $location.Replace(
  'message: Message(' + "`n" + '              value:',
  "message: Message(`n              title: '',`n              value:"
)
Set-Content -LiteralPath $locationPath -Value $location -NoNewline

$routerPath = 'lib\config\routes\app_router.dart'
$router = Get-Content -Raw -LiteralPath $routerPath
if (-not $router.Contains('name: RouteNames.settingsPersonalInformation')) {
  $anchor = @'
      GoRoute(
        name: RouteNames.subscriptionAccountType,
'@
  $routes = @'
      GoRoute(
        name: RouteNames.settingsPersonalInformation,
        path: RouteNames.settingsPersonalInformation,
        builder: (context, state) => BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>()
            ..add(const ProfileCachedLoadRequested()),
          child: const PersonalInformationScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.settingsLocations,
        path: RouteNames.settingsLocations,
        builder: (context, state) => const ProfileLocationsScreen(),
      ),
'@
  $router = $router.Replace($anchor, $routes + $anchor)
}
Set-Content -LiteralPath $routerPath -Value $router -NoNewline

$shellPath = 'lib\shared\widgets\app_shell.dart'
$shell = Get-Content -Raw -LiteralPath $shellPath
if (-not $shell.Contains("profile/domain/entities/profile.dart")) {
  $shell = $shell.Replace(
    "import '../../features/profile/data/models/profile_model.dart';",
    "import '../../features/profile/domain/entities/profile.dart';"
  )
}
$shell = $shell.Replace('ProfileModel? profile', 'Profile? profile')
$shell = $shell.Replace('final ProfileModel? profile =', 'final Profile? profile =')
Set-Content -LiteralPath $shellPath -Value $shell -NoNewline

$testPath = 'test\features\account\data\repositories\account_repository_impl_test.dart'
$test = Get-Content -Raw -LiteralPath $testPath
if (-not $test.Contains("features/profile/profile.dart")) {
  $test = $test.Replace(
    "import 'package:quraaa/features/auth/auth.dart';",
    "import 'package:quraaa/features/auth/auth.dart';`nimport 'package:quraaa/features/profile/profile.dart';"
  )
}
$test = $test.Replace('_MockUserLocalDataSource', '_MockProfileLocalDataSource')
$test = $test.Replace('implements UserLocalDataSource', 'implements ProfileLocalDataSource')
$test = $test.Replace('userLocalDataSource', 'profileLocalDataSource')
$test = $test.Replace(
  "const UserModel(firstName: 'Maya', lastName: 'Haddad')",
  "const ProfileModel(firstName: 'Maya', lastName: 'Haddad')"
)
$test = $test.Replace('.getUser()', '.getCachedProfile()')
Set-Content -LiteralPath $testPath -Value $test -NoNewline
