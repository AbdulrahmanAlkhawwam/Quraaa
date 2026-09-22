import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/sell_book/data/data_sources/sell_book_remote_data_source.dart';
import 'package:quraaa/features/sell_book/data/repositories/sell_book_repository_impl.dart';
import 'package:quraaa/features/sell_book/domain/entities/my_listing.dart';
import 'package:quraaa/features/sell_book/domain/entities/sell_book.dart';

class _MockRemote extends Mock implements SellBookRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late SellBookRepositoryImpl repository;

  const SellBookDraft draft = SellBookDraft(
    method: SellBookMethod.isbn,
    price: 10,
    condition: SellBookCondition.used,
    images: <SellBookImage>[],
    isbn: '9780306406157',
  );

  setUpAll(() => registerFallbackValue(draft));

  setUp(() {
    remote = _MockRemote();
    repository = SellBookRepositoryImpl(remote);
  });

  test('submit returns the new listing id', () async {
    when(
      () => remote.submitPhysicalBook(draft),
    ).thenAnswer((_) async => 'listing-1');

    expect(
      await repository.submit(draft),
      const Right<Failure, String>('listing-1'),
    );
  });

  test('a rejected submission becomes a typed failure', () async {
    when(
      () => remote.submitPhysicalBook(any()),
    ).thenThrow(const ValidationException(message: 'price required'));

    final Either<Failure, String> result = await repository.submit(draft);

    expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    expect(result.getLeft().toNullable()!.message, 'price required');
  });

  test('listings pass through with the query', () async {
    when(
      () => remote.getMyListings(query: 'grammar'),
    ).thenAnswer((_) async => const <MyListing>[]);

    final Either<Failure, List<MyListing>> result = await repository
        .getMyListings(query: 'grammar');

    expect(result.isRight(), isTrue);
    verify(() => remote.getMyListings(query: 'grammar')).called(1);
  });

  test('ISBN lookup is not wired to the API yet', () async {
    expect(
      await repository.findByIsbn('9780306406157'),
      const Right<Failure, SellBookPreview?>(null),
    );
  });
}
