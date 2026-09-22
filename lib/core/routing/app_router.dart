import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screen/otp_verification_screen.dart';
import '../../features/auth/presentation/screen/forgot_password_screen.dart';
import '../../features/auth/presentation/screen/reset_password_screen.dart';
import '../../features/auth/presentation/screen/change_password_screen.dart';
import '../../features/auth/presentation/screen/location_permission_screen.dart';
import '../../features/auth/presentation/screen/notification_permission_screen.dart';
import '../../features/home/presentation/screen/home_screen.dart';
import '../../features/home/presentation/logic/home_bloc.dart';
import '../../features/home/presentation/screen/audio_books_screen.dart';
import '../../features/cart/presentation/screen/cart_screen.dart';
import '../../features/cart/presentation/logic/cart_bloc.dart';
import '../../features/orders/orders.dart';
import '../../features/purchases/purchases.dart';
import '../../features/favorites/presentation/screen/favorite_books_screen.dart';
import '../../features/book_assistant/book_assistant.dart';
import '../../features/auth/presentation/screen/landing_screen.dart';
import '../../features/auth/presentation/screen/login_screen.dart';
import '../../features/auth/presentation/screen/register_screen.dart';
import '../../features/auth/data/data_sources/auth_local_data_source.dart';
import '../../features/home/presentation/screen/stores_screen.dart';
import '../../features/libraries/domain/entities/library_entity.dart';
import '../../features/libraries/presentation/screen/libraries_screen.dart';
import '../../features/libraries/presentation/screen/library_details_screen.dart';
import '../../features/libraries/presentation/screen/author_details_screen.dart';
import '../../features/libraries/presentation/screen/book_details_screen.dart';
import '../../features/libraries/presentation/models/library_details_navigation_data.dart';
import '../../features/libraries/presentation/logic/book_details_cubit.dart';
import '../../features/libraries/presentation/logic/library_details_cubit.dart';
import '../../features/libraries/presentation/logic/author_details_cubit.dart';
import '../../features/home/presentation/screen/user_books_screen.dart';
import '../../features/sell_book/presentation/screen/sell_book_screen.dart';
import '../../features/sell_book/presentation/screen/my_listings_screen.dart';
import '../../features/onboarding/presentation/screen/age_onboarding_screen.dart';
import '../../features/onboarding/presentation/screen/gender_onboarding_screen.dart';
import '../../features/onboarding/presentation/screen/interests_onboarding_screen.dart';
import '../../features/profile/presentation/logic/profile_bloc.dart';
import '../../features/profile/presentation/logic/profile_event.dart';
import '../../features/settings/presentation/screen/settings_screen.dart';
import '../../features/settings/presentation/screen/personal_information_screen.dart';
import '../../features/profile/presentation/screen/profile_locations_screen.dart';
import '../../features/subscription/presentation/screen/account_type_screen.dart';
import '../../features/search/search.dart';
import '../di/injection_container.dart';
import '../network/session_expiry_controller.dart';
import '../../features/splash/presentation/screen/splash_screen.dart';
import '../../features/local_explorer/presentation/screen/explorer_history_screen.dart';
import '../../features/local_explorer/presentation/screen/local_explorer_screen.dart';
import '../../features/pdf_reader/presentation/screen/pdf_reader_screen.dart';
import '../../features/pdf_reader/presentation/widget/purchased_pdf_reader_loader.dart';
import '../../features/settings/presentation/logic/library_registration_cubit.dart';
import '../../features/settings/presentation/screen/settings_account_type_screen.dart';
import '../constants/app_routes.dart';
import 'route_resolver.dart';

