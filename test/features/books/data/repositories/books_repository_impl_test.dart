import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/books/books.dart';

class _MockRemote extends Mock implements BooksRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late BooksRepositoryImpl repository;

  HomeCatalogBookModel model({
    required String id,
    required String title,
    required String author,
    required BookFormat format,
  }) => HomeCatalogBookModel(
    id: id,
    listingId: 'listing-$id',
    title: title,
    subtitle: '',
    author: author,
    description: '',
    price: '10',
    format: format,
    coverImageUrl: '',
    language: 'ar',
    isbn: '',
    categoryId: '',
    publisher: '',
    version: '',
    condition: null,
    previewImageUrls: const <String>[],
  );

  final HomeCatalogBookModel arabic = model(
    id: 'book-1',
    title: 'Arabic Grammar',
    author: 'Sibawayh',
    format: BookFormat.used,
  );
  final HomeCatalogBookModel english = model(
    id: 'book-2',
    title: 'English Reader',
    author: 'Carter',
    format: BookFormat.audio,
  );

  setUpAll(() => registerFallbackValue(const BookCatalogFilter()));

  setUp(() {
    remote = _MockRemote();
    repository = BooksRepositoryImpl(remote);
    when(
      () => remote.fetchHomeCatalog(
        filter: any(named: 'filter'),
        query: any(named: 'query'),
      ),
    ).thenAnswer((_) async => <HomeCatalogBookModel>[arabic, english]);
  });

  test('filters the catalog by free text', () async {
    final Either<Failure, List<Book>> result = await repository.getBooks(
      query: 'grammar',
    );

    expect(
      result.getOrElse((_) => fail('expected Right')).single.id,
      'book-1',
    );
  });

  test('filters the catalog by format', () async {
    final Either<Failure, List<Book>> result = await repository.getBooks(
      format: BookFormat.audio,
    );

    expect(
      result.getOrElse((_) => fail('expected Right')).single.id,
      'book-2',
    );
  });

  test('returns a failure instead of throwing', () async {
    when(
      () => remote.fetchHomeCatalog(
        filter: any(named: 'filter'),
        query: any(named: 'query'),
      ),
    ).thenThrow(const NoInternetException());

    final Either<Failure, List<Book>> result = await repository.getBooks();

    expect(result.getLeft().toNullable(), isA<NoInternetFailure>());
  });
}
