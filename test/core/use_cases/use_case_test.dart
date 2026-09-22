import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/core/use_cases/use_case.dart';

class _Double extends UseCase<int, int> {
  const _Double();

  @override
  FutureEither<int> call(int params) async {
    if (params < 0) return const Left(UnknownFailure(message: 'negative'));
    return Right(params * 2);
  }
}

class _Answer extends NoParamsUseCase<int> {
  const _Answer();

  @override
  FutureEither<int> call() async => const Right(42);
}

class _Parse extends SyncUseCase<int, String> {
  const _Parse();

  @override
  Either<Failure, int> call(String params) {
    final int? value = int.tryParse(params);
    return value == null
        ? const Left(UnknownFailure(message: 'not a number'))
        : Right(value);
  }
}

class _Countdown extends StreamUseCase<int, int> {
  const _Countdown();

  @override
  Stream<Either<Failure, int>> call(int params) async* {
    for (int i = params; i > 0; i--) {
      yield Right(i);
    }
  }
}

void main() {
  test('async use case returns Right on success and Left on failure', () async {
    expect(await const _Double()(3), const Right<Failure, int>(6));
    final Either<Failure, int> failed = await const _Double()(-1);
    expect(failed.getLeft().toNullable(), isA<UnknownFailure>());
  });

  test('no-params use case is invoked like a function', () async {
    expect(await const _Answer()(), const Right<Failure, int>(42));
  });

  test('sync use case maps invalid input to a failure', () {
    expect(const _Parse()('7'), const Right<Failure, int>(7));
    expect(const _Parse()('x').isLeft(), isTrue);
  });

  test('stream use case emits each value', () async {
    final List<int> values = await const _Countdown()(3)
        .map((Either<Failure, int> e) => e.getOrElse((_) => -1))
        .toList();
    expect(values, <int>[3, 2, 1]);
  });
}
