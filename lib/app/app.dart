import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../config/routes/app_router.dart';
import '../core/di/injection_container.dart';
import '../core/error_monitoring/navigation_tracker.dart';
import '../core/localization/localization_constants.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/dev_debug_overlay.dart';

class QuraaaApp extends StatefulWidget {
  const QuraaaApp({super.key});

  @override
  State<QuraaaApp> createState() => _QuraaaAppState();
}

class _QuraaaAppState extends State<QuraaaApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter _router = buildAppRouter(
    navigatorKey: _navigatorKey,
    observers: <NavigatorObserver>[
      sl<NavigationTracker>().observer,
    ],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lockOrientationIfPhone();
    });
  }

  Future<void> _lockOrientationIfPhone() async {
    final Size size = MediaQuery.sizeOf(context);
    final double shortestSide = size.shortestSide;
    if (shortestSide < 600) {
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (BuildContext context) => sl<ProfileBloc>(),
      child: MaterialApp.router(
        title: LocalizationConstants.appNameKey.tr(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: _router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            children: <Widget>[
              child!,
              DevDebugOverlay(navigatorKey: _navigatorKey),
            ],
          );
        },
      ),
    );
  }
}
