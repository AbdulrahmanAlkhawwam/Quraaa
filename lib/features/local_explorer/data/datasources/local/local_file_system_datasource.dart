import '../../models/local_file_entry_model.dart';
import '../../models/local_path_segment_model.dart';

abstract class LocalFileSystemDataSource {
  Future<String> resolveInitialPath();

  Future<List<LocalFileEntryModel>> listDirectory(String path);

  List<LocalPathSegmentModel> buildBreadcrumbs(String path);

  String? parentOf(String path);
}
