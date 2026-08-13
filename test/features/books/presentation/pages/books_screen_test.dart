import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:quraaa/core/di/injection_container.dart';
import 'package:quraaa/features/books/books.dart';
import 'package:quraaa/features/books/presentation/pages/books_screen.dart';

void main() {
  setUp(() {
    if (!sl.isRegistered<BooksBloc>()) {
      sl.registerFactory<BooksBloc>(() => BooksBloc(getBooks: GetBooksUseCase(BooksRepositoryImpl(const BooksMockRemoteDataSourceImpl()))));
    }
  });
  tearDown(() => GetIt.I.reset());

  testWidgets('opens the filter bottom sheet', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BooksScreen()));
    await tester.tap(find.byKey(const Key('books_filter_button')));
    await tester.pumpAndSettle();
    expect(find.text('Filter books'), findsOneWidget);
  });

  testWidgets('shows every Figma book-format filter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BooksScreen()));

    expect(find.text('Sound Book'), findsOneWidget);
    expect(find.text('E-book'), findsOneWidget);
    expect(find.text('Free book'), findsOneWidget);
    expect(find.text('Used Book'), findsOneWidget);
  });
}
