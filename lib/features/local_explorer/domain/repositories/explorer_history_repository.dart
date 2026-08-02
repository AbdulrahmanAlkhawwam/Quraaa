import '../entities/explorer_history_entry.dart';
import '../entities/local_file_entry.dart';

abstract class ExplorerHistoryRepository {
  Future<List<ExplorerHistoryEntry>> loadHistory();

  Future<void> recordOpenedFile(LocalFileEntry entry);

  Future<bool> fileExists(String path);

  Future<void> removeEntry(String path);
}
