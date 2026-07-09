import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/user_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/use_cases/complete_onboarding_use_case.dart';
import '../../features/onboarding/domain/use_cases/load_onboarding_state_use_case.dart';
import '../../features/onboarding/domain/use_cases/save_birth_date_use_case.dart';
import '../../features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import '../../features/onboarding/domain/use_cases/load_categories_use_case.dart';
import '../../features/onboarding/domain/use_cases/save_category_id_use_case.dart';
import '../../features/onboarding/domain/use_cases/save_gender_use_case.dart';
import '../../features/auth/domain/use_cases/register_use_case.dart';
import '../../features/auth/domain/use_cases/login_use_case.dart';
import '../../features/auth/domain/use_cases/verify_otp_use_case.dart';
import '../../features/auth/domain/use_cases/forgot_password_use_case.dart';
import '../../features/auth/domain/use_cases/reset_password_use_case.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_journey_cubit.dart';
import '../../features/auth/presentation/bloc/auth_permission_cubit.dart';
import '../../features/auth/presentation/bloc/auth_recovery_cubit.dart';
import '../../features/auth/presentation/bloc/auth_registration_cubit.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../error_monitoring/app_bloc_observer.dart';
import '../error_monitoring/crashlytics_service.dart';
import '../error_monitoring/device_info_provider.dart';
import '../error_monitoring/dio_logging_interceptor.dart';
import '../error_monitoring/navigation_tracker.dart';
import '../error_monitoring/error_report_cache.dart';
import '../error_monitoring/telegram_notification_service.dart';
import '../error_monitoring/user_context_provider.dart';
import '../../shared/theme/app_theme_cubit.dart';
import '../../features/account/account.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/edit_profile_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/libraries/data/datasources/libraries_remote_data_source.dart';
import '../../features/libraries/data/repositories/libraries_repository_impl.dart';
import '../../features/libraries/domain/repositories/libraries_repository.dart';
import '../../features/libraries/domain/use_cases/get_libraries_use_case.dart';
import '../../features/libraries/presentation/cubit/libraries_cubit.dart';
import '../../features/libraries/data/datasources/library_details_remote_data_source.dart';
import '../../features/libraries/data/repositories/library_details_repository_impl.dart';
import '../../features/libraries/domain/repositories/library_details_repository.dart';
import '../../features/libraries/domain/use_cases/get_library_books_use_case.dart';
import '../../features/libraries/presentation/cubit/library_details_cubit.dart';
import '../../config/env/env.dart';
import '../network/auth_interceptor.dart';
import '../network/connectivity_interceptor.dart';
import '../network/http_helper.dart';
import '../services/app_diagnostics_service.dart';
import '../connectivity/connectivity_service.dart';
import '../connectivity/connectivity_service_impl.dart';
import '../services/firebase_notification_service.dart';
import '../services/storage_service_impl.dart';

