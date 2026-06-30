import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
const List<List<Color>> editProfileColorPalette = <List<Color>>[
  <Color>[
    Color(0xFFEF8E8F),
    Color(0xFFF0A486),
    Color(0xFFEDAF86),
    Color(0xFFEDBA84),
    Color(0xFFEBD577),
    Color(0xFF8FD19E),
    Color(0xFF79CAC5),
  ],
  <Color>[
    Color(0xFF74C7CF),
    Color(0xFF74C4DD),
    Color(0xFF73A9DD),
    Color(0xFF9A95DD),
    Color(0xFFC584D7),
    Color(0xFFC9B4A2),
    Color(0xFFB5A79A),
  ],
];
