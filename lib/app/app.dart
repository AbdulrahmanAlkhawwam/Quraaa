import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../config/routes/app_router.dart';
import '../core/di/injection_container.dart';
import '../core/error_monitoring/navigation_tracker.dart';
import '../core/localization/localization_constants.dart';
import '../shared/theme/app_theme_cubit.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../shared/theme/app_theme.dart';

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
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppThemeCubit>.value(value: sl<AppThemeCubit>()),
        BlocProvider<ProfileBloc>(
          create: (BuildContext context) => sl<ProfileBloc>(),
        ),
      ],
      child: BlocBuilder<AppThemeCubit, ThemeMode>(
        builder: (BuildContext context, ThemeMode themeMode) {
          return MaterialApp.router(
            title: LocalizationConstants.appNameKey.tr(),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            routerConfig: _router,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            builder: (BuildContext context, Widget? child) {
              final Brightness iconBrightness =
                  Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark;

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: iconBrightness,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  systemNavigationBarIconBrightness: iconBrightness,
                  systemStatusBarContrastEnforced: false,
                  systemNavigationBarContrastEnforced: false,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
