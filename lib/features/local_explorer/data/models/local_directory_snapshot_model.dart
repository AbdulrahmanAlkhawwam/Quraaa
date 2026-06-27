import 'local_file_entry_model.dart';
import 'local_path_segment_model.dart';

class LocalDirectorySnapshotModel {
  const LocalDirectorySnapshotModel({
    required this.currentPath,
    required this.breadcrumbs,
    required this.entries,
  });

  final String currentPath;
  final List<LocalPathSegmentModel> breadcrumbs;
  final List<LocalFileEntryModel> entries;
}
