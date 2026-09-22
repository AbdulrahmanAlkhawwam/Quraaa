import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/use_cases/delete_profile_location_use_case.dart';
import '../../domain/use_cases/get_profile_locations_use_case.dart';
import '../../domain/use_cases/save_profile_location_use_case.dart';
import '../../domain/use_cases/set_default_profile_location_use_case.dart';

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
  ProfileLocationCubit({
    required this._getLocations,
    required this._saveLocation,
    required this._deleteLocation,
    required this._setDefaultLocation,
  }) : super(const ProfileLocationState());

  final GetProfileLocationsUseCase _getLocations;
  final SaveProfileLocationUseCase _saveLocation;
  final DeleteProfileLocationUseCase _deleteLocation;
  final SetDefaultProfileLocationUseCase _setDefaultLocation;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    final Either<Failure, List<ProfileLocation>> result = await _getLocations();
    emit(
      result.fold(
        (Failure failure) => state.copyWith(loading: false, error: failure),
        (List<ProfileLocation> locations) => state.copyWith(
          locations: locations,
          loading: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> setDefault(ProfileLocation location) async {
    if (state.saving || location.isDefault) return;
    emit(state.copyWith(saving: true, clearError: true));
    _emitMutation(await _setDefaultLocation(location));
  }

  Future<void> save(ProfileLocation location) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, clearError: true));
    final ProfileLocation effectiveLocation = location.id == null
        ? location.copyWith(isDefault: state.locations.isEmpty)
        : location;
    _emitMutation(await _saveLocation(effectiveLocation));
  }

  Future<void> delete(ProfileLocation location) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, clearError: true));
    _emitMutation(await _deleteLocation(location));
  }

  void _emitMutation(Either<Failure, List<ProfileLocation>> result) {
    emit(
      result.fold(
        (Failure failure) => state.copyWith(saving: false, error: failure),
        (List<ProfileLocation> locations) => state.copyWith(
          locations: locations,
          saving: false,
          changeSerial: state.changeSerial + 1,
          clearError: true,
        ),
      ),
    );
  }
}
