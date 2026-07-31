import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/core/services/app_permission_service.dart';
import 'package:quraaa/core/services/notification_service.dart';
import 'package:quraaa/features/account/account.dart';
import 'package:quraaa/features/home/home.dart';

void main() {
  test('emits loading then loaded when home starts', () async {
    final HomeBloc bloc = HomeBloc(
      loadUserSnapshot: LoadAccountUserSnapshotUseCase(
        const _FakeHomeRepository(
          AccountUserSnapshot(fullName: 'Abdulrahman Alkhawwam'),
        ),
      ),
      getRecommendedBooks: GetRecommendedBooksUseCase(
        const _FakeHomeBooksRepository(),
      ),
      getMostPopularBooks: GetMostPopularBooksUseCase(
        const _FakeHomeBooksRepository(),
      ),
      notificationService: const _FakeNotificationService(),
      appPermissionService: _FakeAppPermissionService(),
    );
    addTearDown(bloc.close);

    bloc.add(const HomeStarted());

    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<HomeState>().having(
          (HomeState state) => state.status,
          'status',
          HomeStatus.loading,
        ),
        isA<HomeState>()
            .having(
              (HomeState state) => state.status,
              'status',
              HomeStatus.loaded,
            )
            .having(
              (HomeState state) => state.firstName,
              'firstName',
              'Abdulrahman',
            )
            .having(
              (HomeState state) => state.recommendedBooks.single.title,
              'recommended title',
              'Recommended book',
            )
            .having(
              (HomeState state) => state.mostPopularBooks.single.title,
              'popular title',
              'Popular book',
            ),
      ]),
    );
  });

  test('emits failure when loading the user snapshot fails', () async {
    final HomeBloc bloc = HomeBloc(
      loadUserSnapshot: LoadAccountUserSnapshotUseCase(
        const _ThrowingHomeRepository(),
      ),
      getRecommendedBooks: GetRecommendedBooksUseCase(
        const _FakeHomeBooksRepository(),
      ),
      getMostPopularBooks: GetMostPopularBooksUseCase(
        const _FakeHomeBooksRepository(),
      ),
      notificationService: const _FakeNotificationService(),
      appPermissionService: _FakeAppPermissionService(),
    );
    addTearDown(bloc.close);

    bloc.add(const HomeStarted());

    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<HomeState>().having(
          (HomeState state) => state.status,
          'status',
          HomeStatus.loading,
        ),
        isA<HomeState>().having(
          (HomeState state) => state.status,
          'status',
          HomeStatus.failure,
        ),
      ]),
    );
  });

  test('requests the initial permission bundle when requested', () async {
    final _FakeAppPermissionService permissionService =
        _FakeAppPermissionService();
    final HomeBloc bloc = HomeBloc(
      loadUserSnapshot: LoadAccountUserSnapshotUseCase(
        const _FakeHomeRepository(AccountUserSnapshot(fullName: 'Test User')),
      ),
      getRecommendedBooks: GetRecommendedBooksUseCase(
        const _FakeHomeBooksRepository(),
      ),
      getMostPopularBooks: GetMostPopularBooksUseCase(
        const _FakeHomeBooksRepository(),
      ),
      notificationService: const _FakeNotificationService(),
      appPermissionService: permissionService,
    );
    addTearDown(bloc.close);

    bloc.add(const HomePermissionsRequested());
    await permissionService.requested.future;

    expect(permissionService.requestCount, 1);
  });
}

class _FakeHomeRepository implements AccountRepository {
  const _FakeHomeRepository(this.snapshot);

  final AccountUserSnapshot snapshot;

  @override
  Future<AccountUserSnapshot> loadUserSnapshot() async => snapshot;
}

class _ThrowingHomeRepository implements AccountRepository {
  const _ThrowingHomeRepository();

  @override
  Future<AccountUserSnapshot> loadUserSnapshot() async {
    throw StateError('cannot load user');
  }
}

class _FakeHomeBooksRepository implements HomeBooksRepository {
  const _FakeHomeBooksRepository();

  @override
  Future<Result<HomeBooksPage>> getRecommendedBooks() async {
    return const Success<HomeBooksPage>(
      HomeBooksPage(
        items: <HomeBookEntity>[
          HomeBookEntity(
            bookId: 'recommended',
            title: 'Recommended book',
            author: 'Author',
            description: '',
            coverImageUrl: '',
            categoryId: '',
            language: 'en',
            isbn: '',
            purchaseCount: '0',
            ratingCount: '0',
            averageRating: '0',
            activeListingCount: '0',
          ),
        ],
        pageNumber: '1',
        pageSize: '1',
        totalCount: '1',
        totalPages: '1',
        hasNextPage: false,
        hasPreviousPage: false,
      ),
    );
  }

  @override
  Future<Result<HomeBooksPage>> getMostPopularBooks() async {
    return const Success<HomeBooksPage>(
      HomeBooksPage(
        items: <HomeBookEntity>[
          HomeBookEntity(
            bookId: 'popular',
            title: 'Popular book',
            author: 'Author',
            description: '',
            coverImageUrl: '',
            categoryId: '',
            language: 'en',
            isbn: '',
            purchaseCount: '0',
            ratingCount: '0',
            averageRating: '0',
            activeListingCount: '0',
          ),
        ],
        pageNumber: '1',
        pageSize: '1',
        totalCount: '1',
        totalPages: '1',
        hasNextPage: false,
        hasPreviousPage: false,
      ),
    );
  }
}

class _FakeNotificationService implements NotificationService {
  const _FakeNotificationService();

  @override
  Stream<RemoteMessage> get foregroundMessages => Stream<RemoteMessage>.empty();

  @override
  Future<void> handleForegroundMessage(RemoteMessage message) async {}

  @override
  Future<void> initialize({bool shouldRequestPermission = true}) async {}

  @override
  Future<void> requestPermission() async {}
}

class _FakeAppPermissionService implements AppPermissionService {
  final Completer<void> requested = Completer<void>();
  int requestCount = 0;

  @override
  Future<void> requestInitialPermissions() async {
    requestCount += 1;
    if (!requested.isCompleted) {
      requested.complete();
    }
  }
}
