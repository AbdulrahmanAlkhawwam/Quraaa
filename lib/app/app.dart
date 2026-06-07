import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../config/routes/app_router.dart';
import '../core/localization/localization_constants.dart';
import '../shared/theme/app_theme.dart';

class QuraaaApp extends StatelessWidget {
  const QuraaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = buildAppRouter();

    return MaterialApp.router(
      title: LocalizationConstants.appNameKey.tr(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
