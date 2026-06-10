import 'dart:io';

import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entities/local_directory_snapshot.dart';
import '../../../domain/entities/local_file_entry.dart';
import 'local_explorer_platform_datasource.dart';
import 'local_file_system_datasource.dart';

LocalFileSystemDataSource createDataSource(
  LocalExplorerPlatformDataSource platformDataSource,
) {
  return IoLocalFileSystemDataSource(platformDataSource);
}

class IoLocalFileSystemDataSource implements LocalFileSystemDataSource {
  IoLocalFileSystemDataSource(this._platformDataSource);

  static const String _androidRootPath = '/storage/emulated/0';

  final LocalExplorerPlatformDataSource _platformDataSource;

  @override
  Future<String> resolveInitialPath() async {
    final String? platformPath = await _platformDataSource.defaultRootPath();
    if (platformPath != null && await Directory(platformPath).exists()) {
      return platformPath;
    }

    for (final String path in _candidateInitialPaths()) {
      if (await Directory(path).exists()) {
        return path;
      }
    }

    return Directory.current.path;
  }

  @override
  Future<List<LocalFileEntry>> listDirectory(String path) async {
    final Directory directory = Directory(path);
    if (!await directory.exists()) {
      throw NotFoundException(message: 'Folder was not found.');
    }

    final List<LocalFileEntry> entries = <LocalFileEntry>[];

    try {
      await for (final FileSystemEntity entity
          in directory.list(followLinks: false)) {
        final String name = _basename(entity.path);
        if (name.isEmpty || name.startsWith('.')) {
          continue;
        }

        final FileSystemEntityType entityType;
        try {
          entityType = await FileSystemEntity.type(
            entity.path,
            followLinks: false,
          );
        } on FileSystemException {
          continue;
        }

        if (entityType != FileSystemEntityType.directory &&
            entityType != FileSystemEntityType.file) {
          continue;
        }

        final FileStat stat;
        try {
          stat = await entity.stat();
        } on FileSystemException {
          continue;
        }
        final LocalFileEntryType type = _entryType(entity.path, entityType);

        entries.add(
          LocalFileEntry(
            name: name,
            path: entity.path,
            type: type,
            sizeBytes: entityType == FileSystemEntityType.file ? stat.size : 0,
            modifiedAt: stat.modified,
          ),
        );
      }
    } on FileSystemException catch (error) {
      throw FileAccessDeniedException(
        message: error.message,
      );
    }

    entries.sort(_compareEntries);
    return entries;
  }

  @override
  List<LocalPathSegment> buildBreadcrumbs(String path) {
    final String normalizedPath = _normalize(path);

    if (_isAndroidInternalPath(normalizedPath)) {
      return _buildAndroidBreadcrumbs(normalizedPath);
    }

    if (Platform.isWindows) {
      return _buildWindowsBreadcrumbs(normalizedPath);
    }

    return _buildUnixBreadcrumbs(normalizedPath);
  }

  @override
  String? parentOf(String path) {
    final String normalizedPath = _normalize(path);
    if (_isAndroidInternalRoot(normalizedPath)) {
      return null;
    }

    final Directory directory = Directory(path);
    final String parentPath = directory.parent.path;
    if (_normalize(parentPath) == normalizedPath) {
      return null;
    }

    return parentPath;
  }

