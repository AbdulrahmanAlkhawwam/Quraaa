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
import '../../features/auth/presentation/bloc/auth_bloc.dart';
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
import '../../features/account/data/user_data_local_data_source.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../screens/profile/bloc/edit_profile_bloc.dart';
import '../network/auth_interceptor.dart';
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
    () => AuthInterceptor(sl<AuthLocalDataSource>()),
  );
  sl.registerLazySingleton<Dio>(
    () => HttpHelper.buildDio(<Interceptor>[
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
    sl.registerLazySingleton<PdfNoteDataSource>(
      InMemoryPdfNoteDataSource.new,
    );
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

  sl.registerFactory<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
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

  if (!sl.isRegistered<PdfReaderRepository>()) {
    sl.registerLazySingleton<PdfReaderRepository>(
      () => PdfReaderRepositoryImpl(
        renderDataSource: sl(),
        noteDataSource: sl(),
      ),
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
      () => LocalExplorerBloc(
        loadDirectory: sl(),
        repository: sl(),
      ),
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
}

void registerTestDependencies() {
  // Register test doubles here when needed.
}

/// Initializes notifications and FCM after Firebase has been set up.
Future<void> initializeNotificationDependencies() async {
  final notificationService = sl<NotificationService>();
  final messagingService = sl<FirebaseMessagingService>();

  await notificationService.initialize(shouldRequestPermission: true);
  await messagingService.requestPermissions();
  await messagingService.subscribeToDefaultTopic();
  messagingService.listenToForegroundMessages();
  await messagingService.logDeviceToken();
}
