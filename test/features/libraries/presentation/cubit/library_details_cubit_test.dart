import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/libraries/domain/entities/library_book_entity.dart';
import 'package:quraaa/features/libraries/domain/repositories/library_details_repository.dart';
import 'package:quraaa/features/libraries/domain/use_cases/get_library_books_use_case.dart';
import 'package:quraaa/features/libraries/presentation/cubit/library_details_cubit.dart';
import 'package:quraaa/features/libraries/presentation/cubit/library_details_state.dart';

class MockGetLibraryBooksUseCase extends Mock
    implements GetLibraryBooksUseCase {}

class _FakeGetLibraryBooksParams extends Fake
    implements GetLibraryBooksParams {}

void main() {
  group('LibraryDetailsCubit', () {
    late MockGetLibraryBooksUseCase useCase;
    late LibraryDetailsCubit cubit;

    const String libraryId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';

    const LibraryBookEntity book = LibraryBookEntity(
      listingId: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      price: '10.00',
      stock: '5',
      condition: 0,
      bookId: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      title: 'Emar English book',
      author: 'Ahmed Khaled',
      description: 'A great book',
      coverImageUrl: 'https://example.com/cover.png',
      language: 'English',
      isbn: '123456789',
      categoryId: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      categoryNameAr: 'تعليم',
      categoryNameEn: 'Education',
    );

    setUpAll(() {
      registerFallbackValue(
        const GetLibraryBooksParams(
          libraryId: libraryId,
          pageNumber: 1,
          pageSize: 10,
        ),
      );
      registerFallbackValue(_FakeGetLibraryBooksParams());
    });

    setUp(() {
      useCase = MockGetLibraryBooksUseCase();
      cubit = LibraryDetailsCubit(
        libraryId: libraryId,
        getLibraryBooksUseCase: useCase,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is empty and initial status', () {
      expect(cubit.state.status, LibraryDetailsStatus.initial);
      expect(cubit.state.books, isEmpty);
      expect(cubit.state.authors, isEmpty);
      expect(cubit.state.hasMore, false);
    });

    test('loadBooks emits success with books and derived authors', () async {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Success<LibraryBooksPage>(
          LibraryBooksPage(
            items: <LibraryBookEntity>[book],
            pageNumber: 1,
            pageSize: 10,
            totalCount: 1,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await cubit.loadBooks();

      expect(cubit.state.status, LibraryDetailsStatus.success);
      expect(cubit.state.books, <LibraryBookEntity>[book]);
      expect(cubit.state.authors.length, 1);
      expect(cubit.state.authors.first.name, 'Ahmed Khaled');
      expect(cubit.state.hasMore, false);
      verify(() => useCase(any())).called(1);
    });

    test('loadBooks emits error when use case fails', () async {
      when(() => useCase(any())).thenAnswer(
        (_) async => const ResultFailure<LibraryBooksPage>('Network error'),
      );

      await cubit.loadBooks();

      expect(cubit.state.status, LibraryDetailsStatus.error);
      expect(cubit.state.errorMessage, 'Network error');
      expect(cubit.state.books, isEmpty);
    });

    test('loadBooks calls use case with empty search/sort params', () async {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Success<LibraryBooksPage>(
          LibraryBooksPage(
            items: <LibraryBookEntity>[],
            pageNumber: 1,
            pageSize: 10,
            totalCount: 0,
            totalPages: 0,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      await cubit.loadBooks();

      final verification = verify(() => useCase(captureAny()))..called(1);
      final GetLibraryBooksParams params =
          verification.captured.single as GetLibraryBooksParams;
      expect(params.libraryId, libraryId);
      expect(params.pageNumber, 1);
      expect(params.pageSize, 10);
      expect(params.searchTerm, '');
      expect(params.sortBy, '');
      expect(params.sortDescending, false);
    });
  });
}
