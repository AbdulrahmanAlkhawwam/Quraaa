import 'package:get_it/get_it.dart';

import '../../features/local_explorer/data/datasources/local/local_explorer_platform_datasource.dart';
import '../../features/local_explorer/data/datasources/local/local_file_system_datasource.dart';
import '../../features/local_explorer/data/datasources/local/local_file_system_datasource_factory.dart';
import '../../features/local_explorer/data/datasources/local/pdf_render_datasource.dart';
import '../../features/local_explorer/data/repositories/local_file_repository_impl.dart';
import '../../features/local_explorer/domain/repositories/local_file_repository.dart';
import '../../features/local_explorer/domain/use_cases/load_local_directory_use_case.dart';
import '../../features/local_explorer/presentation/bloc/local_explorer_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  registerCoreDependencies();
  registerFeatureDependencies();
}

void registerCoreDependencies() {}

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
}

void registerTestDependencies() {}
