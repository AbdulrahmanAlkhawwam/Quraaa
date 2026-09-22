import 'package:fpdart/fpdart.dart';

import '../errors/failures.dart';

/// The result every repository and use case returns: a typed [Failure] on the
/// left, the value on the right.
typedef FutureEither<T> = Future<Either<Failure, T>>;

/// Async use case with parameters. Invoke it like a function: `await login(p)`.
abstract class UseCase<T, Params> {
  const UseCase();

  FutureEither<T> call(Params params);
}

/// Async use case without parameters.
abstract class NoParamsUseCase<T> {
  const NoParamsUseCase();

  FutureEither<T> call();
}

/// Synchronous use case with parameters, for work that never awaits
/// (validation, formatting of domain values).
abstract class SyncUseCase<T, Params> {
  const SyncUseCase();

  Either<Failure, T> call(Params params);
}

/// Synchronous use case without parameters.
abstract class SyncNoParamsUseCase<T> {
  const SyncNoParamsUseCase();

  Either<Failure, T> call();
}

/// Use case that emits over time (sync status, connectivity, live queries).
abstract class StreamUseCase<T, Params> {
  const StreamUseCase();

  Stream<Either<Failure, T>> call(Params params);
}
