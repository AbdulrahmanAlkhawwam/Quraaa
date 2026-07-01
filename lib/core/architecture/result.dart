sealed class Result<T> {
  const Result();

  /// Applies [onFailure] to a [ResultFailure] or [onSuccess] to a [Success].
  R fold<R>(
    R Function(ResultFailure<T> failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    return switch (this) {
      Success<T>(value: final value) => onSuccess(value),
      ResultFailure<T>() => onFailure(this as ResultFailure<T>),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.message, {this.cause});

  final String message;
  final Object? cause;
}
