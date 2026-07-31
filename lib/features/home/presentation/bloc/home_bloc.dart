import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../../../core/services/app_permission_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../account/account.dart';
import '../../domain/entities/home_book_entity.dart';
import '../../domain/repositories/home_books_repository.dart';
import '../../domain/use_cases/get_most_popular_books_use_case.dart';
import '../../domain/use_cases/get_recommended_books_use_case.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required LoadAccountUserSnapshotUseCase loadUserSnapshot,
    required GetRecommendedBooksUseCase getRecommendedBooks,
    required GetMostPopularBooksUseCase getMostPopularBooks,
    required NotificationService notificationService,
    required AppPermissionService appPermissionService,
  }) : _loadUserSnapshot = loadUserSnapshot,
       _getRecommendedBooks = getRecommendedBooks,
       _getMostPopularBooks = getMostPopularBooks,
       _notificationService = notificationService,
       _appPermissionService = appPermissionService,
       super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRecommendedBooksRequested>(_onRecommendedBooksRequested);
    on<HomeMostPopularBooksRequested>(_onMostPopularBooksRequested);
    on<HomePermissionsRequested>(_onPermissionsRequested);
    on<HomeNotificationReceived>(_onNotificationReceived);
  }

  final LoadAccountUserSnapshotUseCase _loadUserSnapshot;
  final GetRecommendedBooksUseCase _getRecommendedBooks;
  final GetMostPopularBooksUseCase _getMostPopularBooks;
  final NotificationService _notificationService;
  final AppPermissionService _appPermissionService;
  StreamSubscription<RemoteMessage>? _notificationSubscription;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    unawaited(_startNotifications());
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        recommendedStatus: HomeBooksStatus.loading,
        mostPopularStatus: HomeBooksStatus.loading,
        clearError: true,
        clearRecommendedError: true,
        clearMostPopularError: true,
      ),
    );

    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      _loadUser(),
      _loadBooksSafely(_getRecommendedBooks),
      _loadBooksSafely(_getMostPopularBooks),
    ]);
    final _HomeUserLoadResult userResult = results[0] as _HomeUserLoadResult;
    final Result<HomeBooksPage> recommendedResult =
        results[1] as Result<HomeBooksPage>;
    final Result<HomeBooksPage> mostPopularResult =
        results[2] as Result<HomeBooksPage>;

    emit(
      state.copyWith(
        status: userResult.error == null
            ? HomeStatus.loaded
            : HomeStatus.failure,
        userSnapshot: userResult.snapshot,
        errorMessage: userResult.error?.toString(),
        recommendedStatus: recommendedResult is Success<HomeBooksPage>
            ? HomeBooksStatus.loaded
            : HomeBooksStatus.failure,
        recommendedBooks: switch (recommendedResult) {
          Success<HomeBooksPage>(value: final HomeBooksPage page) => page.items,
          ResultFailure<HomeBooksPage>() => const <HomeBookEntity>[],
        },
        recommendedErrorMessage: switch (recommendedResult) {
          Success<HomeBooksPage>() => null,
          ResultFailure<HomeBooksPage>(message: final String message) =>
            message,
        },
        mostPopularStatus: mostPopularResult is Success<HomeBooksPage>
            ? HomeBooksStatus.loaded
            : HomeBooksStatus.failure,
        mostPopularBooks: switch (mostPopularResult) {
          Success<HomeBooksPage>(value: final HomeBooksPage page) => page.items,
          ResultFailure<HomeBooksPage>() => const <HomeBookEntity>[],
        },
        mostPopularErrorMessage: switch (mostPopularResult) {
          Success<HomeBooksPage>() => null,
          ResultFailure<HomeBooksPage>(message: final String message) =>
            message,
        },
        clearError: userResult.error == null,
        clearRecommendedError: recommendedResult is Success<HomeBooksPage>,
        clearMostPopularError: mostPopularResult is Success<HomeBooksPage>,
      ),
    );
  }

  Future<_HomeUserLoadResult> _loadUser() async {
    try {
      return _HomeUserLoadResult(
        snapshot: await _loadUserSnapshot(const NoParams()),
      );
    } catch (error) {
      return _HomeUserLoadResult(error: error);
    }
  }

  Future<Result<HomeBooksPage>> _loadBooksSafely(
    UseCase<Result<HomeBooksPage>, NoParams> useCase,
  ) async {
    try {
      return await useCase(const NoParams());
    } catch (error) {
      return ResultFailure<HomeBooksPage>(error.toString(), cause: error);
    }
  }

  Future<void> _onRecommendedBooksRequested(
    HomeRecommendedBooksRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        recommendedStatus: HomeBooksStatus.loading,
        clearRecommendedError: true,
      ),
    );
    final Result<HomeBooksPage> result = await _loadBooksSafely(
      _getRecommendedBooks,
    );
    switch (result) {
      case Success<HomeBooksPage>(value: final HomeBooksPage page):
        emit(
          state.copyWith(
            recommendedStatus: HomeBooksStatus.loaded,
            recommendedBooks: page.items,
            clearRecommendedError: true,
          ),
        );
      case ResultFailure<HomeBooksPage>(message: final String message):
        emit(
          state.copyWith(
            recommendedStatus: HomeBooksStatus.failure,
            recommendedErrorMessage: message,
          ),
        );
    }
  }

  Future<void> _onMostPopularBooksRequested(
    HomeMostPopularBooksRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        mostPopularStatus: HomeBooksStatus.loading,
        clearMostPopularError: true,
      ),
    );
    final Result<HomeBooksPage> result = await _loadBooksSafely(
      _getMostPopularBooks,
    );
    switch (result) {
      case Success<HomeBooksPage>(value: final HomeBooksPage page):
        emit(
          state.copyWith(
            mostPopularStatus: HomeBooksStatus.loaded,
            mostPopularBooks: page.items,
            clearMostPopularError: true,
          ),
        );
      case ResultFailure<HomeBooksPage>(message: final String message):
        emit(
          state.copyWith(
            mostPopularStatus: HomeBooksStatus.failure,
            mostPopularErrorMessage: message,
          ),
        );
    }
  }

  Future<void> _startNotifications() async {
    try {
      await _notificationService.initialize(shouldRequestPermission: false);
      await _notificationSubscription?.cancel();
      _notificationSubscription = _notificationService.foregroundMessages
          .listen(
            (RemoteMessage message) => add(HomeNotificationReceived(message)),
          );
    } catch (_) {
      // Notification providers may be unavailable in local/dev builds.
    }
  }

  Future<void> _onPermissionsRequested(
    HomePermissionsRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _appPermissionService.requestInitialPermissions();
  }

  void _onNotificationReceived(
    HomeNotificationReceived event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        notificationSerial: state.notificationSerial + 1,
        notificationTitle: event.message.notification?.title,
        notificationBody: event.message.notification?.body ?? '',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    return super.close();
  }
}

class _HomeUserLoadResult {
  const _HomeUserLoadResult({this.snapshot, this.error});

  final AccountUserSnapshot? snapshot;
  final Object? error;
}
