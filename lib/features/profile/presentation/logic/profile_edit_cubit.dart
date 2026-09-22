import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/update_profile_input.dart';
import '../../domain/use_cases/update_my_profile_use_case.dart';

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
  ProfileEditCubit(
    this._updateMyProfile,
    this._userContextProvider,
    Profile profile,
  ) : super(ProfileEditState(profile: profile));

  final UpdateMyProfileUseCase _updateMyProfile;
  final UserContextProvider _userContextProvider;

  Future<void> save(UpdateProfileInput input) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, saved: false, clearError: true));
    final Either<Failure, Profile> result = await _updateMyProfile(input);
    await result.fold(
      (Failure failure) async =>
          emit(state.copyWith(saving: false, saved: false, error: failure)),
      (Profile profile) async {
        try {
          final snapshot = _userContextProvider.snapshot;
          await _userContextProvider.setUser(
            id: profile.userId ?? snapshot.userId ?? 'authenticated',
            name: profile.fullName,
            phone: profile.phoneNumber ?? snapshot.userPhone,
            subscriptionStatus: 'active',
          );
        } catch (error) {
          emit(state.copyWith(saving: false, saved: false, error: error));
          return;
        }
        emit(
          state.copyWith(
            profile: profile,
            saving: false,
            saved: true,
            clearError: true,
          ),
        );
      },
    );
  }
}
