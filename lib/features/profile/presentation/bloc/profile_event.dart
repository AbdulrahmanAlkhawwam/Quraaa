import 'package:equatable/equatable.dart';

/// {@template profile_event}
/// Events that can be dispatched to the [ProfileBloc].
/// {@endtemplate}
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Request loading the authenticated user's profile from the backend.
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}
