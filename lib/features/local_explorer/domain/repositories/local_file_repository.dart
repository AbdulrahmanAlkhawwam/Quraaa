import '../entities/local_directory_snapshot.dart';

abstract class LocalFileRepository {
  Future<bool> hasStorageAccess();

  Future<bool> requestStorageAccess();

  Future<LocalDirectorySnapshot> loadDirectory({String? path});

  String? parentOf(String path);
}
