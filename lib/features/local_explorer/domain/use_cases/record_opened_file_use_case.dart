import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/local_file_entry.dart';
import '../repositories/explorer_history_repository.dart';

/// Adds a freshly opened PDF to the reading history.
class RecordOpenedFileUseCase extends UseCase<Unit, LocalFileEntry> {
  const RecordOpenedFileUseCase(this._repository);

  final ExplorerHistoryRepository _repository;

  @override
  FutureEither<Unit> call(LocalFileEntry params) =>
      _repository.recordOpenedFile(params);
}
