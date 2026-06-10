import 'local_file_entry.dart';

class LocalDirectorySnapshot {
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
}

class LocalPathSegment {
  const LocalPathSegment({
    required this.label,
    required this.path,
  });

  final String label;
  final String path;
}
