import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/books/books.dart';

class _FakeBooksRepository implements BooksRepository {
  @override
  Future<List<Book>> getBooks({
    String query = '',
    BookFormat? format,
  }) async {
    return const <Book>[
      Book(
        id: '1',
        title: 'Global English Course Book 10',
        author: 'Cambridge',
        price: '15',
        format: BookFormat.audio,
      ),
      Book(
        id: '2',
        title: 'Global English Learners Book 8',
        author: 'Cambridge',
        price: '9',
        format: BookFormat.used,
      ),
    ];
  }
}

void main() {
  group('BooksBloc', () {
    late BooksBloc bloc;

    setUp(() {
      bloc = BooksBloc(
        getBooks: GetBooksUseCase(_FakeBooksRepository()),
      );
    });

    tearDown(() => bloc.close());

    test('loads the home catalog', () async {
      final Future<void> expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          isA<BooksState>().having(
            (BooksState state) => state.status,
            'status',
            BooksStatus.loading,
          ),
          isA<BooksState>()
              .having(
                (BooksState state) => state.status,
                'status',
                BooksStatus.success,
              )
              .having(
                (BooksState state) => state.books.length,
                'books length',
                2,
              ),
        ]),
      );

      bloc.add(const BooksRequested());
      await expectation;
    });

    test('filters the loaded catalog without another request', () async {
      bloc.add(const BooksRequested());
      await bloc.stream.firstWhere(
        (BooksState state) => state.status == BooksStatus.success,
      );

      bloc.add(const BooksQueryChanged('Learners'));
      await bloc.stream.firstWhere(
        (BooksState state) => state.query == 'Learners',
      );
      expect(bloc.state.books.single.id, '2');

      bloc.add(const BooksFilterChanged(BookFormat.audio));
      await bloc.stream.firstWhere(
        (BooksState state) => state.format == BookFormat.audio,
      );
      expect(bloc.state.books, isEmpty);
    });
  });
}
