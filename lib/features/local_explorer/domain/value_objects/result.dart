import '../../../../core/errors/failures.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}

extension ResultFold<T> on Result<T> {
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(value: final T value) => onSuccess(value),
      ResultFailure<T>(failure: final Failure failure) => onFailure(failure),
    };
  }
}
