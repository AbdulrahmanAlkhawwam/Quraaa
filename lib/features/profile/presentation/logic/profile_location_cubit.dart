import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileLocationState extends Equatable {
  const ProfileLocationState({
    this.locations = const <ProfileLocation>[],
    this.loading = false,
    this.saving = false,
    this.error,
    this.changeSerial = 0,
  });

  final List<ProfileLocation> locations;
  final bool loading;
  final bool saving;
  final Object? error;
  final int changeSerial;

  ProfileLocationState copyWith({
    List<ProfileLocation>? locations,
    bool? loading,
    bool? saving,
    Object? error,
    bool clearError = false,
    int? changeSerial,
  }) {
    return ProfileLocationState(
      locations: locations ?? this.locations,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      error: clearError ? null : error ?? this.error,
      changeSerial: changeSerial ?? this.changeSerial,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        locations,
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
      final List<ProfileLocation> locations = await _repository.getLocations();
      emit(
        state.copyWith(
          locations: locations,
          loading: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(loading: false, error: error));
    }
  }

  Future<void> setDefault(ProfileLocation location) async {
    if (state.saving || location.isDefault) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final List<ProfileLocation> locations =
          await _repository.setDefaultLocation(location);
      emit(
        state.copyWith(
          locations: locations,
          saving: false,
          changeSerial: state.changeSerial + 1,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(saving: false, error: error));
    }
  }

  Future<void> save(ProfileLocation location) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final ProfileLocation effectiveLocation = location.id == null
          ? location.copyWith(isDefault: state.locations.isEmpty)
          : location;
      final List<ProfileLocation> locations = await _repository.updateLocation(
        effectiveLocation,
      );
      emit(
        state.copyWith(
          locations: locations,
          saving: false,
          changeSerial: state.changeSerial + 1,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(saving: false, error: error));
    }
  }

  Future<void> delete(ProfileLocation location) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final List<ProfileLocation> locations = await _repository.deleteLocation(
        location,
      );
      emit(
        state.copyWith(
          locations: locations,
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
