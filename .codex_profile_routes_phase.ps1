$ErrorActionPreference = 'Stop'

$routeNamesPath = 'lib\config\routes\route_names.dart'
$routeNames = Get-Content -Raw -LiteralPath $routeNamesPath
if (-not $routeNames.Contains('settingsPersonalInformation')) {
  $routeNames = $routeNames.Replace(
    "  static const String settings = '/settings';",
    "  static const String settings = '/settings';`r`n  static const String settingsPersonalInformation =`r`n      '/settings/personal-information';`r`n  static const String settingsLocations = '/settings/locations';"
  )
  Set-Content -LiteralPath $routeNamesPath -Value $routeNames -NoNewline
}

$routerPath = 'lib\config\routes\app_router.dart'
$router = Get-Content -Raw -LiteralPath $routerPath
if (-not $router.Contains("personal_information_screen.dart")) {
  $router = $router.Replace(
    "import '../../features/settings/presentation/pages/settings_screen.dart';",
    "import '../../features/settings/presentation/pages/settings_screen.dart';`r`nimport '../../features/settings/presentation/pages/personal_information_screen.dart';`r`nimport '../../features/profile/presentation/pages/profile_locations_screen.dart';"
  )
}
if (-not $router.Contains('name: RouteNames.settingsPersonalInformation')) {
  $settingsRoute = @'
      GoRoute(
        name: RouteNames.settings,
        path: RouteNames.settings,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 3,
          child: const SettingsScreen(),
        ),
      ),
'@
  $profileRoutes = $settingsRoute + @'
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
  $router = $router.Replace($settingsRoute, $profileRoutes)
}
$router = $router.Replace(
  '    RouteNames.settings,' + "`r`n" + '    RouteNames.settingsAccountType,',
  '    RouteNames.settings,' + "`r`n" + '    RouteNames.settingsPersonalInformation,' + "`r`n" + '    RouteNames.settingsLocations,' + "`r`n" + '    RouteNames.settingsAccountType,'
)
Set-Content -LiteralPath $routerPath -Value $router -NoNewline

$settingsViewPath = 'lib\features\settings\presentation\widgets\settings_view.dart'
$settingsView = Get-Content -Raw -LiteralPath $settingsViewPath
$navigateNeedle = @'
    if (section.action == SettingsSectionAction.navigate) {
      if (section.id == 'account_type') {
'@
$navigateReplacement = @'
    if (section.action == SettingsSectionAction.navigate) {
      if (section.id == 'my_personal_information') {
        context.pushTo(RouteNames.settingsPersonalInformation);
        return;
      }
      if (section.id == 'my_locations') {
        context.pushTo(RouteNames.settingsLocations);
        return;
      }
      if (section.id == 'account_type') {
'@
$settingsView = $settingsView.Replace($navigateNeedle, $navigateReplacement)
Set-Content -LiteralPath $settingsViewPath -Value $settingsView -NoNewline

$presentationBarrel = 'lib\features\profile\presentation\presentation.dart'
$exports = Get-Content -Raw -LiteralPath $presentationBarrel
$needed = @(
  "export 'cubit/profile_edit_cubit.dart';",
  "export 'cubit/profile_location_cubit.dart';",
  "export 'pages/profile_locations_screen.dart';"
)
foreach ($entry in $needed) {
  if (-not $exports.Contains($entry)) {
    $exports = $exports.TrimEnd() + "`r`n$entry`r`n"
  }
}
Set-Content -LiteralPath $presentationBarrel -Value $exports -NoNewline
