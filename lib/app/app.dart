import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/routes/app_router.dart';
import '../shared/theme/app_theme.dart';

class QuraaaApp extends StatelessWidget {
  const QuraaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = buildAppRouter();

    return MaterialApp.router(
      title: 'Quraaa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
