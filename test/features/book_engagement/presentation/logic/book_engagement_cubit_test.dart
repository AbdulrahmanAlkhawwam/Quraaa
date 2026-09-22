import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/book_engagement/book_engagement.dart';

class _MockRepository extends Mock implements BookEngagementRepository {}

void main() {
  late _MockRepository repository;
  late BookEngagementCubit cubit;

  const BookComment review = BookComment(
    id: 'r1',
    userId: 'u1',
    name: 'Reader',
    content: 'Useful',
    score: 4,
    createdAt: null,
  );
  const BookRatingSummary rating = BookRatingSummary(average: 4, count: 1);

  setUp(() {
    repository = _MockRepository();
    cubit = BookEngagementCubit(
      bookId: 'book-1',
      getComments: GetBookCommentsUseCase(repository),
      getRating: GetBookRatingUseCase(repository),
      getReportReasons: GetBookReportReasonsUseCase(repository),
      getMyReview: GetMyBookReviewUseCase(repository),
      addReview: AddBookReviewUseCase(repository),
      updateReview: UpdateBookReviewUseCase(repository),
      deleteReview: DeleteBookReviewUseCase(repository),
      reportBook: ReportBookUseCase(repository),
    );
    when(
      () => repository.getComments('book-1'),
    ).thenAnswer((_) async => const Right(<BookComment>[review]));
    when(
      () => repository.getRating('book-1'),
    ).thenAnswer((_) async => const Right(rating));
    when(
      () => repository.getReportReasons(),
    ).thenAnswer((_) async => const Right(<BookReportReason>[]));
    when(
      () => repository.getMyReview('book-1'),
    ).thenAnswer((_) async => const Right(null));
  });

  tearDown(() => cubit.close());

  test('load fills every section', () async {
    await cubit.load();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.comments, <BookComment>[review]);
    expect(cubit.state.rating, rating);
    expect(cubit.state.error, isNull);
  });

  test('a failed section keeps its previous value and reports the message',
      () async {
    await cubit.load();
    when(() => repository.getRating('book-1')).thenAnswer(
      (_) async => const Left(NetworkFailure(message: 'offline')),
    );

    await cubit.load();

    expect(cubit.state.rating, rating);
    expect(cubit.state.comments, <BookComment>[review]);
    expect(cubit.state.error, 'offline');
  });

  test('a saved review bumps actionSerial and reloads', () async {
    when(
      () => repository.addReview('book-1', 5, 'Great'),
    ).thenAnswer((_) async => const Right(unit));

    await cubit.addReview(score: 5, comment: '  Great  ');

    expect(cubit.state.actionSerial, 1);
    expect(cubit.state.saving, isFalse);
    verify(() => repository.getComments('book-1')).called(1);
  });

  test('a failed review shows the message and does not reload', () async {
    when(() => repository.addReview('book-1', 5, 'Great')).thenAnswer(
      (_) async => const Left(ValidationFailure(message: 'too short')),
    );

    await cubit.addReview(score: 5, comment: 'Great');

    expect(cubit.state.error, 'too short');
    expect(cubit.state.actionSerial, 0);
    verifyNever(() => repository.getComments(any()));
  });
}
