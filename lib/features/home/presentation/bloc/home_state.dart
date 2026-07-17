part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, failure }

@immutable
class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.userSnapshot,
    this.errorMessage,
    this.notificationSerial = 0,
    this.notificationTitle,
    this.notificationBody = '',
  });

  final HomeStatus status;
  final AccountUserSnapshot? userSnapshot;
  final String? errorMessage;
  final int notificationSerial;
  final String? notificationTitle;
  final String notificationBody;

  String get firstName => userSnapshot?.firstName ?? '';
  String? get profileImage => userSnapshot?.profileImage;

  HomeState copyWith({
    HomeStatus? status,
    AccountUserSnapshot? userSnapshot,
    String? errorMessage,
    int? notificationSerial,
    String? notificationTitle,
    String? notificationBody,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      userSnapshot: userSnapshot ?? this.userSnapshot,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      notificationSerial: notificationSerial ?? this.notificationSerial,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationBody: notificationBody ?? this.notificationBody,
    );
  }
}