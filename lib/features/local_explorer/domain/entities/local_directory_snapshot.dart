import 'package:equatable/equatable.dart';

import 'local_file_entry.dart';

class LocalDirectorySnapshot extends Equatable {
  const LocalDirectorySnapshot({
    required this.currentPath,
    required this.breadcrumbs,
    required this.entries,
  });

  final String currentPath;
  final List<LocalPathSegment> breadcrumbs;
  final List<LocalFileEntry> entries;

  String get title {
    if (breadcrumbs.isEmpty) {
      return currentPath;
    }

    return breadcrumbs.last.label;
  }

  bool get canNavigateUp => breadcrumbs.length > 1;

  @override
  List<Object?> get props => <Object?>[
        currentPath,
        breadcrumbs,
        entries,
      ];
}

class LocalPathSegment extends Equatable {
  const LocalPathSegment({
    required this.label,
    required this.path,
  });

  final String label;
  final String path;

  @override
  List<Object?> get props => <Object?>[label, path];
}
