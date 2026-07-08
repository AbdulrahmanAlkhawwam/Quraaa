import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/features/libraries/data/datasources/library_details_remote_data_source.dart';
import 'package:quraaa/features/libraries/data/models/library_book_model.dart';
import 'package:quraaa/features/libraries/data/models/paginated_library_books_response_model.dart';
import 'package:quraaa/features/libraries/data/repositories/library_details_repository_impl.dart';
import 'package:quraaa/features/libraries/domain/entities/library_book_entity.dart';
import 'package:quraaa/features/libraries/domain/repositories/library_details_repository.dart';

class MockLibraryDetailsRemoteDataSource extends Mock
    implements LibraryDetailsRemoteDataSource {}

void main() {
  group('LibraryDetailsRepositoryImpl', () {
    late MockLibraryDetailsRemoteDataSource remoteDataSource;
    late LibraryDetailsRepositoryImpl repository;

    const String libraryId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';

    setUp(() {
      remoteDataSource = MockLibraryDetailsRemoteDataSource();
      repository = LibraryDetailsRepositoryImpl(remoteDataSource);
    });

    const PaginatedLibraryBooksResponseModel responseModel =
        PaginatedLibraryBooksResponseModel(
      items: <LibraryBookModel>[
        LibraryBookModel(
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

    test('returns Success with mapped page on successful fetch', () async {
      when(
        () => remoteDataSource.getLibraryBooks(
          libraryId: libraryId,
          pageNumber: 1,
          pageSize: 10,
          searchTerm: '',
          sortBy: '',
          sortDescending: false,
        ),
      ).thenAnswer((_) async => responseModel);

      final Result<LibraryBooksPage> result = await repository.getLibraryBooks(
        libraryId: libraryId,
        pageNumber: 1,
        pageSize: 10,
        searchTerm: '',
        sortBy: '',
        sortDescending: false,
      );

      expect(result, isA<Success<LibraryBooksPage>>());
      final LibraryBooksPage page = (result as Success<LibraryBooksPage>).value;
      expect(page.items.length, 1);
      expect(page.items.first, isA<LibraryBookEntity>());
      expect(page.items.first.title, 'Emar English book');
      expect(page.hasNextPage, false);
      verify(
        () => remoteDataSource.getLibraryBooks(
          libraryId: libraryId,
          pageNumber: 1,
          pageSize: 10,
          searchTerm: '',
          sortBy: '',
          sortDescending: false,
        ),
      ).called(1);
    });

    test('returns ResultFailure when remote data source throws', () async {
      when(
        () => remoteDataSource.getLibraryBooks(
          libraryId: any(named: 'libraryId'),
          pageNumber: any(named: 'pageNumber'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(const UnknownException(message: 'Network error'));

      final Result<LibraryBooksPage> result = await repository.getLibraryBooks(
        libraryId: libraryId,
        pageNumber: 1,
        pageSize: 10,
      );

      expect(result, isA<ResultFailure<LibraryBooksPage>>());
      final ResultFailure<LibraryBooksPage> failure =
          result as ResultFailure<LibraryBooksPage>;
      expect(failure.message, 'Network error');
    });
  });
}
