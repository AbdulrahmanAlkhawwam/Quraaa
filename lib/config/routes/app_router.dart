import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/otp_verification_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/change_password_screen.dart';
import '../../features/auth/presentation/pages/location_permission_screen.dart';
import '../../features/auth/presentation/pages/notification_permission_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/audio_books_screen.dart';
import '../../features/cart/presentation/pages/cart_screen.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/orders/orders.dart';
import '../../features/purchases/purchases.dart';
import '../../features/favorites/presentation/pages/favorite_books_screen.dart';
import '../../features/book_assistant/book_assistant.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/home/presentation/pages/stores_screen.dart';
import '../../features/libraries/domain/entities/library_entity.dart';
import '../../features/libraries/presentation/pages/libraries_screen.dart';
import '../../features/libraries/presentation/pages/library_details_screen.dart';
import '../../features/libraries/presentation/pages/author_details_screen.dart';
import '../../features/libraries/presentation/pages/book_details_screen.dart';
import '../../features/libraries/presentation/models/library_details_navigation_data.dart';
import '../../features/libraries/presentation/cubit/book_details_cubit.dart';
import '../../features/libraries/presentation/cubit/library_details_cubit.dart';
import '../../features/libraries/presentation/cubit/author_details_cubit.dart';
import '../../features/home/presentation/pages/user_books_screen.dart';
import '../../features/sell_book/presentation/pages/sell_book_screen.dart';
import '../../features/sell_book/presentation/pages/my_listings_screen.dart';
import '../../features/onboarding/presentation/pages/age_onboarding_page.dart';
import '../../features/onboarding/presentation/pages/gender_onboarding_page.dart';
import '../../features/onboarding/presentation/pages/interests_onboarding_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_event.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/settings/presentation/pages/personal_information_screen.dart';
import '../../features/profile/presentation/pages/profile_locations_screen.dart';
import '../../features/subscription/presentation/pages/account_type_screen.dart';
import '../../features/search/search.dart';
import '../../core/di/injection_container.dart';
import '../../core/network/session_expiry_controller.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/local_explorer/presentation/pages/explorer_history_screen.dart';
import '../../features/local_explorer/presentation/pages/local_explorer_page.dart';
import '../../features/pdf_reader/presentation/pages/pdf_reader_page.dart';
import '../../features/pdf_reader/presentation/widgets/purchased_pdf_reader_loader.dart';
import '../../features/settings/presentation/cubit/library_registration_cubit.dart';
import '../../features/settings/presentation/pages/account_type_page.dart';
import 'route_names.dart';
import 'route_resolver.dart';

