import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/explorer_history_entry.dart';
import '../../domain/entities/local_file_entry.dart';
import '../../domain/repositories/explorer_history_repository.dart';
import '../data_sources/local/local_file_system_data_source.dart';
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
  FutureEither<List<ExplorerHistoryEntry>> loadHistory() async {
    return Right(await _loadHistory());
  }

  @override
  FutureEither<Unit> recordOpenedFile(LocalFileEntry entry) {
    return _guardUnit(() async {
      if (!entry.isPdf) return;

      final List<ExplorerHistoryEntry> current = await _loadHistory();
      final List<ExplorerHistoryEntryModel> updated =
          <ExplorerHistoryEntryModel>[
            ExplorerHistoryEntryModel.fromFileEntry(
              entry,
              openedAt: DateTime.now(),
            ),
            ...current
                .where((ExplorerHistoryEntry item) => item.path != entry.path)
                .map(_toModel),
          ].take(_maximumEntries).toList(growable: false);

      await _persist(updated);
    });
  }

  @override
  FutureEither<bool> fileExists(String path) async {
    try {
      return Right(await _fileSystemDataSource.fileExists(path));
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  FutureEither<Unit> removeEntry(String path) {
    return _guardUnit(() async {
      final List<ExplorerHistoryEntryModel> updated = (await _loadHistory())
          .where((ExplorerHistoryEntry entry) => entry.path != path)
          .map(_toModel)
          .toList(growable: false);
      await _persist(updated);
    });
  }

  /// An unreadable or malformed history reads as empty rather than failing:
  /// the list is a convenience, not data the user can lose.
  Future<List<ExplorerHistoryEntry>> _loadHistory() async {
    final String? raw = _storageService.getString(StorageKeys.explorerHistory);
    if (raw == null || raw.trim().isEmpty) {
      return const <ExplorerHistoryEntry>[];
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const <ExplorerHistoryEntry>[];
      }
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> item) => ExplorerHistoryEntryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where(
            (ExplorerHistoryEntry entry) =>
                entry.path.trim().isNotEmpty && entry.name.trim().isNotEmpty,
          )
          .toList(growable: false)
        ..sort(
          (ExplorerHistoryEntry first, ExplorerHistoryEntry second) =>
              second.openedAt.compareTo(first.openedAt),
        );
    } catch (_) {
      return const <ExplorerHistoryEntry>[];
    }
  }

  ExplorerHistoryEntryModel _toModel(ExplorerHistoryEntry entry) =>
      ExplorerHistoryEntryModel(
        name: entry.name,
        path: entry.path,
        directoryName: entry.directoryName,
        openedAt: entry.openedAt,
      );

  Future<void> _persist(List<ExplorerHistoryEntryModel> entries) async {
    await _storageService.setString(
      StorageKeys.explorerHistory,
      jsonEncode(
        entries
            .map((ExplorerHistoryEntryModel entry) => entry.toJson())
            .toList(growable: false),
      ),
    );
  }

  FutureEither<Unit> _guardUnit(Future<void> Function() body) async {
    try {
      await body();
      return const Right(unit);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}
