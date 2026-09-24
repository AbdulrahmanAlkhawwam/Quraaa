import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/local_explorer/data/data_sources/local/local_explorer_platform_data_source.dart';
import 'package:quraaa/features/local_explorer/data/data_sources/local/local_file_system_data_source.dart';
import 'package:quraaa/features/local_explorer/data/repositories/local_file_repository_impl.dart';
import 'package:quraaa/features/local_explorer/domain/entities/local_directory_snapshot.dart';
import 'package:quraaa/features/local_explorer/data/models/local_file_entry_model.dart';
import 'package:quraaa/features/local_explorer/data/models/local_path_segment_model.dart';

class _MockPlatform extends Mock implements LocalExplorerPlatformDataSource {}

class _MockFileSystem extends Mock implements LocalFileSystemDataSource {}

void main() {
  late _MockPlatform platform;
  late _MockFileSystem fileSystem;
  late LocalFileRepositoryImpl repository;

  setUp(() {
    platform = _MockPlatform();
    fileSystem = _MockFileSystem();
    repository = LocalFileRepositoryImpl(
      platformDataSource: platform,
      fileSystemDataSource: fileSystem,
    );
  });

  test('loading a directory without storage access is denied', () async {
    when(() => platform.hasStorageAccess()).thenAnswer((_) async => false);

    final Either<Failure, LocalDirectorySnapshot> result = await repository
        .loadDirectory(path: '/storage/emulated/0');

    expect(result.getLeft().toNullable(), isA<FileAccessDeniedFailure>());
    verifyNever(() => fileSystem.listDirectory(any()));
  });

  test('a readable directory is returned as a snapshot', () async {
    when(() => platform.hasStorageAccess()).thenAnswer((_) async => true);
    when(
      () => fileSystem.buildBreadcrumbs('/books'),
    ).thenReturn(const <LocalPathSegmentModel>[]);
    when(
      () => fileSystem.listDirectory('/books'),
    ).thenAnswer((_) async => const <LocalFileEntryModel>[]);

    final Either<Failure, LocalDirectorySnapshot> result = await repository
        .loadDirectory(path: '/books');

    expect(
      result.getOrElse((_) => fail('expected Right')).currentPath,
      '/books',
    );
  });

  test('a file-system error keeps its message in the failure', () async {
    when(() => platform.hasStorageAccess()).thenAnswer((_) async => true);
    when(
      () => fileSystem.buildBreadcrumbs(any()),
    ).thenReturn(const <LocalPathSegmentModel>[]);
    when(
      () => fileSystem.listDirectory('/books'),
    ).thenThrow(const NotFoundException(message: 'no such directory'));

    final Either<Failure, LocalDirectorySnapshot> result = await repository
        .loadDirectory(path: '/books');

    final Failure failure = result.getLeft().toNullable()!;
    expect(failure, isA<NotFoundFailure>());
    expect(failure.message, 'no such directory');
  });

  test('parentOf reports the parent path synchronously', () {
    when(() => fileSystem.parentOf('/books/sci')).thenReturn('/books');

    expect(
      repository.parentOf('/books/sci'),
      const Right<Failure, String?>('/books'),
    );
  });
}
