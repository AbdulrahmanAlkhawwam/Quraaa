import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileLocationState extends Equatable {
  const ProfileLocationState({
    this.profile,
    this.loading = false,
    this.saving = false,
    this.error,
    this.changeSerial = 0,
  });

  final Profile? profile;
  final bool loading;
  final bool saving;
  final Object? error;
  final int changeSerial;

  ProfileLocationState copyWith({
    Profile? profile,
    bool? loading,
    bool? saving,
    Object? error,
    bool clearError = false,
    int? changeSerial,
  }) {
    return ProfileLocationState(
      profile: profile ?? this.profile,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      error: clearError ? null : error ?? this.error,
      changeSerial: changeSerial ?? this.changeSerial,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    profile,
    loading,
    saving,
    error,
    changeSerial,
  ];
}

class ProfileLocationCubit extends Cubit<ProfileLocationState> {
  ProfileLocationCubit(this._repository) : super(const ProfileLocationState());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final Profile? profile = await _repository.getCachedProfile();
      emit(state.copyWith(profile: profile, loading: false, clearError: true));
    } catch (error) {
      emit(state.copyWith(loading: false, error: error));
    }
  }

  Future<void> save(ProfileLocation location) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final Profile profile = await _repository.updateLocation(location);
      emit(
        state.copyWith(
          profile: profile,
          saving: false,
          changeSerial: state.changeSerial + 1,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(saving: false, error: error));
    }
  }

  Future<void> delete() async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final Profile? profile = await _repository.deleteLocation();
      emit(
        state.copyWith(
          profile: profile,
          saving: false,
          changeSerial: state.changeSerial + 1,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(saving: false, error: error));
    }
  }
}
