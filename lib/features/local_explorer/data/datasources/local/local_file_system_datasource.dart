import '../../../domain/entities/local_directory_snapshot.dart';
import '../../../domain/entities/local_file_entry.dart';

abstract class LocalFileSystemDataSource {
  Future<String> resolveInitialPath();

  Future<List<LocalFileEntry>> listDirectory(String path);

  List<LocalPathSegment> buildBreadcrumbs(String path);

  String? parentOf(String path);
}
