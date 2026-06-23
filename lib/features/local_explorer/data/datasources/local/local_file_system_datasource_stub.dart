import '../../models/local_file_entry_model.dart';
import '../../models/local_path_segment_model.dart';
import 'local_explorer_platform_datasource.dart';
import 'local_file_system_datasource.dart';

LocalFileSystemDataSource createDataSource(
  LocalExplorerPlatformDataSource platformDataSource,
) {
  return const UnsupportedLocalFileSystemDataSource();
}

class UnsupportedLocalFileSystemDataSource
    implements LocalFileSystemDataSource {
  const UnsupportedLocalFileSystemDataSource();

  @override
  Future<String> resolveInitialPath() {
    throw UnsupportedError('Local file browsing is not supported here.');
  }

  @override
  Future<List<LocalFileEntryModel>> listDirectory(String path) {
    throw UnsupportedError('Local file browsing is not supported here.');
  }

  @override
  List<LocalPathSegmentModel> buildBreadcrumbs(String path) {
    return <LocalPathSegmentModel>[
      LocalPathSegmentModel(label: path, path: path),
    ];
  }

  @override
  String? parentOf(String path) => null;
}