GoRouter buildAppRouter({
  List<NavigatorObserver> observers = const <NavigatorObserver>[],
  GlobalKey<NavigatorState>? navigatorKey,
  required SessionExpiryController sessionExpiryController,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteNames.splash,
    observers: observers,
    refreshListenable: sessionExpiryController,
    redirect: (context, state) async {
      final String location = state.matchedLocation;

      if (sessionExpiryController.consumeSessionExpired()) {
        return location == RouteNames.login ? null : RouteNames.login;
      }

      if (location == RouteNames.cart) {
        try {
          final bool isAuthenticated =
              await sl<AuthLocalDataSource>().isAuthenticatedSession();
          if (!isAuthenticated) {
            return RouteNames.home;
          }
        } catch (_) {
          return RouteNames.home;
        }
      }

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
        path: RouteNames.checkoutSuccess,
        redirect: (context, state) => '${RouteNames.home}?checkout=success',
      ),
      GoRoute(
        path: RouteNames.checkoutCancel,
        redirect: (context, state) => RouteNames.cart,
      ),
      GoRoute(
        name: RouteNames.home,
        path: RouteNames.home,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 0,
          child: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<HomeBloc>(
                create: (BuildContext context) =>
                    sl<HomeBloc>()..add(const HomeStarted()),
              ),
              BlocProvider<CartBloc>(create: (_) => sl<CartBloc>()),
              BlocProvider<AccountOrdersCubit>(
                create: (_) => AccountOrdersCubit(
                  sl<OrdersRepository>(),
                  mode: AccountOrdersMode.purchases,
                )..load(),
              ),
            ],
            child: HomeScreen(
              showCheckoutSuccess:
                  state.uri.queryParameters['checkout'] == 'success',
            ),
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.stores,
        path: RouteNames.stores,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 1,
          child: const StoresScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.libraries,
        path: RouteNames.libraries,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 1,
          child: const LibrariesScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.libraryDetails,
        path: RouteNames.libraryDetails,
        builder: (context, state) {
          final String libraryId = state.pathParameters['libraryId']!;
          final LibraryEntity? library = state.extra as LibraryEntity?;

          return BlocProvider<LibraryDetailsCubit>(
            create: (_) => sl<LibraryDetailsCubit>(param1: libraryId),
            child: LibraryDetailsScreen(library: library),
          );
        },
      ),
      GoRoute(
        name: RouteNames.authorDetails,
        path: RouteNames.authorDetails,
        builder: (context, state) {
          final String authorId = Uri.decodeComponent(
            state.pathParameters['authorId'] ?? '',
          );
          return BlocProvider<AuthorDetailsCubit>(
            create: (_) => sl<AuthorDetailsCubit>(param1: authorId)..load(),
            child: const AuthorDetailsScreen(),
          );
        },
      ),
      GoRoute(
        name: RouteNames.bookDetails,
        path: RouteNames.bookDetails,
        builder: (context, state) {
          final String bookId = Uri.decodeComponent(
            state.pathParameters['bookId'] ?? '',
          );
          final BookDetailsNavigationData? data =
              state.extra as BookDetailsNavigationData?;
          final String listingId = data?.book.listingId.trim() ?? '';
          final String detailsId = listingId.isNotEmpty ? listingId : bookId;

          return BlocProvider<BookDetailsCubit>(
            create: (_) => sl<BookDetailsCubit>()
              ..load(detailsId: detailsId, fallbackBook: data?.book),
            child: BookDetailsScreen(bookId: bookId, data: data),
          );
        },
      ),
      GoRoute(
        name: RouteNames.userBooks,
        path: RouteNames.userBooks,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 2,
          child: const UserBooksScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.sellBook,
        path: RouteNames.sellBook,
        builder: (context, state) => const SellBookScreen(),
      ),
      GoRoute(
        name: RouteNames.audioBooks,
        path: RouteNames.audioBooks,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 3,
          child: const AudioBooksScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.cart,
        path: RouteNames.cart,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 4,
          child: CartScreen(openCheckoutOnLoad: state.extra == true),
        ),
      ),
      GoRoute(
        name: RouteNames.favorites,
        path: RouteNames.favorites,
        builder: (context, state) => const FavoriteBooksScreen(),
      ),
      GoRoute(
        name: RouteNames.bookAssistant,
        path: RouteNames.bookAssistant,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 3,
          child: BookAssistantScreen(
            data: state.extra as BookAssistantNavigationData?,
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.profile,
        path: RouteNames.profile,
        builder: (context, state) => BlocProvider<ProfileBloc>(
          create: (BuildContext context) =>
              sl<ProfileBloc>()..add(const ProfileLoadRequested()),
          child: const PersonalInformationScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.explorer,
        path: RouteNames.explorer,
        builder: (context, state) => const LocalExplorerPage(),
      ),
      GoRoute(
        name: RouteNames.pdfReaderName,
        path: RouteNames.pdfReader,
        builder: (context, state) {
          final String? path = state.uri.queryParameters['path'];
          final String? name = state.uri.queryParameters['name'];
          final String? purchaseId = state.uri.queryParameters['purchaseId'];
          final String effectivePath = path ?? '';
          final String effectiveName = name ?? 'PDF';

          if (effectivePath.isEmpty && purchaseId?.trim().isNotEmpty == true) {
            return PurchasedPdfReaderLoader(
              purchaseId: purchaseId!.trim(),
              name: effectiveName,
            );
          }

          return PdfReaderPage(
            path: effectivePath,
            name: effectiveName,
            purchaseId: purchaseId ?? '',
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
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 3,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.myOrders,
        path: RouteNames.myOrders,
        builder: (context, state) => BlocProvider<AccountOrdersCubit>(
          create: (_) => AccountOrdersCubit(
            sl<OrdersRepository>(),
            mode: AccountOrdersMode.purchases,
          )..load(),
          child: const MyOrdersScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.mySells,
        path: RouteNames.mySells,
        builder: (context, state) => BlocProvider<AccountOrdersCubit>(
          create: (_) => AccountOrdersCubit(
            sl<OrdersRepository>(),
            mode: AccountOrdersMode.sales,
          )..load(),
          child: const MySellsScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.myListings,
        path: RouteNames.myListings,
        builder: (context, state) => const MyListingsScreen(),
      ),
      GoRoute(
        name: RouteNames.purchasedBooks,
        path: RouteNames.purchasedBooks,
        builder: (context, state) => const PurchasedBooksScreen(),
      ),
      GoRoute(
        name: RouteNames.aiTextTools,
        path: RouteNames.aiTextTools,
        builder: (context, state) => const AiTextToolsScreen(),
      ),
      GoRoute(
        name: RouteNames.settingsPersonalInformation,
        path: RouteNames.settingsPersonalInformation,
        builder: (context, state) => BlocProvider<ProfileBloc>(
          create: (_) =>
              sl<ProfileBloc>()..add(const ProfileCachedLoadRequested()),
          child: const PersonalInformationScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.settingsLocations,
        path: RouteNames.settingsLocations,
        builder: (context, state) => const ProfileLocationsScreen(),
      ),
      GoRoute(
        name: RouteNames.settingsPersonalFiles,
        path: RouteNames.settingsPersonalFiles,
        builder: (context, state) => const ExplorerHistoryScreen(),
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
        name: RouteNames.forgotPassword,
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: RouteNames.resetPassword,
        path: RouteNames.resetPassword,
        builder: (context, state) {
          final String? phoneNumber = state.extra as String?;
          return ResetPasswordScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        name: RouteNames.settingsChangePassword,
        path: RouteNames.settingsChangePassword,
        builder: (context, state) => const ChangePasswordScreen(),
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
        builder: (context, state) => BlocProvider<LibraryRegistrationCubit>(
          create: (_) => sl<LibraryRegistrationCubit>(),
          child: const AccountTypePage(),
        ),
      ),
    ],
  );
}

int _lastNavRouteIndex = 0;

Page<void> _buildTabTransitionPage({
  required GoRouterState state,
  required Widget child,
  required int tabIndex,
}) {
  final int previousIndex = _lastNavRouteIndex;
  final int direction = tabIndex >= previousIndex ? 1 : -1;
  _lastNavRouteIndex = tabIndex;

  return _buildSoftTransitionPage(
    state: state,
    child: child,
    beginOffset: Offset(direction * 0.08, 0),
  );
}

Page<void> _buildSoftTransitionPage({
  required GoRouterState state,
  required Widget child,
  required Offset beginOffset,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    child: child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      final Animation<double> curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.985,
              end: 1,
            ).animate(curvedAnimation),
            child: child,
          ),
        ),
      );
    },
  );
}