  Iterable<String> _candidateInitialPaths() sync* {
    if (Platform.isAndroid) {
      yield '/storage/emulated/0/Download';
      yield '/storage/emulated/0/Downloads';
      yield _androidRootPath;
      yield '/sdcard/Download';
      yield '/sdcard';
    }

    if (Platform.isWindows) {
      final String? profile = Platform.environment['USERPROFILE'];
      if (profile != null && profile.isNotEmpty) {
        yield '$profile\\Downloads';
        yield profile;
      }
    }

    if (Platform.isMacOS || Platform.isLinux) {
      final String? home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        yield '$home/Downloads';
        yield home;
      }
    }
  }

  LocalFileEntryType _entryType(
    String path,
    FileSystemEntityType entityType,
  ) {
    if (entityType == FileSystemEntityType.directory) {
      return LocalFileEntryType.directory;
    }

    return path.toLowerCase().endsWith('.pdf')
        ? LocalFileEntryType.pdf
        : LocalFileEntryType.unsupported;
  }

  int _compareEntries(LocalFileEntry first, LocalFileEntry second) {
    final int rankCompare = _rank(first.type).compareTo(_rank(second.type));
    if (rankCompare != 0) {
      return rankCompare;
    }

    return first.name.toLowerCase().compareTo(second.name.toLowerCase());
  }

  int _rank(LocalFileEntryType type) {
    return switch (type) {
      LocalFileEntryType.directory => 0,
      LocalFileEntryType.pdf => 1,
      LocalFileEntryType.unsupported => 2,
    };
  }

  List<LocalPathSegment> _buildAndroidBreadcrumbs(String normalizedPath) {
    final List<LocalPathSegment> breadcrumbs = <LocalPathSegment>[
      const LocalPathSegment(
        label: 'Internal Storage',
        path: _androidRootPath,
      ),
    ];

    final String rest = normalizedPath
        .substring(_androidRootPath.length)
        .replaceFirst(RegExp(r'^/+'), '');
    if (rest.isEmpty) {
      return breadcrumbs;
    }

    String currentPath = _androidRootPath;
    for (final String segment in rest.split('/')) {
      if (segment.isEmpty) {
        continue;
      }

      currentPath = '$currentPath/$segment';
      breadcrumbs.add(LocalPathSegment(label: segment, path: currentPath));
    }

    return breadcrumbs;
  }

  List<LocalPathSegment> _buildWindowsBreadcrumbs(String normalizedPath) {
    final List<String> segments =
        normalizedPath.split('/').where((String part) => part.isNotEmpty).toList();
    if (segments.isEmpty) {
      return <LocalPathSegment>[
        LocalPathSegment(label: normalizedPath, path: pathFromNormalized(normalizedPath)),
      ];
    }

    final List<LocalPathSegment> breadcrumbs = <LocalPathSegment>[];
    String currentPath = '${segments.first}/';
    breadcrumbs.add(
      LocalPathSegment(label: segments.first, path: pathFromNormalized(currentPath)),
    );

    for (final String segment in segments.skip(1)) {
      currentPath = '$currentPath$segment/';
      breadcrumbs.add(
        LocalPathSegment(label: segment, path: pathFromNormalized(currentPath)),
      );
    }

    return breadcrumbs;
  }

  List<LocalPathSegment> _buildUnixBreadcrumbs(String normalizedPath) {
    final List<LocalPathSegment> breadcrumbs = <LocalPathSegment>[
      const LocalPathSegment(label: 'Root', path: '/'),
    ];
    final String rest = normalizedPath.replaceFirst(RegExp(r'^/+'), '');
    if (rest.isEmpty) {
      return breadcrumbs;
    }

    String currentPath = '';
    for (final String segment in rest.split('/')) {
      if (segment.isEmpty) {
        continue;
      }

      currentPath = '$currentPath/$segment';
      breadcrumbs.add(LocalPathSegment(label: segment, path: currentPath));
    }

    return breadcrumbs;
  }

  String _basename(String path) {
    final String normalizedPath = _normalize(path);
    final List<String> parts =
        normalizedPath.split('/').where((String part) => part.isNotEmpty).toList();
    return parts.isEmpty ? normalizedPath : parts.last;
  }

  String _normalize(String path) => path.replaceAll('\\', '/');

  String pathFromNormalized(String normalizedPath) {
    return Platform.isWindows ? normalizedPath.replaceAll('/', '\\') : normalizedPath;
  }

  bool _isAndroidInternalPath(String normalizedPath) {
    return normalizedPath == _androidRootPath ||
        normalizedPath.startsWith('$_androidRootPath/');
  }

  bool _isAndroidInternalRoot(String normalizedPath) {
    return Platform.isAndroid && normalizedPath == _androidRootPath;
  }
}
