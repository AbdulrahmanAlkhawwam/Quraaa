import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/location_permission_screen.dart';
import '../../features/auth/presentation/pages/notification_permission_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/auth/presentation/pages/auth_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/onboarding/presentation/pages/age_onboarding_page.dart';
import '../../features/onboarding/presentation/pages/gender_onboarding_page.dart';
import '../../features/onboarding/presentation/pages/interests_onboarding_page.dart';
import '../../features/search/search.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/local_explorer/presentation/pages/local_explorer_page.dart';
import '../../features/pdf_reader/presentation/pages/pdf_reader_page.dart';
import '../../shared/widgets/app_shell.dart';
import 'route_names.dart';
import 'route_resolver.dart';

GoRouter buildAppRouter({
  List<NavigatorObserver> observers = const <NavigatorObserver>[],
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteNames.splash,
    observers: observers,
    redirect: (context, state) {
      final String location = state.matchedLocation;

      if (location == RouteNames.routeBridge) {
        return resolveBridgeRoute(state.uri.queryParameters['route']) ??
            RouteNames.splash;
      }

      if (location == RouteNames.splash || _isKnownRoute(location)) {
        return null;
      }

      return RouteNames.splash;
    },
    routes: <RouteBase>[
      GoRoute(
        name: RouteNames.splash,
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: RouteNames.auth,
        path: RouteNames.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        name: RouteNames.onboarding,
        path: RouteNames.onboarding,
        builder: (context, state) => const GenderOnboardingPage(),
      ),
      GoRoute(
        name: RouteNames.onboardingAge,
        path: RouteNames.onboardingAge,
        builder: (context, state) => const AgeOnboardingPage(),
      ),
      GoRoute(
        name: RouteNames.onboardingInterests,
        path: RouteNames.onboardingInterests,
        builder: (context, state) => const InterestsOnboardingPage(),
      ),
      GoRoute(
        name: RouteNames.login,
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: RouteNames.register,
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: RouteNames.routeBridge,
        path: RouteNames.routeBridge,
        redirect: (context, state) =>
            resolveBridgeRoute(state.uri.queryParameters['route']) ??
            RouteNames.splash,
      ),
      GoRoute(
        name: RouteNames.home,
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: RouteNames.profile,
        path: RouteNames.profile,
        builder: (context, state) => AppShell(),
      ),
      GoRoute(
        name: RouteNames.pdfReaderName,
        path: RouteNames.pdfReader,
        builder: (context, state) {
          final String? path = state.uri.queryParameters['path'];
          final String? name = state.uri.queryParameters['name'];

          return PdfReaderPage(
            path: path ?? '',
            name: name ?? 'PDF',
          );
        },
      ),
      GoRoute(
        name: RouteNames.search,
        path: RouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        name: RouteNames.notificationPermission,
        path: RouteNames.notificationPermission,
        builder: (context, state) => const NotificationPermissionScreen(),
      ),
      GoRoute(
        name: RouteNames.locationPermission,
        path: RouteNames.locationPermission,
        builder: (context, state) => const LocationPermissionScreen(),
      ),
    ],
  );
}

bool _isKnownRoute(String location) {
  return <String>{
    RouteNames.splash,
    RouteNames.home,
    RouteNames.profile,
    RouteNames.search,
    RouteNames.auth,
    RouteNames.login,
    RouteNames.register,
    RouteNames.onboarding,
    RouteNames.onboardingAge,
    RouteNames.onboardingInterests,
    RouteNames.routeBridge,
    RouteNames.notificationPermission,
    RouteNames.locationPermission,
  }.contains(location);
}
