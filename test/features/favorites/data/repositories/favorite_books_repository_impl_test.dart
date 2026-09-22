import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/favorites/data/data_sources/favorite_books_remote_data_source.dart';
import 'package:quraaa/features/favorites/data/models/favorite_book_model.dart';
import 'package:quraaa/features/favorites/data/repositories/favorite_books_repository_impl.dart';

class _MockRemote extends Mock implements FavoriteBooksRemoteDataSource {}

FavoriteBookModel _book(String id) => FavoriteBookModel(
  favoriteId: 'fav-$id',
  bookId: id,
  title: 'Book $id',
  author: '',
  description: '',
  coverImageUrl: '',
  categoryId: '',
  language: 'ar',
  isbn: '',
  favoritedAt: null,
);

FavoriteBooksPageModel _page(
  List<String> ids, {
  required int number,
  required bool hasNext,
}) => FavoriteBooksPageModel(
  items: ids.map(_book).toList(),
  pageNumber: number,
  pageSize: 100,
  totalCount: 0,
  totalPages: 0,
  hasNextPage: hasNext,
  hasPreviousPage: number > 1,
);

void main() {
  late _MockRemote remote;
  late FavoriteBooksRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = FavoriteBooksRepositoryImpl(remote);
  });

  void stubPage(int number, List<String> ids, {required bool hasNext}) {
    when(
      () => remote.getFavoriteBooks(
        pageNumber: number,
        pageSize: 100,
        searchTerm: '',
      ),
    ).thenAnswer((_) async => _page(ids, number: number, hasNext: hasNext));
  }

  group('isFavorite', () {
    test('pages until it finds the book, then answers from memory', () async {
      stubPage(1, <String>['a'], hasNext: true);
      stubPage(2, <String>['b'], hasNext: false);

      expect(await repository.isFavorite('b'), const Right<Failure, bool>(true));
      expect(await repository.isFavorite('a'), const Right<Failure, bool>(true));

      verify(
        () => remote.getFavoriteBooks(
          pageNumber: any(named: 'pageNumber'),
          pageSize: 100,
          searchTerm: '',
        ),
      ).called(2);
    });

    test('is false after the last page', () async {
      stubPage(1, <String>['a'], hasNext: false);

      expect(
        await repository.isFavorite('z'),
        const Right<Failure, bool>(false),
      );
    });

    test('forgets a removed book so the next check asks the backend',
        () async {
      stubPage(1, <String>['a'], hasNext: false);
      when(() => remote.removeFavorite('a')).thenAnswer((_) async {});
      await repository.isFavorite('a');

      await repository.removeFavorite('a');
      stubPage(1, <String>[], hasNext: false);

      expect(
        await repository.isFavorite('a'),
        const Right<Failure, bool>(false),
      );
    });
  });

  test('maps a backend error to a typed failure', () async {
    when(
      () => remote.addFavorite('a'),
    ).thenThrow(const UnauthorizedException(message: 'sign in'));

    final result = await repository.addFavorite('a');

    expect(result.getLeft().toNullable(), isA<UnauthorizedFailure>());
  });
}
