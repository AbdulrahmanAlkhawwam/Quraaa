import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/favorites/domain/entities/favorite_book.dart';
import 'package:quraaa/features/favorites/domain/repositories/favorite_books_repository.dart';
import 'package:quraaa/features/favorites/domain/use_cases/add_favorite_book_use_case.dart';
import 'package:quraaa/features/favorites/domain/use_cases/is_favorite_book_use_case.dart';
import 'package:quraaa/features/favorites/domain/use_cases/remove_favorite_book_use_case.dart';
import 'package:quraaa/features/favorites/presentation/logic/favorite_status_cubit.dart';

class _MockRepository extends Mock implements FavoriteBooksRepository {}

void main() {
  late _MockRepository repository;
  late FavoriteStatusCubit cubit;

  const FavoriteBook favorite = FavoriteBook(
    favoriteId: 'fav-1',
    bookId: 'book-1',
    title: 'Book',
    author: '',
    description: '',
    coverImageUrl: '',
    categoryId: '',
    language: 'ar',
    isbn: '',
    favoritedAt: null,
  );

  setUp(() {
    repository = _MockRepository();
    cubit = FavoriteStatusCubit(
      isFavoriteBook: IsFavoriteBookUseCase(repository),
      addFavorite: AddFavoriteBookUseCase(repository),
      removeFavorite: RemoveFavoriteBookUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  test('load shows the failure message', () async {
    when(() => repository.isFavorite('book-1')).thenAnswer(
      (_) async => const Left(NetworkFailure(message: 'offline')),
    );

    await cubit.load('book-1');

    expect(cubit.state.isFavorite, isFalse);
    expect(cubit.state.error, 'offline');
  });

  test('toggle adds a book that is not a favorite yet', () async {
    when(
      () => repository.addFavorite('book-1'),
    ).thenAnswer((_) async => const Right(favorite));

    await cubit.toggle('book-1');

    expect(cubit.state.isFavorite, isTrue);
    expect(cubit.state.error, isNull);
  });

  test('a failed removal keeps the book marked as favorite', () async {
    when(
      () => repository.isFavorite('book-1'),
    ).thenAnswer((_) async => const Right(true));
    when(() => repository.removeFavorite('book-1')).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'try later')),
    );
    await cubit.load('book-1');

    await cubit.toggle('book-1');

    expect(cubit.state.isFavorite, isTrue);
    expect(cubit.state.error, 'try later');
  });
}
