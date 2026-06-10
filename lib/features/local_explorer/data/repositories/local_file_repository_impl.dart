import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/local_directory_snapshot.dart';
import '../../domain/repositories/local_file_repository.dart';
import '../datasources/local/local_explorer_platform_datasource.dart';
import '../datasources/local/local_file_system_datasource.dart';

class LocalFileRepositoryImpl implements LocalFileRepository {
  const LocalFileRepositoryImpl({
    required LocalExplorerPlatformDataSource platformDataSource,
    required LocalFileSystemDataSource fileSystemDataSource,
  })  : _platformDataSource = platformDataSource,
        _fileSystemDataSource = fileSystemDataSource;

  final LocalExplorerPlatformDataSource _platformDataSource;
  final LocalFileSystemDataSource _fileSystemDataSource;

  @override
  Future<bool> hasStorageAccess() => _platformDataSource.hasStorageAccess();

  @override
  Future<bool> requestStorageAccess() {
    return _platformDataSource.requestStorageAccess();
  }

  @override
  Future<LocalDirectorySnapshot> loadDirectory({String? path}) async {
    if (!await hasStorageAccess()) {
      throw const FileAccessDeniedException(
        message: 'Storage access is required.',
      );
    }

    final String resolvedPath = path ?? await _fileSystemDataSource.resolveInitialPath();
    return LocalDirectorySnapshot(
      currentPath: resolvedPath,
      breadcrumbs: _fileSystemDataSource.buildBreadcrumbs(resolvedPath),
      entries: await _fileSystemDataSource.listDirectory(resolvedPath),
    );
  }

  @override
  String? parentOf(String path) => _fileSystemDataSource.parentOf(path);
}
