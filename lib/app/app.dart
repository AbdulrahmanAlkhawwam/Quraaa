import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/routes/app_router.dart';
import '../core/di/injection_container.dart';
import '../core/error_monitoring/navigation_tracker.dart';
import '../core/localization/localization_constants.dart';
import '../shared/theme/app_theme.dart';

class QuraaaApp extends StatefulWidget {
  const QuraaaApp({super.key});

  @override
  State<QuraaaApp> createState() => _QuraaaAppState();
}

class _QuraaaAppState extends State<QuraaaApp> {
  late final GoRouter _router = buildAppRouter(
    observers: <NavigatorObserver>[
      sl<NavigationTracker>().observer,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: LocalizationConstants.appNameKey.tr(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
