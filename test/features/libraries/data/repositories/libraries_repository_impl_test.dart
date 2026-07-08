import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/features/libraries/data/datasources/libraries_remote_data_source.dart';
import 'package:quraaa/features/libraries/data/models/library_model.dart';
import 'package:quraaa/features/libraries/data/models/paginated_libraries_response_model.dart';
import 'package:quraaa/features/libraries/data/repositories/libraries_repository_impl.dart';
import 'package:quraaa/features/libraries/domain/entities/library_entity.dart';
import 'package:quraaa/features/libraries/domain/repositories/libraries_repository.dart';

class MockLibrariesRemoteDataSource extends Mock
    implements LibrariesRemoteDataSource {}

void main() {
  group('LibrariesRepositoryImpl', () {
    late MockLibrariesRemoteDataSource remoteDataSource;
    late LibrariesRepositoryImpl repository;

    setUp(() {
      remoteDataSource = MockLibrariesRemoteDataSource();
      repository = LibrariesRepositoryImpl(remoteDataSource);
    });

    const PaginatedLibrariesResponseModel responseModel =
        PaginatedLibrariesResponseModel(
      items: <LibraryModel>[
        LibraryModel(
          id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
          libraryName: 'Jarir Book Store',
          location: 'Riyadh',
          libraryImage: 'https://example.com/library.png',
          headerImage: 'https://example.com/header.png',
          email: 'contact@jarir.com',
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
        () => remoteDataSource.getLibraries(
          searchTerm: 'jarir',
          pageNumber: 1,
          pageSize: 10,
        ),
      ).thenAnswer((_) async => responseModel);

      final Result<LibrariesPage> result = await repository.getLibraries(
        searchTerm: 'jarir',
        pageNumber: 1,
        pageSize: 10,
      );

      expect(result, isA<Success<LibrariesPage>>());
      final LibrariesPage page = (result as Success<LibrariesPage>).value;
      expect(page.items.length, 1);
      expect(page.items.first, isA<LibraryEntity>());
      expect(page.items.first.libraryName, 'Jarir Book Store');
      expect(page.hasNextPage, false);
      verify(
        () => remoteDataSource.getLibraries(
          searchTerm: 'jarir',
          pageNumber: 1,
          pageSize: 10,
        ),
      ).called(1);
    });

    test('returns ResultFailure when remote data source throws', () async {
      when(
        () => remoteDataSource.getLibraries(
          searchTerm: any(named: 'searchTerm'),
          pageNumber: any(named: 'pageNumber'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(const UnknownException(message: 'Network error'));

      final Result<LibrariesPage> result = await repository.getLibraries(
        searchTerm: '',
        pageNumber: 1,
        pageSize: 10,
      );

      expect(result, isA<ResultFailure<LibrariesPage>>());
      final ResultFailure<LibrariesPage> failure =
          result as ResultFailure<LibrariesPage>;
      expect(failure.message, 'Network error');
    });
  });
}
