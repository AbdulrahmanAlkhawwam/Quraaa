$ErrorActionPreference = 'Stop'

$navPath = 'lib\features\home\presentation\widgets\home_bottom_nav.dart'
Set-Content -LiteralPath $navPath -Value "export '../../../../shared/widgets/primary_bottom_nav.dart';`r`n" -NoNewline

$sharedPath = 'lib\shared\shared.dart'
$shared = Get-Content -Raw -LiteralPath $sharedPath
if (-not $shared.Contains("export 'widgets/primary_bottom_nav.dart';")) {
  $shared = $shared.TrimEnd() + "`r`nexport 'widgets/primary_bottom_nav.dart';`r`n"
  Set-Content -LiteralPath $sharedPath -Value $shared -NoNewline
}

$primaryPath = 'lib\shared\widgets\primary_bottom_nav.dart'
$primary = Get-Content -Raw -LiteralPath $primaryPath
$primary = $primary.Replace("import '../../core/localization/localization_constants.dart';", "import '../../core/di/injection_container.dart';`r`nimport '../../core/error_monitoring/user_context_provider.dart';`r`nimport '../../core/localization/localization_constants.dart';")
$primary = $primary.Replace('    required this.isGuest,', '    this.isGuest,')
$primary = $primary.Replace('  final bool isGuest;', '  final bool? isGuest;')
$primary = $primary.Replace("    final Color shadowColor = context.isDark", "    final bool guest = isGuest ??`r`n        sl<UserContextProvider>().snapshot.subscriptionStatus != 'active';`r`n    final Color shadowColor = context.isDark")
$primary = $primary.Replace('    final String fourthRoute = isGuest', '    final String fourthRoute = guest')
$primary = $primary.Replace('              icon: isGuest', '              icon: guest')
$primary = $primary.Replace('              activeIcon: isGuest', '              activeIcon: guest')
$primary = $primary.Replace('              label: isGuest', '              label: guest')
Set-Content -LiteralPath $primaryPath -Value $primary -NoNewline

$diPath = 'lib\core\di\injection_container.dart'
$di = Get-Content -Raw -LiteralPath $diPath
if (-not $di.Contains("import '../network/language_interceptor.dart';")) {
  $di = $di.Replace("import '../network/connectivity_interceptor.dart';", "import '../network/connectivity_interceptor.dart';`r`nimport '../network/language_interceptor.dart';")
}
if (-not $di.Contains('registerLazySingleton<LanguageInterceptor>')) {
  $needle = "  sl.registerLazySingleton<ConnectivityInterceptor>(`r`n    () => ConnectivityInterceptor(sl<ConnectivityService>()),`r`n  );"
  $replacement = $needle + "`r`n  sl.registerLazySingleton<LanguageInterceptor>(`r`n    () => LanguageInterceptor(sl<StorageService>()),`r`n  );"
  $di = $di.Replace($needle, $replacement)
}
$di = $di.Replace("      sl<ConnectivityInterceptor>(),`r`n      sl<AuthInterceptor>(),", "      sl<ConnectivityInterceptor>(),`r`n      sl<LanguageInterceptor>(),`r`n      sl<AuthInterceptor>(),")
Set-Content -LiteralPath $diPath -Value $di -NoNewline
