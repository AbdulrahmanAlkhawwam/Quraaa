import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/local_directory_snapshot.dart';

abstract class LocalFileRepository {
  FutureEither<bool> hasStorageAccess();

  FutureEither<bool> requestStorageAccess();

  FutureEither<LocalDirectorySnapshot> loadDirectory({String? path});

  /// Parent of [path], or `null` at the root. Synchronous: it is pure path
  /// arithmetic with no I/O.
  Either<Failure, String?> parentOf(String path);
}
