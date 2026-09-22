import 'local_explorer_platform_data_source.dart';
import 'local_file_system_data_source.dart';
import 'local_file_system_data_source_stub.dart'
    if (dart.library.io) 'local_file_system_data_source_io.dart';

LocalFileSystemDataSource createLocalFileSystemDataSource(
  LocalExplorerPlatformDataSource platformDataSource,
) {
  return createDataSource(platformDataSource);
}
