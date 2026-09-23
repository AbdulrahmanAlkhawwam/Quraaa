import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/features/home/data/data_sources/home_books_remote_data_source.dart';
import 'package:quraaa/features/home/data/models/home_book_model.dart';
import 'package:quraaa/features/home/data/models/paginated_home_books_response_model.dart';
import 'package:quraaa/features/home/data/repositories/home_books_repository_impl.dart';
import 'package:quraaa/features/home/domain/entities/home_books_page.dart';

class _MockHomeBooksRemoteDataSource extends Mock
    implements HomeBooksRemoteDataSource {}

void main() {
  late _MockHomeBooksRemoteDataSource remoteDataSource;
  late HomeBooksRepositoryImpl repository;

  const PaginatedHomeBooksResponseModel response =
      PaginatedHomeBooksResponseModel(
    items: <HomeBookModel>[
      HomeBookModel(
        listingId: 'listing-id',
        title: 'Book title',
        author: 'Author',
        description: 'Description',
        coverImageUrl: 'https://example.com/cover.jpg',
        categoryId: 'category-id',
        language: 'ar',
        isbn: '123',
        purchaseCount: '2',
        ratingCount: '3',
        averageRating: '4.5',
        activeListingCount: '1',
      ),
    ],
    pageNumber: '1',
    pageSize: '10',
    totalCount: '1',
    totalPages: '1',
    hasNextPage: false,
    hasPreviousPage: false,
  );

  setUp(() {
    remoteDataSource = _MockHomeBooksRemoteDataSource();
    repository = HomeBooksRepositoryImpl(remoteDataSource);
  });

  test('maps recommended response models to domain entities', () async {
    when(
      remoteDataSource.getRecommendedBooks,
    ).thenAnswer((_) async => response);

    final Either<Failure, HomeBooksPage> result =
        await repository.getRecommendedBooks();

    expect(result.isRight(), isTrue);
    final HomeBooksPage page = result.getOrElse((_) => fail('expected Right'));
    expect(page.items.single.listingId, 'listing-id');
    expect(page.items.single.averageRating, '4.5');
  });

  test('returns a typed failure when the request throws', () async {
    when(
      remoteDataSource.getMostPopularBooks,
    ).thenThrow(const UnknownException(message: 'Network error'));

    final Either<Failure, HomeBooksPage> result =
        await repository.getMostPopularBooks();

    expect(result.isLeft(), isTrue);
    expect(result.getLeft().toNullable()!.message, 'Network error');
  });
}
