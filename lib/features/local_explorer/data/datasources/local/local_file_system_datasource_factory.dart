import 'local_explorer_platform_datasource.dart';
import 'local_file_system_datasource.dart';
import 'local_file_system_datasource_stub.dart'
    if (dart.library.io) 'local_file_system_datasource_io.dart';

LocalFileSystemDataSource createLocalFileSystemDataSource(
  LocalExplorerPlatformDataSource platformDataSource,
) {
  return createDataSource(platformDataSource);
}
