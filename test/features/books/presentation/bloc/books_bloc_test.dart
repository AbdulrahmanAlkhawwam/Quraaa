import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/books/books.dart';

void main() {
  group('BooksBloc', () {
    late BooksBloc bloc;

    setUp(() {
      bloc = BooksBloc(
        getBooks: GetBooksUseCase(
          BooksRepositoryImpl(const BooksMockRemoteDataSourceImpl()),
        ),
      );
    });

    tearDown(() => bloc.close());

    test('loads the temporary endpoint catalogue', () async {
      bloc.add(const BooksRequested());
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(bloc.state.status, BooksStatus.success);
      expect(bloc.state.books, isNotEmpty);
    });

    test('filters catalogue after a query change', () async {
      bloc.add(const BooksQueryChanged('Learner'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(bloc.state.books.single.subtitle, 'Learner’s Book 8');
    });
  });
}
