import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/app_permission_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../account/account.dart';
import '../../../auth/auth.dart';
import '../../domain/entities/home_book_entity.dart';
import '../../domain/entities/home_books_page.dart';
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
    required AuthLocalDataSource authLocalDataSource,
  }) : _loadUserSnapshot = loadUserSnapshot,
       _getRecommendedBooks = getRecommendedBooks,
       _getMostPopularBooks = getMostPopularBooks,
       _notificationService = notificationService,
       _appPermissionService = appPermissionService,
       _authLocalDataSource = authLocalDataSource,
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
  final AuthLocalDataSource _authLocalDataSource;
  StreamSubscription<RemoteMessage>? _notificationSubscription;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    unawaited(_startNotifications());
    final bool isGuest = !await _authLocalDataSource.isAuthenticatedSession();
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        isGuest: isGuest,
        recommendedStatus: isGuest
            ? HomeBooksStatus.initial
            : HomeBooksStatus.loading,
        mostPopularStatus: HomeBooksStatus.loading,
        clearError: true,
        clearRecommendedError: true,
        clearMostPopularError: true,
      ),
    );

    // A guest sees no recommendations, so that request is skipped entirely.
    final (
      _HomeUserLoadResult userResult,
      Either<Failure, HomeBooksPage>? recommendedResult,
      Either<Failure, HomeBooksPage> mostPopularResult,
    ) = await (
      _loadUser(),
      isGuest
          ? Future<Either<Failure, HomeBooksPage>?>.value()
          : _getRecommendedBooks(),
      _getMostPopularBooks(),
    ).wait;

    final bool recommendedLoaded = recommendedResult?.isRight() ?? false;
    emit(
      state.copyWith(
        status: userResult.error == null
            ? HomeStatus.loaded
            : HomeStatus.failure,
        isGuest: isGuest,
        userSnapshot: userResult.snapshot,
        errorMessage: userResult.error,
        recommendedStatus: isGuest
            ? HomeBooksStatus.initial
            : recommendedLoaded
            ? HomeBooksStatus.loaded
            : HomeBooksStatus.failure,
        recommendedBooks:
            recommendedResult?.toNullable()?.items ?? const <HomeBookEntity>[],
        recommendedErrorMessage: recommendedResult
            ?.getLeft()
            .toNullable()
            ?.message,
        mostPopularStatus: mostPopularResult.isRight()
            ? HomeBooksStatus.loaded
            : HomeBooksStatus.failure,
        mostPopularBooks:
            mostPopularResult.toNullable()?.items ?? const <HomeBookEntity>[],
        mostPopularErrorMessage: mostPopularResult
            .getLeft()
            .toNullable()
            ?.message,
        clearError: userResult.error == null,
        clearRecommendedError: isGuest || recommendedLoaded,
        clearMostPopularError: mostPopularResult.isRight(),
      ),
    );
  }

  Future<_HomeUserLoadResult> _loadUser() async {
    return (await _loadUserSnapshot()).fold(
      (Failure failure) => _HomeUserLoadResult(error: failure.message),
      (AccountUserSnapshot snapshot) => _HomeUserLoadResult(snapshot: snapshot),
    );
  }

  Future<void> _onRecommendedBooksRequested(
    HomeRecommendedBooksRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isGuest) {
      return;
    }

    emit(
      state.copyWith(
        recommendedStatus: HomeBooksStatus.loading,
        clearRecommendedError: true,
      ),
    );
    emit(
      (await _getRecommendedBooks()).fold(
        (Failure failure) => state.copyWith(
          recommendedStatus: HomeBooksStatus.failure,
          recommendedErrorMessage: failure.message,
        ),
        (HomeBooksPage page) => state.copyWith(
          recommendedStatus: HomeBooksStatus.loaded,
          recommendedBooks: page.items,
          clearRecommendedError: true,
        ),
      ),
    );
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
    emit(
      (await _getMostPopularBooks()).fold(
        (Failure failure) => state.copyWith(
          mostPopularStatus: HomeBooksStatus.failure,
          mostPopularErrorMessage: failure.message,
        ),
        (HomeBooksPage page) => state.copyWith(
          mostPopularStatus: HomeBooksStatus.loaded,
          mostPopularBooks: page.items,
          clearMostPopularError: true,
        ),
      ),
    );
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

  /// Message of the failure that prevented the snapshot from loading.
  final String? error;
}
