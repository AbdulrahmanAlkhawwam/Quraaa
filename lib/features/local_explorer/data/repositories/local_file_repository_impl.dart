import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/local_directory_snapshot.dart';
import '../../domain/repositories/local_file_repository.dart';
import '../../domain/value_objects/result.dart';
import '../datasources/local/local_explorer_platform_datasource.dart';
import '../datasources/local/local_file_system_datasource.dart';
import '../mappers/local_directory_snapshot_mapper.dart';
import '../models/local_directory_snapshot_model.dart';

class LocalFileRepositoryImpl implements LocalFileRepository {
  const LocalFileRepositoryImpl({
    required this._platformDataSource,
    required this._fileSystemDataSource,
    this._snapshotMapper = const LocalDirectorySnapshotMapper(),
  });

  final LocalExplorerPlatformDataSource _platformDataSource;
  final LocalFileSystemDataSource _fileSystemDataSource;
  final LocalDirectorySnapshotMapper _snapshotMapper;

  @override
  Future<Result<bool>> hasStorageAccess() {
    return _run(() => _platformDataSource.hasStorageAccess());
  }

  @override
  Future<Result<bool>> requestStorageAccess() {
    return _run(() => _platformDataSource.requestStorageAccess());
  }

  @override
  Future<Result<LocalDirectorySnapshot>> loadDirectory({String? path}) async {
    final Result<bool> accessResult = await hasStorageAccess();
    if (accessResult case ResultFailure<bool>(failure: final Failure failure)) {
      return ResultFailure<LocalDirectorySnapshot>(failure);
    }

    final bool hasAccess = switch (accessResult) {
      Success<bool>(value: final bool value) => value,
      ResultFailure<bool>() => false,
    };
    if (!hasAccess) {
      return const ResultFailure<LocalDirectorySnapshot>(
        FileAccessDeniedFailure(
          message: 'Storage access is required.',
        ),
      );
    }

    try {
      final String resolvedPath =
          path ?? await _fileSystemDataSource.resolveInitialPath();
      final LocalDirectorySnapshotModel snapshot = LocalDirectorySnapshotModel(
        currentPath: resolvedPath,
        breadcrumbs: _fileSystemDataSource.buildBreadcrumbs(resolvedPath),
        entries: await _fileSystemDataSource.listDirectory(resolvedPath),
      );

      return Success<LocalDirectorySnapshot>(_snapshotMapper.toEntity(snapshot));
    } catch (error) {
      return ResultFailure<LocalDirectorySnapshot>(
        _failureFromError(error),
      );
    }
  }

  @override
  Result<String?> parentOf(String path) {
    try {
      return Success<String?>(_fileSystemDataSource.parentOf(path));
    } catch (error) {
      return ResultFailure<String?>(_failureFromError(error));
    }
  }

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } catch (error) {
      return ResultFailure<T>(_failureFromError(error));
    }
  }

  Failure _failureFromError(Object error) {
    return switch (error) {
      FileAccessDeniedException(message: final String message) =>
        FileAccessDeniedFailure(message: message),
      NotFoundException(message: final String message) =>
        NotFoundFailure(message: message),
      AppException(message: final String message) =>
        UnknownFailure(message: message),
      UnsupportedError(message: final String? message) =>
        UnknownFailure(message: message ?? '$error'),
      _ => UnknownFailure(message: '$error'),
    };
  }
}
