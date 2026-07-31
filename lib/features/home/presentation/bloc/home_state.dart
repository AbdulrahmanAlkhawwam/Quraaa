part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, failure }

enum HomeBooksStatus { initial, loading, loaded, failure }

@immutable
class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.isGuest = true,
    this.userSnapshot,
    this.errorMessage,
    this.recommendedStatus = HomeBooksStatus.initial,
    this.recommendedBooks = const <HomeBookEntity>[],
    this.recommendedErrorMessage,
    this.mostPopularStatus = HomeBooksStatus.initial,
    this.mostPopularBooks = const <HomeBookEntity>[],
    this.mostPopularErrorMessage,
    this.notificationSerial = 0,
    this.notificationTitle,
    this.notificationBody = '',
  });

  final HomeStatus status;
  final bool isGuest;
  final AccountUserSnapshot? userSnapshot;
  final String? errorMessage;
  final HomeBooksStatus recommendedStatus;
  final List<HomeBookEntity> recommendedBooks;
  final String? recommendedErrorMessage;
  final HomeBooksStatus mostPopularStatus;
  final List<HomeBookEntity> mostPopularBooks;
  final String? mostPopularErrorMessage;
  final int notificationSerial;
  final String? notificationTitle;
  final String notificationBody;

  String get firstName => userSnapshot?.firstName ?? '';
  String? get profileImage => userSnapshot?.profileImage;

  HomeState copyWith({
    HomeStatus? status,
    bool? isGuest,
    AccountUserSnapshot? userSnapshot,
    String? errorMessage,
    HomeBooksStatus? recommendedStatus,
    List<HomeBookEntity>? recommendedBooks,
    String? recommendedErrorMessage,
    HomeBooksStatus? mostPopularStatus,
    List<HomeBookEntity>? mostPopularBooks,
    String? mostPopularErrorMessage,
    int? notificationSerial,
    String? notificationTitle,
    String? notificationBody,
    bool clearError = false,
    bool clearRecommendedError = false,
    bool clearMostPopularError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      isGuest: isGuest ?? this.isGuest,
      userSnapshot: userSnapshot ?? this.userSnapshot,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      recommendedStatus: recommendedStatus ?? this.recommendedStatus,
      recommendedBooks: recommendedBooks ?? this.recommendedBooks,
      recommendedErrorMessage: clearRecommendedError
          ? null
          : recommendedErrorMessage ?? this.recommendedErrorMessage,
      mostPopularStatus: mostPopularStatus ?? this.mostPopularStatus,
      mostPopularBooks: mostPopularBooks ?? this.mostPopularBooks,
      mostPopularErrorMessage: clearMostPopularError
          ? null
          : mostPopularErrorMessage ?? this.mostPopularErrorMessage,
      notificationSerial: notificationSerial ?? this.notificationSerial,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationBody: notificationBody ?? this.notificationBody,
    );
  }
}
