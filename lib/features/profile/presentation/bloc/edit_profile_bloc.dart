import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/shared.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

/// BLoC that manages the Edit Profile form and avatar customization.
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(const EditProfileState()) {
    on<EditProfileBackgroundColorSelected>(_onBackgroundColorSelected);
    on<EditProfileTabSelected>(_onTabSelected);
    on<EditProfileNameChanged>(_onNameChanged);
    on<EditProfileGenderChanged>(_onGenderChanged);
    on<EditProfileBirthDateChanged>(_onBirthDateChanged);
    on<EditProfilePhoneNumberChanged>(_onPhoneNumberChanged);
  }

  void _onBackgroundColorSelected(
    EditProfileBackgroundColorSelected event,
    Emitter<EditProfileState> emit,
  ) {
    emit(state.copyWith(selectedBackgroundColor: event.color));
  }

  void _onTabSelected(
    EditProfileTabSelected event,
    Emitter<EditProfileState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.index));
  }

  void _onNameChanged(
    EditProfileNameChanged event,
    Emitter<EditProfileState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onGenderChanged(
    EditProfileGenderChanged event,
    Emitter<EditProfileState> emit,
  ) {
    emit(state.copyWith(gender: event.gender));
  }

  void _onBirthDateChanged(
    EditProfileBirthDateChanged event,
    Emitter<EditProfileState> emit,
  ) {
    emit(state.copyWith(birthDate: event.birthDate));
  }

  void _onPhoneNumberChanged(
    EditProfilePhoneNumberChanged event,
    Emitter<EditProfileState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }
}

/// Palette colors exposed for the avatar background selector.
List<List<Color>> get editProfileColorPalette =>
    AppColors.avatarBackgroundPalette;
