import 'dart:convert';

import '../services/storage_service.dart';
import 'error_report.dart';

/// Stores [ErrorReport]s that could not be sent because the device was offline.
///
/// Reports are kept as a JSON string list in local storage. Callers are expected
/// to [flush] them when connectivity is available and then [clear] the cache.
class ErrorReportCache {
  ErrorReportCache(this._storage);

  final StorageService _storage;

  static const String _key = 'offline_error_reports';

  Future<void> add(ErrorReport report) async {
    final List<String> reports = _storage.getStringList(_key) ?? <String>[];
    reports.add(jsonEncode(report.toJson()));
    await _storage.setStringList(_key, reports);
  }

  Future<List<ErrorReport>> getAll() async {
    final List<String> reports = _storage.getStringList(_key) ?? <String>[];
    return reports
        .map((String raw) {
          try {
            return ErrorReport.fromJson(
              jsonDecode(raw) as Map<String, Object?>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<ErrorReport>()
        .toList(growable: false);
  }

  Future<void> clear() => _storage.remove(_key);
}
