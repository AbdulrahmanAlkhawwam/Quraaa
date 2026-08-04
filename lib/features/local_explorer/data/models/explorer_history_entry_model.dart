import '../../domain/entities/explorer_history_entry.dart';
import '../../domain/entities/local_file_entry.dart';

class ExplorerHistoryEntryModel extends ExplorerHistoryEntry {
  const ExplorerHistoryEntryModel({
    required super.name,
    required super.path,
    required super.directoryName,
    required super.openedAt,
  });

  factory ExplorerHistoryEntryModel.fromFileEntry(
    LocalFileEntry entry, {
    required DateTime openedAt,
  }) {
    return ExplorerHistoryEntryModel(
      name: entry.name,
      path: entry.path,
      directoryName: _directoryName(entry.path),
      openedAt: openedAt,
    );
  }

  factory ExplorerHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return ExplorerHistoryEntryModel(
      name: json['name']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      directoryName: json['directoryName']?.toString() ?? '',
      openedAt:
          DateTime.tryParse(json['openedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'path': path,
    'directoryName': directoryName,
    'openedAt': openedAt.toIso8601String(),
  };

  static String _directoryName(String filePath) {
    final String normalized = filePath.replaceAll('\\', '/');
    final List<String> segments = normalized
        .split('/')
        .where((String segment) => segment.trim().isNotEmpty)
        .toList(growable: false);
    if (segments.length < 2) {
      return 'Internal Storage';
    }

    final String parent = segments[segments.length - 2];
    if (parent == '0' && normalized.startsWith('/storage/emulated/0/')) {
      return 'Internal Storage';
    }
    return parent;
  }
}
