$ErrorActionPreference = 'Stop'

$path = 'lib\config\routes\app_router.dart'
$router = Get-Content -Raw -LiteralPath $path
if (-not $router.Contains('name: RouteNames.settingsPersonalInformation')) {
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
  $pattern = "(?m)^      GoRoute\(\r?\n        name: RouteNames\.subscriptionAccountType,"
  $match = [regex]::Match($router, $pattern)
  if (-not $match.Success) {
    throw 'Unable to locate the subscription route anchor.'
  }
  $router = $router.Insert($match.Index, $routes)
  Set-Content -LiteralPath $path -Value $router -NoNewline
}
