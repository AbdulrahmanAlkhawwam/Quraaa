import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/local_directory_snapshot.dart';
import '../../domain/repositories/local_file_repository.dart';
import '../data_sources/local/local_explorer_platform_data_source.dart';
import '../data_sources/local/local_file_system_data_source.dart';
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
  FutureEither<bool> hasStorageAccess() {
    return _run(() => _platformDataSource.hasStorageAccess());
  }

  @override
  FutureEither<bool> requestStorageAccess() {
    return _run(() => _platformDataSource.requestStorageAccess());
  }

  @override
  FutureEither<LocalDirectorySnapshot> loadDirectory({String? path}) async {
    final Either<Failure, bool> accessResult = await hasStorageAccess();
    final Failure? accessFailure = accessResult.getLeft().toNullable();
    if (accessFailure != null) return Left(accessFailure);

    if (!accessResult.getOrElse((_) => false)) {
      return const Left(
        FileAccessDeniedFailure(message: 'Storage access is required.'),
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

      return Right(_snapshotMapper.toEntity(snapshot));
    } catch (error) {
      return Left(_failureFromError(error));
    }
  }

  @override
  Either<Failure, String?> parentOf(String path) {
    try {
      return Right(_fileSystemDataSource.parentOf(path));
    } catch (error) {
      return Left(_failureFromError(error));
    }
  }

  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (error) {
      return Left(_failureFromError(error));
    }
  }

  /// Local mapping rather than [ErrorMapper]: file-system errors carry text
  /// (a path, a permission hint) that the shared mapper's fallback drops.
  Failure _failureFromError(Object error) {
    return switch (error) {
      FileAccessDeniedException(message: final String message) =>
        FileAccessDeniedFailure(message: message),
      NotFoundException(message: final String message) => NotFoundFailure(
        message: message,
      ),
      AppException(message: final String message) => UnknownFailure(
        message: message,
      ),
      UnsupportedError(message: final String? message) => UnknownFailure(
        message: message ?? '$error',
      ),
      _ => UnknownFailure(message: '$error'),
    };
  }
}
