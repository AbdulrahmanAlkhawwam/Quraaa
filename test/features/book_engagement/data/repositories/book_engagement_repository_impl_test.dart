import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/book_engagement/book_engagement.dart';

class _MockRemote extends Mock implements BookEngagementRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late BookEngagementRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = BookEngagementRepositoryImpl(remote);
  });

  test('no review of my own is a successful null, not a failure', () async {
    when(() => remote.getMyReview('book-1')).thenAnswer((_) async => null);

    expect(
      await repository.getMyReview('book-1'),
      const Right<Failure, BookComment?>(null),
    );
  });

  test('a completed write returns unit', () async {
    when(() => remote.deleteReview('book-1')).thenAnswer((_) async {});

    expect(
      await repository.deleteReview('book-1'),
      const Right<Failure, Unit>(unit),
    );
  });

  test('a thrown backend error becomes a typed failure', () async {
    when(
      () => remote.report('book-1', 2, null),
    ).thenThrow(const ForbiddenException(message: 'already reported'));

    final Either<Failure, Unit> result = await repository.report(
      'book-1',
      2,
      null,
    );

    expect(result.getLeft().toNullable(), isA<ForbiddenFailure>());
  });
}
