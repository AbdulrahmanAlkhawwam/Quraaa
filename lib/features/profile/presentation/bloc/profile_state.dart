import 'package:equatable/equatable.dart';

import '../../data/models/profile_model.dart';

/// Immutable state exposed by [ProfileBloc].
class ProfileState extends Equatable {
  const ProfileState({
    this.loading = false,
    this.error,
    this.profile,
    this.requiresLogin = false,
  });

  final bool loading;
  final Object? error;
  final ProfileModel? profile;
  final bool requiresLogin;

  bool get hasError => error != null;

  ProfileState copyWith({
    bool? loading,
    Object? error,
    ProfileModel? profile,
    bool? requiresLogin,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      profile: clearProfile ? null : profile ?? this.profile,
      requiresLogin: requiresLogin ?? this.requiresLogin,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        loading,
        error,
        profile,
        requiresLogin,
      ];
}
