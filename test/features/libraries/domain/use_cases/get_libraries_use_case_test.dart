import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/libraries/domain/entities/library_entity.dart';
import 'package:quraaa/features/libraries/domain/repositories/libraries_repository.dart';
import 'package:quraaa/features/libraries/domain/use_cases/get_libraries_use_case.dart';

class MockLibrariesRepository extends Mock implements LibrariesRepository {}

void main() {
  group('GetLibrariesUseCase', () {
    late MockLibrariesRepository repository;
    late GetLibrariesUseCase useCase;

    setUp(() {
      repository = MockLibrariesRepository();
      useCase = GetLibrariesUseCase(repository);
    });

    const LibrariesPage page = LibrariesPage(
      items: <LibraryEntity>[
        LibraryEntity(
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

    test('forwards parameters to repository and returns Success', () async {
      when(
        () => repository.getLibraries(
          searchTerm: 'jarir',
          pageNumber: 1,
          pageSize: 10,
        ),
      ).thenAnswer((_) async => const Success(page));

      final Result<LibrariesPage> result = await useCase(
        const GetLibrariesParams(
          searchTerm: 'jarir',
          pageNumber: 1,
          pageSize: 10,
        ),
      );

      expect(result, isA<Success<LibrariesPage>>());
      expect((result as Success<LibrariesPage>).value, page);
      verify(
        () => repository.getLibraries(
          searchTerm: 'jarir',
          pageNumber: 1,
          pageSize: 10,
        ),
      ).called(1);
    });

    test('forwards failure from repository', () async {
      when(
        () => repository.getLibraries(
          searchTerm: any(named: 'searchTerm'),
          pageNumber: any(named: 'pageNumber'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async => const ResultFailure<LibrariesPage>('Server error'),
      );

      final Result<LibrariesPage> result = await useCase(
        const GetLibrariesParams(
          searchTerm: '',
          pageNumber: 1,
          pageSize: 10,
        ),
      );

      expect(result, isA<ResultFailure<LibrariesPage>>());
      expect((result as ResultFailure<LibrariesPage>).message, 'Server error');
    });
  });
}
