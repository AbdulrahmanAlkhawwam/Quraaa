import 'package:get_it/get_it.dart';

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
  registerCoreDependencies();
  registerFeatureDependencies();
  await initializeNotificationDependencies();
}

void registerCoreDependencies() {
  sl
    ..registerLazySingleton<NotificationService>(NotificationService.new)
    ..registerLazySingleton<FirebaseMessagingService>(
      () => FirebaseMessagingService(
        notificationService: sl<NotificationService>(),
      ),
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

  await notificationService.initialize(requestPermission: true);
  await messagingService.requestPermissions();
  await messagingService.subscribeToDefaultTopic();
  messagingService.listenToForegroundMessages();
  await messagingService.logDeviceToken();
}
