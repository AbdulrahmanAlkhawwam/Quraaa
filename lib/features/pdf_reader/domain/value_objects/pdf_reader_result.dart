import '../../../../core/errors/failures.dart';

sealed class PdfReaderResult<T> {
  const PdfReaderResult();
}

final class PdfReaderSuccess<T> extends PdfReaderResult<T> {
  const PdfReaderSuccess(this.value);

  final T value;
}

final class PdfReaderFailure<T> extends PdfReaderResult<T> {
  const PdfReaderFailure(this.failure);

  final Failure failure;
}

extension PdfReaderResultFold<T> on PdfReaderResult<T> {
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      PdfReaderSuccess<T>(value: final T value) => onSuccess(value),
      PdfReaderFailure<T>(failure: final Failure failure) =>
        onFailure(failure),
    };
  }
}
