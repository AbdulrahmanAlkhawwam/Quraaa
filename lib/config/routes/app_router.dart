import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/onboarding/presentation/pages/age_onboarding_page.dart';
import '../../features/onboarding/presentation/pages/gender_onboarding_page.dart';
import '../../features/onboarding/presentation/pages/interests_onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/local_explorer/presentation/pages/local_explorer_page.dart';
import '../../features/pdf_reader/presentation/pages/pdf_reader_page.dart';
import 'route_names.dart';
import 'route_resolver.dart';

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: RouteNames.splash,
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
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const GenderOnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.onboardingAge,
        builder: (context, state) => const AgeOnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.onboardingInterests,
        builder: (context, state) => const InterestsOnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.routeBridge,
        redirect: (context, state) =>
            resolveBridgeRoute(state.uri.queryParameters['route']) ??
            RouteNames.splash,
      ),
      GoRoute(
        path: RouteNames.explorer,
        builder: (context, state) => const LocalExplorerPage(),
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
    ],
  );
}

bool _isKnownRoute(String location) {
  return <String>{
    RouteNames.splash,
    RouteNames.home,
    RouteNames.auth,
    RouteNames.login,
    RouteNames.register,
    RouteNames.onboarding,
    RouteNames.onboardingAge,
    RouteNames.onboardingInterests,
    RouteNames.routeBridge,
  }.contains(location);
}