import '../services/services.dart';
import '../../features/local_explorer/data/datasources/local/local_explorer_platform_datasource.dart';
import '../../features/local_explorer/data/datasources/local/local_file_system_datasource.dart';
import '../../features/local_explorer/data/datasources/local/local_file_system_datasource_factory.dart';
import '../../features/local_explorer/data/repositories/local_file_repository_impl.dart';
import '../../features/local_explorer/domain/repositories/local_file_repository.dart';
import '../../features/local_explorer/domain/use_cases/load_local_directory_use_case.dart';
import '../../features/local_explorer/presentation/bloc/local_explorer_bloc.dart';
import '../../features/pdf_reader/data/datasources/local/pdf_render_datasource.dart';
import '../../features/pdf_reader/data/datasources/local/pdf_note_datasource.dart';
import '../../features/pdf_reader/data/repositories/pdf_reader_repository_impl.dart';
import '../../features/pdf_reader/domain/repositories/pdf_reader_repository.dart';
import '../../features/pdf_reader/domain/use_cases/delete_pdf_text_note_use_case.dart';
import '../../features/pdf_reader/domain/use_cases/get_pdf_page_count_use_case.dart';
import '../../features/pdf_reader/domain/use_cases/get_pdf_text_layer_use_case.dart';
import '../../features/pdf_reader/domain/use_cases/load_pdf_text_notes_use_case.dart';
import '../../features/pdf_reader/domain/use_cases/render_pdf_page_use_case.dart';
import '../../features/pdf_reader/domain/use_cases/save_pdf_text_note_use_case.dart';
import '../../features/pdf_reader/domain/use_cases/share_pdf_text_use_case.dart';
import '../../features/pdf_reader/presentation/bloc/pdf_reader_bloc.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/use_cases/apply_cart_coupon_use_case.dart';
import '../../features/cart/domain/use_cases/get_cart_use_case.dart';
import '../../features/cart/domain/use_cases/remove_cart_item_use_case.dart';
import '../../features/cart/domain/use_cases/update_cart_item_quantity_use_case.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/book_assistant/data/repositories/book_assistant_repository_impl.dart';
import '../../features/book_assistant/domain/repositories/book_assistant_repository.dart';
import '../../features/book_assistant/domain/use_cases/ask_book_assistant_use_case.dart';
import '../../features/book_assistant/domain/use_cases/get_assistant_books_use_case.dart';
import '../../features/book_assistant/presentation/bloc/book_assistant_bloc.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/use_cases/get_activity_sections_use_case.dart';
import '../../features/settings/domain/use_cases/get_appearance_options_use_case.dart';
import '../../features/settings/domain/use_cases/get_badges_sections_use_case.dart';
import '../../features/settings/domain/use_cases/get_language_options_use_case.dart';
import '../../features/settings/domain/use_cases/get_library_sections_use_case.dart';
import '../../features/settings/domain/use_cases/get_notification_settings_use_case.dart';
import '../../features/settings/domain/use_cases/get_profile_sections_use_case.dart';
import '../../features/settings/domain/use_cases/get_settings_sections_use_case.dart';
import '../../features/settings/domain/use_cases/get_settings_tabs_use_case.dart';
import '../../features/settings/domain/use_cases/update_appearance_option_use_case.dart';
import '../../features/settings/domain/use_cases/update_language_option_use_case.dart';
import '../../features/settings/domain/use_cases/update_notification_setting_use_case.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  registerCoreDependencies();
  registerFeatureDependencies();
  await initializeNotificationDependencies();
}

void registerCoreDependencies() {
  sl.registerLazySingleton<StorageService>(
    () => StorageServiceImpl(sl<SharedPreferences>()),
  );

  // Auth token storage must be available to the network layer so the auth
  // interceptor can attach tokens to outgoing requests.
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<StorageService>()),
  );

  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(sl<StorageService>()),
  );

  sl.registerLazySingleton<UserDataLocalDataSource>(
    () => UserDataLocalDataSource(sl<StorageService>()),
  );

  sl.registerLazySingleton<DeviceInfoProvider>(() => DeviceInfoProvider());
  sl.registerLazySingleton<NavigationTracker>(() => NavigationTracker());
  sl.registerLazySingleton<UserContextProvider>(
    () => UserContextProvider(sl<StorageService>()),
  );
  sl.registerLazySingleton<CrashlyticsService>(() => CrashlyticsService());
  sl.registerLazySingleton<ErrorReportCache>(
    () => ErrorReportCache(sl<StorageService>()),
  );

  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(),
  );

  sl.registerLazySingleton<TelegramNotificationService>(
    () => TelegramNotificationService(
      sl<ErrorReportCache>(),
      sl<ConnectivityService>(),
      // Telegram credentials must not be bundled in the app. Provide them via
      // --dart-define only if client-side Telegram reporting is required,
      // otherwise leave them null to keep the service disabled.
      botToken: const String.fromEnvironment('TELEGRAM_BOT_TOKEN'),
      chatId: const String.fromEnvironment('TELEGRAM_CHAT_ID'),
    ),
  );
  sl.registerLazySingleton<AppLogger>(
    () => AppLoggerImpl(
      crashlyticsService: sl<CrashlyticsService>(),
      telegramNotificationService: sl<TelegramNotificationService>(),
      navigationTracker: sl<NavigationTracker>(),
      userContextProvider: sl<UserContextProvider>(),
      deviceInfoProvider: sl<DeviceInfoProvider>(),
    ),
  );
  sl.registerLazySingleton<AppBlocObserver>(
    () => AppBlocObserver(sl<AppLogger>()),
  );
  sl.registerLazySingleton<DioLoggingInterceptor>(
    () => DioLoggingInterceptor(sl<AppLogger>()),
  );
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(sl<AuthLocalDataSource>(), baseUrl: Env.apiBaseUrl),
  );
  sl.registerLazySingleton<ConnectivityInterceptor>(
    () => ConnectivityInterceptor(sl<ConnectivityService>()),
  );
  sl.registerLazySingleton<Dio>(
    () => HttpHelper.buildDio(<Interceptor>[
      sl<ConnectivityInterceptor>(),
      sl<AuthInterceptor>(),
      sl<DioLoggingInterceptor>(),
    ]),
  );
  sl.registerLazySingleton<HttpHelper>(() => HttpHelper(sl<Dio>()));

  sl.registerLazySingleton<LocalNotificationService>(
    LocalNotificationService.new,
  );

  sl.registerLazySingleton<NotificationService>(
    () => FirebaseNotificationService(),
  );

  sl.registerLazySingleton<LocationPermissionService>(
    () => const GeolocatorLocationPermissionService(),
  );

  sl.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingService(
      notificationService: sl<LocalNotificationService>(),
    ),
  );

  sl.registerLazySingleton<AppDiagnosticsService>(
    () => AppDiagnosticsService(sl<AppLogger>()),
  );

  sl.registerLazySingleton<AppThemeCubit>(
    () => AppThemeCubit(sl<StorageService>()),
  );
}

