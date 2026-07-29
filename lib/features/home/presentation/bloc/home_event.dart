part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {
  const HomeEvent();
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomePermissionsRequested extends HomeEvent {
  const HomePermissionsRequested();
}

final class HomeNotificationReceived extends HomeEvent {
  const HomeNotificationReceived(this.message);

  final RemoteMessage message;
}
