import '../entities/local_directory_snapshot.dart';
import '../value_objects/result.dart';

abstract class LocalFileRepository {
  Future<Result<bool>> hasStorageAccess();

  Future<Result<bool>> requestStorageAccess();

  Future<Result<LocalDirectorySnapshot>> loadDirectory({String? path});

  Result<String?> parentOf(String path);
}
