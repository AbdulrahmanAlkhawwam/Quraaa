import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/explorer_history_entry.dart';
import '../entities/local_file_entry.dart';

abstract class ExplorerHistoryRepository {
  FutureEither<List<ExplorerHistoryEntry>> loadHistory();

  FutureEither<Unit> recordOpenedFile(LocalFileEntry entry);

  /// Whether the file behind a history entry is still on disk.
  FutureEither<bool> fileExists(String path);

  FutureEither<Unit> removeEntry(String path);
}
