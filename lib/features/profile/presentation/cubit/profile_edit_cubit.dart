import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/update_profile_input.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileEditState extends Equatable {
  const ProfileEditState({
    required this.profile,
    this.saving = false,
    this.saved = false,
    this.error,
  });

  final Profile profile;
  final bool saving;
  final bool saved;
  final Object? error;

  ProfileEditState copyWith({
    Profile? profile,
    bool? saving,
    bool? saved,
    Object? error,
    bool clearError = false,
  }) {
    return ProfileEditState(
      profile: profile ?? this.profile,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[profile, saving, saved, error];
}

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit(this._repository, this._userContextProvider, Profile profile)
    : super(ProfileEditState(profile: profile));

  final ProfileRepository _repository;
  final UserContextProvider _userContextProvider;

  Future<void> save(UpdateProfileInput input) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, saved: false, clearError: true));
    try {
      final Profile profile = await _repository.updateMyProfile(input);
      final snapshot = _userContextProvider.snapshot;
      await _userContextProvider.setUser(
        id: profile.userId ?? snapshot.userId ?? 'authenticated',
        name: profile.fullName,
        phone: profile.phoneNumber ?? snapshot.userPhone,
        subscriptionStatus: 'active',
      );
      emit(
        state.copyWith(
          profile: profile,
          saving: false,
          saved: true,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(saving: false, saved: false, error: error));
    }
  }
}
