import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:quraaa/core/di/injection_container.dart';
import 'package:quraaa/features/books/books.dart';
import 'package:quraaa/features/home/home.dart';

class _FakeBooksRepository implements BooksRepository {
  @override
  Future<List<Book>> getBooks({
    String query = '',
    BookFormat? format,
    BookCatalogFilter catalogFilter = const BookCatalogFilter(),
  }) async {
    return const <Book>[
      Book(
        id: 'book-1',
        listingId: 'listing-1',
        title: 'Global English Course Book 10',
        price: '15',
        format: BookFormat.audio,
      ),
    ];
  }
}

void main() {
  setUpAll(() {
    EasyLocalization.logger.enableLevels = const [];
  });

  setUp(() {
    sl.registerFactory<BooksBloc>(
      () => BooksBloc(
        getBooks: GetBooksUseCase(_FakeBooksRepository()),
      ),
    );
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('shows search, format filters, and the catalog grid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BooksScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(HomeAppBar), findsOneWidget);
    expect(find.byKey(const Key('books_search_field')), findsOneWidget);
    final TextField searchField = tester.widget<TextField>(
      find.byKey(const Key('books_search_field')),
    );
    expect(searchField.decoration?.filled, isFalse);
    expect(searchField.decoration?.fillColor, Colors.transparent);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byKey(const Key('books_filter_button')), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(4));
    expect(find.byKey(const Key('books_catalog_grid')), findsOneWidget);
    expect(find.text('Global English Course Book 10'), findsOneWidget);
  });

  testWidgets('opens the catalog filter bottom sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BooksScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byKey(const Key('books_filter_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('books_filter_library')), findsOneWidget);
    expect(find.byKey(const Key('books_filter_category')), findsOneWidget);
    expect(find.byKey(const Key('books_filter_apply')), findsOneWidget);
  });
}
