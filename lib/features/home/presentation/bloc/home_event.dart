part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {
  const HomeEvent();
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeNotificationReceived extends HomeEvent {
  const HomeNotificationReceived(this.message);

  final RemoteMessage message;
}