bool _isKnownRoute(String location) {
  if (<String>{
    RouteNames.splash,
    RouteNames.home,
    RouteNames.profile,
    RouteNames.stores,
    RouteNames.libraries,
    RouteNames.userBooks,
    RouteNames.sellBook,
    RouteNames.audioBooks,
    RouteNames.cart,
    RouteNames.favorites,
    RouteNames.bookAssistant,
    RouteNames.aiTextTools,
    RouteNames.search,
    RouteNames.settings,
    RouteNames.myOrders,
    RouteNames.mySells,
    RouteNames.myListings,
    RouteNames.purchasedBooks,
    RouteNames.settingsPersonalInformation,
    RouteNames.settingsLocations,
    RouteNames.settingsPersonalFiles,
    RouteNames.settingsChangePassword,
    RouteNames.settingsAccountType,
    RouteNames.subscriptionAccountType,
    RouteNames.explorer,
    RouteNames.pdfReader,
    RouteNames.auth,
    RouteNames.login,
    RouteNames.register,
    RouteNames.onboarding,
    RouteNames.onboardingAge,
    RouteNames.onboardingInterests,
    RouteNames.routeBridge,
    RouteNames.checkoutSuccess,
    RouteNames.checkoutCancel,
    RouteNames.notificationPermission,
    RouteNames.locationPermission,
    RouteNames.otpVerification,
    RouteNames.forgotPassword,
    RouteNames.resetPassword,
  }.contains(location)) {
    return true;
  }

  // Library details uses a path parameter, so the actual location looks like
  // /libraries/{id} rather than the declared /libraries/:libraryId route.
  if (location.startsWith('${RouteNames.libraries}/') ||
      location.startsWith('/authors/') ||
      location.startsWith('/books/')) {
    return true;
  }

  return false;
}