void registerFeatureDependencies() {
  if (!sl.isRegistered<LocalExplorerPlatformDataSource>()) {
    sl.registerLazySingleton<LocalExplorerPlatformDataSource>(
      LocalExplorerPlatformDataSource.new,
    );
  }

  if (!sl.isRegistered<LocalFileSystemDataSource>()) {
    sl.registerLazySingleton<LocalFileSystemDataSource>(
      () => createLocalFileSystemDataSource(sl()),
    );
  }

  if (!sl.isRegistered<PdfRenderDataSource>()) {
    sl.registerLazySingleton<PdfRenderDataSource>(
      MethodChannelPdfRenderDataSource.new,
    );
  }

  if (!sl.isRegistered<PdfNoteDataSource>()) {
    sl.registerLazySingleton<PdfNoteDataSource>(InMemoryPdfNoteDataSource.new);
  }

  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sl<StorageService>()),
  );

  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      sl<OnboardingLocalDataSource>(),
      sl<OnboardingRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(sl<HttpHelper>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<HttpHelper>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerFactory<LoadOnboardingStateUseCase>(
    () => LoadOnboardingStateUseCase(sl<OnboardingRepository>()),
  );
  sl.registerFactory<SaveBirthDateUseCase>(
    () => SaveBirthDateUseCase(sl<OnboardingRepository>()),
  );
  sl.registerFactory<SaveGenderUseCase>(
    () => SaveGenderUseCase(sl<OnboardingRepository>()),
  );
  sl.registerFactory<SaveCategoryIdUseCase>(
    () => SaveCategoryIdUseCase(sl<OnboardingRepository>()),
  );
  sl.registerFactory<LoadCategoriesUseCase>(
    () => LoadCategoriesUseCase(sl<OnboardingRepository>()),
  );
  sl.registerFactory<CompleteOnboardingUseCase>(
    () => CompleteOnboardingUseCase(sl<OnboardingRepository>()),
  );
  sl.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(
      loadOnboardingStateUseCase: sl<LoadOnboardingStateUseCase>(),
      saveBirthDateUseCase: sl<SaveBirthDateUseCase>(),
      saveGenderUseCase: sl<SaveGenderUseCase>(),
      saveCategoryIdUseCase: sl<SaveCategoryIdUseCase>(),
      loadCategoriesUseCase: sl<LoadCategoriesUseCase>(),
      completeOnboardingUseCase: sl<CompleteOnboardingUseCase>(),
    ),
  );

  sl.registerFactory<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));

  sl.registerFactory<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      authJourney: sl<AuthLocalDataSource>(),
      userCache: sl<UserLocalDataSource>(),
      userContext: sl<UserContextProvider>(),
    ),
  );

  sl.registerFactory<AuthPermissionCubit>(
    () => AuthPermissionCubit(
      authJourney: sl<AuthLocalDataSource>(),
      notificationService: sl<NotificationService>(),
      locationPermissionService: sl<LocationPermissionService>(),
    ),
  );

  sl.registerFactory<AuthJourneyCubit>(
    () => AuthJourneyCubit(authJourney: sl<AuthLocalDataSource>()),
  );

  sl.registerFactory<AuthRegistrationCubit>(
    () => AuthRegistrationCubit(
      loadOnboardingStateUseCase: sl<LoadOnboardingStateUseCase>(),
      loadCategoriesUseCase: sl<LoadCategoriesUseCase>(),
    ),
  );

  sl.registerFactory<AuthRecoveryCubit>(
    () => AuthRecoveryCubit(
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
      verifyOtpUseCase: sl<VerifyOtpUseCase>(),
      authJourney: sl<AuthLocalDataSource>(),
    ),
  );

  // Profile binding feature
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sl<StorageService>()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<HttpHelper>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      profileRepository: sl<ProfileRepository>(),
      authRepository: sl<AuthRepository>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
      userLocalDataSource: sl<UserLocalDataSource>(),
      connectivityService: sl<ConnectivityService>(),
      profileLocalDataSource: sl<ProfileLocalDataSource>(),
    ),
  );

  sl.registerFactory<EditProfileBloc>(EditProfileBloc.new);

  // Account feature
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(sl<UserDataLocalDataSource>()),
  );

  sl.registerFactory<LoadAccountUserSnapshotUseCase>(
    () => LoadAccountUserSnapshotUseCase(sl<AccountRepository>()),
  );

  // Home feature
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      loadUserSnapshot: sl<LoadAccountUserSnapshotUseCase>(),
      notificationService: sl<NotificationService>(),
    ),
  );

  // Libraries feature
  sl.registerLazySingleton<LibrariesRemoteDataSource>(
    () => LibrariesRemoteDataSourceImpl(sl<HttpHelper>()),
  );

  sl.registerLazySingleton<LibrariesRepository>(
    () => LibrariesRepositoryImpl(sl<LibrariesRemoteDataSource>()),
  );

  sl.registerFactory<GetLibrariesUseCase>(
    () => GetLibrariesUseCase(sl<LibrariesRepository>()),
  );

  sl.registerFactory<LibrariesCubit>(
    () => LibrariesCubit(
      getLibrariesUseCase: sl<GetLibrariesUseCase>(),
      loadUserSnapshotUseCase: sl<LoadAccountUserSnapshotUseCase>(),
    ),
  );

  // Library details feature
  sl.registerLazySingleton<LibraryDetailsRemoteDataSource>(
    () => LibraryDetailsRemoteDataSourceImpl(sl<HttpHelper>()),
  );

  sl.registerLazySingleton<LibraryDetailsRepository>(
    () => LibraryDetailsRepositoryImpl(sl<LibraryDetailsRemoteDataSource>()),
  );

  sl.registerFactory<GetLibraryBooksUseCase>(
    () => GetLibraryBooksUseCase(sl<LibraryDetailsRepository>()),
  );

  sl.registerFactoryParam<LibraryDetailsCubit, String, void>(
    (String libraryId, _) => LibraryDetailsCubit(
      libraryId: libraryId,
      getLibraryBooksUseCase: sl<GetLibraryBooksUseCase>(),
    ),
  );

  if (!sl.isRegistered<PdfReaderRepository>()) {
    sl.registerLazySingleton<PdfReaderRepository>(
      () =>
          PdfReaderRepositoryImpl(renderDataSource: sl(), noteDataSource: sl()),
    );
  }

  if (!sl.isRegistered<GetPdfPageCountUseCase>()) {
    sl.registerLazySingleton<GetPdfPageCountUseCase>(
      () => GetPdfPageCountUseCase(sl()),
    );
  }

  if (!sl.isRegistered<RenderPdfPageUseCase>()) {
    sl.registerLazySingleton<RenderPdfPageUseCase>(
      () => RenderPdfPageUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetPdfTextLayerUseCase>()) {
    sl.registerLazySingleton<GetPdfTextLayerUseCase>(
      () => GetPdfTextLayerUseCase(sl()),
    );
  }

  if (!sl.isRegistered<SharePdfTextUseCase>()) {
    sl.registerLazySingleton<SharePdfTextUseCase>(
      () => SharePdfTextUseCase(sl()),
    );
  }

  if (!sl.isRegistered<LoadPdfTextNotesUseCase>()) {
    sl.registerLazySingleton<LoadPdfTextNotesUseCase>(
      () => LoadPdfTextNotesUseCase(sl()),
    );
  }

  if (!sl.isRegistered<SavePdfTextNoteUseCase>()) {
    sl.registerLazySingleton<SavePdfTextNoteUseCase>(
      () => SavePdfTextNoteUseCase(sl()),
    );
  }

  if (!sl.isRegistered<DeletePdfTextNoteUseCase>()) {
    sl.registerLazySingleton<DeletePdfTextNoteUseCase>(
      () => DeletePdfTextNoteUseCase(sl()),
    );
  }

  if (!sl.isRegistered<LocalFileRepository>()) {
    sl.registerLazySingleton<LocalFileRepository>(
      () => LocalFileRepositoryImpl(
        platformDataSource: sl(),
        fileSystemDataSource: sl(),
      ),
    );
  }

  if (!sl.isRegistered<LoadLocalDirectoryUseCase>()) {
    sl.registerLazySingleton<LoadLocalDirectoryUseCase>(
      () => LoadLocalDirectoryUseCase(sl()),
    );
  }

  if (!sl.isRegistered<LocalExplorerBloc>()) {
    sl.registerFactory<LocalExplorerBloc>(
      () => LocalExplorerBloc(loadDirectory: sl(), repository: sl()),
    );
  }

  if (!sl.isRegistered<PdfReaderBloc>()) {
    sl.registerFactory<PdfReaderBloc>(
      () => PdfReaderBloc(
        getPageCount: sl(),
        loadNotes: sl(),
        saveNote: sl(),
        deleteNote: sl(),
      ),
    );
  }


  if (!sl.isRegistered<CartRepository>()) {
    sl.registerLazySingleton<CartRepository>(
      CartRepositoryImpl.new,
    );
  }

  if (!sl.isRegistered<GetCartUseCase>()) {
    sl.registerLazySingleton<GetCartUseCase>(
      () => GetCartUseCase(sl()),
    );
  }

  if (!sl.isRegistered<UpdateCartItemQuantityUseCase>()) {
    sl.registerLazySingleton<UpdateCartItemQuantityUseCase>(
      () => UpdateCartItemQuantityUseCase(sl()),
    );
  }

  if (!sl.isRegistered<RemoveCartItemUseCase>()) {
    sl.registerLazySingleton<RemoveCartItemUseCase>(
      () => RemoveCartItemUseCase(sl()),
    );
  }

  if (!sl.isRegistered<ApplyCartCouponUseCase>()) {
    sl.registerLazySingleton<ApplyCartCouponUseCase>(
      () => ApplyCartCouponUseCase(sl()),
    );
  }

  if (!sl.isRegistered<CartBloc>()) {
    sl.registerFactory<CartBloc>(
      () => CartBloc(
        getCart: sl(),
        updateQuantity: sl(),
        removeItem: sl(),
        applyCoupon: sl(),
      ),
    );
  }
  if (!sl.isRegistered<BookAssistantRepository>()) {
    sl.registerLazySingleton<BookAssistantRepository>(
      BookAssistantRepositoryImpl.new,
    );
  }

  if (!sl.isRegistered<GetAssistantBooksUseCase>()) {
    sl.registerLazySingleton<GetAssistantBooksUseCase>(
      () => GetAssistantBooksUseCase(sl()),
    );
  }

  if (!sl.isRegistered<AskBookAssistantUseCase>()) {
    sl.registerLazySingleton<AskBookAssistantUseCase>(
      () => AskBookAssistantUseCase(sl()),
    );
  }

  if (!sl.isRegistered<BookAssistantBloc>()) {
    sl.registerFactory<BookAssistantBloc>(
      () => BookAssistantBloc(
        getBooks: sl(),
        askAssistant: sl(),
      ),
    );
  }

  if (!sl.isRegistered<SettingsRepository>()) {
    sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl<StorageService>()),
    );
  }

  if (!sl.isRegistered<GetSettingsTabsUseCase>()) {
    sl.registerLazySingleton<GetSettingsTabsUseCase>(
      () => GetSettingsTabsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetProfileSectionsUseCase>()) {
    sl.registerLazySingleton<GetProfileSectionsUseCase>(
      () => GetProfileSectionsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetSettingsSectionsUseCase>()) {
    sl.registerLazySingleton<GetSettingsSectionsUseCase>(
      () => GetSettingsSectionsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetLibrarySectionsUseCase>()) {
    sl.registerLazySingleton<GetLibrarySectionsUseCase>(
      () => GetLibrarySectionsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetBadgesSectionsUseCase>()) {
    sl.registerLazySingleton<GetBadgesSectionsUseCase>(
      () => GetBadgesSectionsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetActivitySectionsUseCase>()) {
    sl.registerLazySingleton<GetActivitySectionsUseCase>(
      () => GetActivitySectionsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetAppearanceOptionsUseCase>()) {
    sl.registerLazySingleton<GetAppearanceOptionsUseCase>(
      () => GetAppearanceOptionsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetNotificationSettingsUseCase>()) {
    sl.registerLazySingleton<GetNotificationSettingsUseCase>(
      () => GetNotificationSettingsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GetLanguageOptionsUseCase>()) {
    sl.registerLazySingleton<GetLanguageOptionsUseCase>(
      () => GetLanguageOptionsUseCase(sl()),
    );
  }

  if (!sl.isRegistered<UpdateAppearanceOptionUseCase>()) {
    sl.registerLazySingleton<UpdateAppearanceOptionUseCase>(
      () => UpdateAppearanceOptionUseCase(sl()),
    );
  }

  if (!sl.isRegistered<UpdateNotificationSettingUseCase>()) {
    sl.registerLazySingleton<UpdateNotificationSettingUseCase>(
      () => UpdateNotificationSettingUseCase(sl()),
    );
  }

  if (!sl.isRegistered<UpdateLanguageOptionUseCase>()) {
    sl.registerLazySingleton<UpdateLanguageOptionUseCase>(
      () => UpdateLanguageOptionUseCase(sl()),
    );
  }

  if (!sl.isRegistered<SettingsBloc>()) {
    sl.registerFactory<SettingsBloc>(
      () => SettingsBloc(
        getTabs: sl(),
        getProfileSections: sl(),
        getSettingsSections: sl(),
        getLibrarySections: sl(),
        getBadgesSections: sl(),
        getActivitySections: sl(),
        getAppearanceOptions: sl(),
        getNotificationSettings: sl(),
        getLanguageOptions: sl(),
        updateAppearance: sl(),
        updateNotification: sl(),
        updateLanguage: sl(),
        storageService: sl(),
      ),
    );
  }
}

void registerTestDependencies() {
  // Register test doubles here when needed.
}

/// Initializes notifications and FCM after Firebase has been set up.
Future<void> initializeNotificationDependencies() async {
  final notificationService = sl<NotificationService>();
  final messagingService = sl<FirebaseMessagingService>();

  // Notification permission is requested through the post-registration UI
  // (NotificationPermissionScreen) instead of at startup.
  await notificationService.initialize(shouldRequestPermission: false);
  await messagingService.subscribeToDefaultTopic();
  messagingService.listenToForegroundMessages();
  await messagingService.logDeviceToken();
}
