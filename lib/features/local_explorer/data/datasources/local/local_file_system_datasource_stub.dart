import '../../../domain/entities/local_directory_snapshot.dart';
import '../../../domain/entities/local_file_entry.dart';
import 'local_explorer_platform_datasource.dart';
import 'local_file_system_datasource.dart';

LocalFileSystemDataSource createDataSource(
  LocalExplorerPlatformDataSource platformDataSource,
) {
  return const UnsupportedLocalFileSystemDataSource();
}

class UnsupportedLocalFileSystemDataSource implements LocalFileSystemDataSource {
  const UnsupportedLocalFileSystemDataSource();

  @override
  Future<String> resolveInitialPath() {
    throw UnsupportedError('Local file browsing is not supported here.');
  }

  @override
  Future<List<LocalFileEntry>> listDirectory(String path) {
    throw UnsupportedError('Local file browsing is not supported here.');
  }

  @override
  List<LocalPathSegment> buildBreadcrumbs(String path) {
    return <LocalPathSegment>[LocalPathSegment(label: path, path: path)];
  }

  @override
  String? parentOf(String path) => null;
}