GoRouter buildAppRouter({
  List<NavigatorObserver> observers = const <NavigatorObserver>[],
  GlobalKey<NavigatorState>? navigatorKey,
  required SessionExpiryController sessionExpiryController,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    observers: observers,
    refreshListenable: sessionExpiryController,
    redirect: (context, state) async {
      final String location = state.matchedLocation;

      if (sessionExpiryController.consumeSessionExpired()) {
        return location == AppRoutes.login ? null : AppRoutes.login;
      }

      if (location == AppRoutes.cart) {
        try {
          final bool isAuthenticated =
              await sl<AuthLocalDataSource>().isAuthenticatedSession();
          if (!isAuthenticated) {
            return AppRoutes.home;
          }
        } catch (_) {
          return AppRoutes.home;
        }
      }

      if (location == AppRoutes.routeBridge) {
        return resolveBridgeRoute(state.uri.queryParameters['route']) ??
            AppRoutes.splash;
      }

      if (location == AppRoutes.splash || _isKnownRoute(location)) {
        return null;
      }

      return AppRoutes.splash;
    },
    routes: <RouteBase>[
      GoRoute(
        name: AppRoutes.splash,
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.auth,
        path: AppRoutes.auth,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        name: AppRoutes.onboarding,
        path: AppRoutes.onboarding,
        builder: (context, state) => const GenderOnboardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.onboardingAge,
        path: AppRoutes.onboardingAge,
        builder: (context, state) => const AgeOnboardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.onboardingInterests,
        path: AppRoutes.onboardingInterests,
        builder: (context, state) => const InterestsOnboardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: AppRoutes.register,
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: AppRoutes.routeBridge,
        path: AppRoutes.routeBridge,
        redirect: (context, state) =>
            resolveBridgeRoute(state.uri.queryParameters['route']) ??
            AppRoutes.splash,
      ),
      GoRoute(
        path: AppRoutes.checkoutSuccess,
        redirect: (context, state) => AppRoutes.cart,
      ),
      GoRoute(
        path: AppRoutes.checkoutCancel,
        redirect: (context, state) => AppRoutes.cart,
      ),
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.home,
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
              showCheckoutSuccess: state.extra == true,
            ),
          ),
        ),
      ),
      GoRoute(
        name: AppRoutes.stores,
        path: AppRoutes.stores,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 1,
          child: const StoresScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.libraries,
        path: AppRoutes.libraries,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 1,
          child: const LibrariesScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.libraryDetails,
        path: AppRoutes.libraryDetails,
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
        name: AppRoutes.authorDetails,
        path: AppRoutes.authorDetails,
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
        name: AppRoutes.bookDetails,
        path: AppRoutes.bookDetails,
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
        name: AppRoutes.userBooks,
        path: AppRoutes.userBooks,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 2,
          child: const UserBooksScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.sellBook,
        path: AppRoutes.sellBook,
        builder: (context, state) => const SellBookScreen(),
      ),
      GoRoute(
        name: AppRoutes.audioBooks,
        path: AppRoutes.audioBooks,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 3,
          child: const AudioBooksScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.cart,
        path: AppRoutes.cart,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 4,
          child: CartScreen(openCheckoutOnLoad: state.extra == true),
        ),
      ),
      GoRoute(
        name: AppRoutes.favorites,
        path: AppRoutes.favorites,
        builder: (context, state) => const FavoriteBooksScreen(),
      ),
      GoRoute(
        name: AppRoutes.bookAssistant,
        path: AppRoutes.bookAssistant,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 3,
          child: BookAssistantScreen(
            data: state.extra as BookAssistantNavigationData?,
          ),
        ),
      ),
      GoRoute(
        name: AppRoutes.profile,
        path: AppRoutes.profile,
        builder: (context, state) => BlocProvider<ProfileBloc>(
          create: (BuildContext context) =>
              sl<ProfileBloc>()..add(const ProfileLoadRequested()),
          child: const PersonalInformationScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.explorer,
        path: AppRoutes.explorer,
        builder: (context, state) => const LocalExplorerScreen(),
      ),
      GoRoute(
        name: AppRoutes.pdfReaderName,
        path: AppRoutes.pdfReader,
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

          return PdfReaderScreen(
            path: effectivePath,
            name: effectiveName,
            purchaseId: purchaseId ?? '',
          );
        },
      ),
      GoRoute(
        name: AppRoutes.search,
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        name: AppRoutes.settings,
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _buildTabTransitionPage(
          state: state,
          tabIndex: 3,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.myOrders,
        path: AppRoutes.myOrders,
        builder: (context, state) => BlocProvider<AccountOrdersCubit>(
          create: (_) => AccountOrdersCubit(
            sl<OrdersRepository>(),
            mode: AccountOrdersMode.purchases,
          )..load(),
          child: const MyOrdersScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.mySells,
        path: AppRoutes.mySells,
        builder: (context, state) => BlocProvider<AccountOrdersCubit>(
          create: (_) => AccountOrdersCubit(
            sl<OrdersRepository>(),
            mode: AccountOrdersMode.sales,
          )..load(),
          child: const MySellsScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.myListings,
        path: AppRoutes.myListings,
        builder: (context, state) => const MyListingsScreen(),
      ),
      GoRoute(
        name: AppRoutes.purchasedBooks,
        path: AppRoutes.purchasedBooks,
        builder: (context, state) => const PurchasedBooksScreen(),
      ),
      GoRoute(
        name: AppRoutes.aiTextTools,
        path: AppRoutes.aiTextTools,
        builder: (context, state) => const AiTextToolsScreen(),
      ),
      GoRoute(
        name: AppRoutes.settingsPersonalInformation,
        path: AppRoutes.settingsPersonalInformation,
        builder: (context, state) => BlocProvider<ProfileBloc>(
          create: (_) =>
              sl<ProfileBloc>()..add(const ProfileCachedLoadRequested()),
          child: const PersonalInformationScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.settingsLocations,
        path: AppRoutes.settingsLocations,
        builder: (context, state) => const ProfileLocationsScreen(),
      ),
      GoRoute(
        name: AppRoutes.settingsPersonalFiles,
        path: AppRoutes.settingsPersonalFiles,
        builder: (context, state) => const ExplorerHistoryScreen(),
      ),
      GoRoute(
        name: AppRoutes.subscriptionAccountType,
        path: AppRoutes.subscriptionAccountType,
        builder: (context, state) => const AccountTypeScreen(),
      ),
      GoRoute(
        name: AppRoutes.otpVerification,
        path: AppRoutes.otpVerification,
        builder: (context, state) {
          final String? phoneNumber = state.extra as String?;
          return OtpVerificationScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        name: AppRoutes.forgotPassword,
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: AppRoutes.resetPassword,
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final String? phoneNumber = state.extra as String?;
          return ResetPasswordScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        name: AppRoutes.settingsChangePassword,
        path: AppRoutes.settingsChangePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        name: AppRoutes.notificationPermission,
        path: AppRoutes.notificationPermission,
        builder: (context, state) => const NotificationPermissionScreen(),
      ),
      GoRoute(
        name: AppRoutes.locationPermission,
        path: AppRoutes.locationPermission,
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsAccountType,
        builder: (context, state) => BlocProvider<LibraryRegistrationCubit>(
          create: (_) => sl<LibraryRegistrationCubit>(),
          child: const SettingsAccountTypeScreen(),
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
    AppRoutes.splash,
    AppRoutes.home,
    AppRoutes.profile,
    AppRoutes.stores,
    AppRoutes.libraries,
    AppRoutes.userBooks,
    AppRoutes.sellBook,
    AppRoutes.audioBooks,
    AppRoutes.cart,
    AppRoutes.favorites,
    AppRoutes.bookAssistant,
    AppRoutes.aiTextTools,
    AppRoutes.search,
    AppRoutes.settings,
    AppRoutes.myOrders,
    AppRoutes.mySells,
    AppRoutes.myListings,
    AppRoutes.purchasedBooks,
    AppRoutes.settingsPersonalInformation,
    AppRoutes.settingsLocations,
    AppRoutes.settingsPersonalFiles,
    AppRoutes.settingsChangePassword,
    AppRoutes.settingsAccountType,
    AppRoutes.subscriptionAccountType,
    AppRoutes.explorer,
    AppRoutes.pdfReader,
    AppRoutes.auth,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.onboarding,
    AppRoutes.onboardingAge,
    AppRoutes.onboardingInterests,
    AppRoutes.routeBridge,
    AppRoutes.checkoutSuccess,
    AppRoutes.checkoutCancel,
    AppRoutes.notificationPermission,
    AppRoutes.locationPermission,
    AppRoutes.otpVerification,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
  }.contains(location)) {
    return true;
  }

  // Library details uses a path parameter, so the actual location looks like
  // /libraries/{id} rather than the declared /libraries/:libraryId route.
  if (location.startsWith('${AppRoutes.libraries}/') ||
      location.startsWith('/authors/') ||
      location.startsWith('/books/')) {
    return true;
  }

  return false;
}
