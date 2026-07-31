import 'package:equatable/equatable.dart';

import '../../domain/entities/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads a fresh profile from the API and refreshes the cache.
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// Loads only the profile cached immediately after authentication.
class ProfileCachedLoadRequested extends ProfileEvent {
  const ProfileCachedLoadRequested();
}

/// Replaces the visible profile after a successful edit or location change.
class ProfileReplaced extends ProfileEvent {
  const ProfileReplaced(this.profile);

  final Profile profile;

  @override
  List<Object?> get props => <Object?>[profile];
}
