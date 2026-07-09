import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/core/architecture/use_case.dart';
import 'package:quraaa/features/account/account.dart';
import 'package:quraaa/features/libraries/domain/entities/library_entity.dart';
import 'package:quraaa/features/libraries/domain/repositories/libraries_repository.dart';
import 'package:quraaa/features/libraries/domain/use_cases/get_libraries_use_case.dart';
import 'package:quraaa/features/libraries/presentation/cubit/libraries_cubit.dart';

class MockGetLibrariesUseCase extends Mock implements GetLibrariesUseCase {}

class MockLoadAccountUserSnapshotUseCase extends Mock
    implements LoadAccountUserSnapshotUseCase {}

class _FakeGetLibrariesParams extends Fake implements GetLibrariesParams {}

void main() {
  group('LibrariesCubit', () {
    late MockGetLibrariesUseCase useCase;
    late MockLoadAccountUserSnapshotUseCase loadUserSnapshotUseCase;
    late LibrariesCubit cubit;

    setUpAll(() {
      registerFallbackValue(const GetLibrariesParams(
        searchTerm: '',
        pageNumber: 1,
        pageSize: 10,
      ));
      registerFallbackValue(_FakeGetLibrariesParams());
      registerFallbackValue(const NoParams());
    });

    setUp(() {
      useCase = MockGetLibrariesUseCase();
      loadUserSnapshotUseCase = MockLoadAccountUserSnapshotUseCase();
      cubit = LibrariesCubit(
        getLibrariesUseCase: useCase,
        loadUserSnapshotUseCase: loadUserSnapshotUseCase,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    const LibraryEntity library = LibraryEntity(
      id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      libraryName: 'Jarir Book Store',
      location: 'Riyadh',
      libraryImage: 'https://example.com/library.png',
      headerImage: 'https://example.com/header.png',
      email: 'contact@jarir.com',
    );

    test('initial state has empty search and configured paging controller', () {
      expect(cubit.state.searchTerm, '');
      expect(cubit.state.pageSize, 10);
      expect(cubit.state.status, LibrariesStatus.initial);
      expect(cubit.state.pagingController.firstPageKey, 1);
    });

    test('loadUserSnapshot stores the account header snapshot', () async {
      when(() => loadUserSnapshotUseCase(any())).thenAnswer(
        (_) async => const AccountUserSnapshot(
          fullName: 'Abdulrahman Alkhawwam',
          profileImage: '/tmp/avatar.png',
        ),
      );

      await cubit.loadUserSnapshot();

      expect(cubit.state.firstName, 'Abdulrahman');
      expect(cubit.state.profileImage, '/tmp/avatar.png');
      verify(() => loadUserSnapshotUseCase(any())).called(1);
    });

    test('fetching first page appends items and emits success', () async {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Success<LibrariesPage>(
          LibrariesPage(
            items: <LibraryEntity>[library],
            pageNumber: 1,
            pageSize: 10,
            totalCount: 1,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      cubit.state.pagingController.notifyPageRequestListeners(1);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.status, LibrariesStatus.success);
      expect(cubit.state.pagingController.itemList, <LibraryEntity>[library]);
      verify(() => useCase(any())).called(1);
    });

    test('fetching page appends next page key when more pages exist', () async {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Success<LibrariesPage>(
          LibrariesPage(
            items: <LibraryEntity>[library],
            pageNumber: 1,
            pageSize: 10,
            totalCount: 2,
            totalPages: 2,
            hasNextPage: true,
            hasPreviousPage: false,
          ),
        ),
      );

      cubit.state.pagingController.notifyPageRequestListeners(1);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.pagingController.nextPageKey, 2);
    });

    test('failure sets controller error and emits error state', () async {
      when(() => useCase(any())).thenAnswer(
        (_) async => const ResultFailure<LibrariesPage>('Network error'),
      );

      cubit.state.pagingController.notifyPageRequestListeners(1);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.status, LibrariesStatus.error);
      expect(cubit.state.errorMessage, 'Network error');
      expect(cubit.state.pagingController.error, 'Network error');
    });

    test('updateSearchTerm updates search term and subsequent fetch uses it',
        () async {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Success<LibrariesPage>(
          LibrariesPage(
            items: <LibraryEntity>[library],
            pageNumber: 1,
            pageSize: 10,
            totalCount: 1,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        ),
      );

      cubit.updateSearchTerm('jarir');

      expect(cubit.state.searchTerm, 'jarir');

      cubit.state.pagingController.notifyPageRequestListeners(1);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      verify(() => useCase(any())).called(1);
    });

    test('updateSearchTerm with same term does nothing', () async {
      cubit.updateSearchTerm('');

      await Future<void>.delayed(const Duration(milliseconds: 50));

      verifyNever(() => useCase(any()));
    });
  });
}
