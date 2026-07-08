import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/otp_verification_screen.dart';
import '../../features/auth/presentation/pages/location_permission_screen.dart';
import '../../features/auth/presentation/pages/notification_permission_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/home/presentation/pages/audio_books_screen.dart';
import '../../features/cart/presentation/pages/cart_screen.dart';
import '../../features/book_assistant/book_assistant.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/home/presentation/pages/stores_screen.dart';
import '../../features/home/presentation/pages/user_books_screen.dart';
import '../../features/onboarding/presentation/pages/age_onboarding_page.dart';
import '../../features/onboarding/presentation/pages/gender_onboarding_page.dart';
import '../../features/onboarding/presentation/pages/interests_onboarding_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_event.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/subscription/presentation/pages/account_type_screen.dart';
import '../../features/search/search.dart';
import '../../core/connectivity/connection_status.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../core/di/injection_container.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/pdf_reader/presentation/pages/pdf_reader_page.dart';
import '../../shared/widgets/app_shell.dart';
import '../../features/settings/presentation/pages/account_type_page.dart';
import 'route_names.dart';
import 'route_resolver.dart';

GoRouter buildAppRouter({
  List<NavigatorObserver> observers = const <NavigatorObserver>[],
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteNames.bookAssistant,
    observers: observers,
    redirect: (context, state) async {
      final String location = state.matchedLocation;

      if (location == RouteNames.routeBridge) {
        return resolveBridgeRoute(state.uri.queryParameters['route']) ??
            RouteNames.splash;
      }

      if (_isOnlineOnlyRoute(location)) {
        final ConnectionStatus status =
            await sl<ConnectivityService>().currentStatus();
        if (status == ConnectionStatus.disconnected) {
          return RouteNames.auth;
        }
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
        builder: (context, state) => const LandingPage(),
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
        name: RouteNames.stores,
        path: RouteNames.stores,
        builder: (context, state) => const StoresScreen(),
      ),
      GoRoute(
        name: RouteNames.userBooks,
        path: RouteNames.userBooks,
        builder: (context, state) => const UserBooksScreen(),
      ),
      GoRoute(
        name: RouteNames.audioBooks,
        path: RouteNames.audioBooks,
        builder: (context, state) => const AudioBooksScreen(),
      ),
      GoRoute(
        name: RouteNames.cart,
        path: RouteNames.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        name: RouteNames.bookAssistant,
        path: RouteNames.bookAssistant,
        builder: (context, state) => const BookAssistantScreen(),
      ),
      GoRoute(
        name: RouteNames.profile,
        path: RouteNames.profile,
        builder: (context, state) => BlocProvider<ProfileBloc>(
          create: (BuildContext context) =>
          sl<ProfileBloc>()..add(const ProfileLoadRequested()),
          child: const AppShell(),
        ),
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
        name: RouteNames.settings,
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        name: RouteNames.subscriptionAccountType,
        path: RouteNames.subscriptionAccountType,
        builder: (context, state) => const AccountTypeScreen(),
      ),
      GoRoute(
        name: RouteNames.otpVerification,
        path: RouteNames.otpVerification,
        builder: (context, state) {
          final String? phoneNumber = state.extra as String?;
          return OtpVerificationScreen(phoneNumber: phoneNumber);
        },
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
      GoRoute(
        path: RouteNames.settingsAccountType,
        builder: (context, state) => const AccountTypePage(),
      ),
    ],
  );
}

bool _isKnownRoute(String location) {
  return <String>{
    RouteNames.splash,
    RouteNames.home,
    RouteNames.profile,
    RouteNames.stores,
    RouteNames.userBooks,
    RouteNames.audioBooks,
    RouteNames.cart,
    RouteNames.bookAssistant,
    RouteNames.search,
    RouteNames.settings,
    RouteNames.settingsAccountType,
    RouteNames.subscriptionAccountType,
    RouteNames.auth,
    RouteNames.login,
    RouteNames.register,
    RouteNames.onboarding,
    RouteNames.onboardingAge,
    RouteNames.onboardingInterests,
    RouteNames.routeBridge,
    RouteNames.notificationPermission,
    RouteNames.locationPermission,
    RouteNames.otpVerification,
  }.contains(location);
}

bool _isOnlineOnlyRoute(String location) {
  return location == RouteNames.register ||
      location == RouteNames.otpVerification;
}

