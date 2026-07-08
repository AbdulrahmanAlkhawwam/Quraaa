import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/libraries/domain/entities/library_book_entity.dart';
import 'package:quraaa/features/libraries/domain/repositories/library_details_repository.dart';
import 'package:quraaa/features/libraries/domain/use_cases/get_library_books_use_case.dart';

class MockLibraryDetailsRepository extends Mock
    implements LibraryDetailsRepository {}

void main() {
  group('GetLibraryBooksUseCase', () {
    late MockLibraryDetailsRepository repository;
    late GetLibraryBooksUseCase useCase;

    const String libraryId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';

    setUp(() {
      repository = MockLibraryDetailsRepository();
      useCase = GetLibraryBooksUseCase(repository);
    });

    const LibraryBooksPage page = LibraryBooksPage(
      items: <LibraryBookEntity>[
        LibraryBookEntity(
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
        ),
      ],
      pageNumber: 1,
      pageSize: 10,
      totalCount: 1,
      totalPages: 1,
      hasNextPage: false,
      hasPreviousPage: false,
    );

    test('forwards parameters to repository and returns Success', () async {
      when(
        () => repository.getLibraryBooks(
          libraryId: libraryId,
          pageNumber: 1,
          pageSize: 10,
          searchTerm: '',
          sortBy: '',
          sortDescending: false,
        ),
      ).thenAnswer((_) async => const Success(page));

      final Result<LibraryBooksPage> result = await useCase(
        const GetLibraryBooksParams(
          libraryId: libraryId,
          pageNumber: 1,
          pageSize: 10,
          searchTerm: '',
          sortBy: '',
          sortDescending: false,
        ),
      );

      expect(result, isA<Success<LibraryBooksPage>>());
      expect((result as Success<LibraryBooksPage>).value, page);
      verify(
        () => repository.getLibraryBooks(
          libraryId: libraryId,
          pageNumber: 1,
          pageSize: 10,
          searchTerm: '',
          sortBy: '',
          sortDescending: false,
        ),
      ).called(1);
    });

    test('forwards failure from repository', () async {
      when(
        () => repository.getLibraryBooks(
          libraryId: any(named: 'libraryId'),
          pageNumber: any(named: 'pageNumber'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async => const ResultFailure<LibraryBooksPage>('Server error'),
      );

      final Result<LibraryBooksPage> result = await useCase(
        const GetLibraryBooksParams(
          libraryId: libraryId,
          pageNumber: 1,
          pageSize: 10,
        ),
      );

      expect(result, isA<ResultFailure<LibraryBooksPage>>());
      expect((result as ResultFailure<LibraryBooksPage>).message, 'Server error');
    });
  });
}
