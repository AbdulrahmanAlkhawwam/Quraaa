import 'dart:convert';

import '../../../../core/constants/app_storage_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/explorer_history_entry.dart';
import '../../domain/entities/local_file_entry.dart';
import '../../domain/repositories/explorer_history_repository.dart';
import '../datasources/local/local_file_system_datasource.dart';
import '../models/explorer_history_entry_model.dart';

class ExplorerHistoryRepositoryImpl implements ExplorerHistoryRepository {
  const ExplorerHistoryRepositoryImpl({
    required StorageService storageService,
    required LocalFileSystemDataSource fileSystemDataSource,
  }) : _storageService = storageService,
       _fileSystemDataSource = fileSystemDataSource;

  static const int _maximumEntries = 40;

  final StorageService _storageService;
  final LocalFileSystemDataSource _fileSystemDataSource;

  @override
  Future<List<ExplorerHistoryEntry>> loadHistory() async {
    final String? raw = _storageService.getString(
      AppStorageKeys.explorerHistory,
    );
    if (raw == null || raw.trim().isEmpty) {
      return const <ExplorerHistoryEntry>[];
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const <ExplorerHistoryEntry>[];
      }
      final List<ExplorerHistoryEntry> entries =
          decoded
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> item) =>
                    ExplorerHistoryEntryModel.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
              )
              .where(
                (ExplorerHistoryEntry entry) =>
                    entry.path.trim().isNotEmpty &&
                    entry.name.trim().isNotEmpty,
              )
              .toList(growable: false)
            ..sort(
              (ExplorerHistoryEntry first, ExplorerHistoryEntry second) =>
                  second.openedAt.compareTo(first.openedAt),
            );
      return entries;
    } catch (_) {
      return const <ExplorerHistoryEntry>[];
    }
  }

  @override
  Future<void> recordOpenedFile(LocalFileEntry entry) async {
    if (!entry.isPdf) return;

    final List<ExplorerHistoryEntry> current = await loadHistory();
    final List<ExplorerHistoryEntryModel> updated = <ExplorerHistoryEntryModel>[
      ExplorerHistoryEntryModel.fromFileEntry(entry, openedAt: DateTime.now()),
      ...current
          .where((ExplorerHistoryEntry item) => item.path != entry.path)
          .map(
            (ExplorerHistoryEntry item) => ExplorerHistoryEntryModel(
              name: item.name,
              path: item.path,
              directoryName: item.directoryName,
              openedAt: item.openedAt,
            ),
          ),
    ].take(_maximumEntries).toList(growable: false);

    await _persist(updated);
  }

  @override
  Future<bool> fileExists(String path) =>
      _fileSystemDataSource.fileExists(path);

  @override
  Future<void> removeEntry(String path) async {
    final List<ExplorerHistoryEntryModel> updated = (await loadHistory())
        .where((ExplorerHistoryEntry entry) => entry.path != path)
        .map(
          (ExplorerHistoryEntry entry) => ExplorerHistoryEntryModel(
            name: entry.name,
            path: entry.path,
            directoryName: entry.directoryName,
            openedAt: entry.openedAt,
          ),
        )
        .toList(growable: false);
    await _persist(updated);
  }

  Future<void> _persist(List<ExplorerHistoryEntryModel> entries) async {
    await _storageService.setString(
      AppStorageKeys.explorerHistory,
      jsonEncode(
        entries
            .map((ExplorerHistoryEntryModel entry) => entry.toJson())
            .toList(growable: false),
      ),
    );
  }
}
