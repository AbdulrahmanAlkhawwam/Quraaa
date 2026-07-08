import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base class for all Edit Profile events.
abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Background color for the avatar preview was selected.
class EditProfileBackgroundColorSelected extends EditProfileEvent {
  const EditProfileBackgroundColorSelected(this.color);

  final Color color;

  @override
  List<Object?> get props => <Object?>[color];
}

/// Customization tab was selected.
class EditProfileTabSelected extends EditProfileEvent {
  const EditProfileTabSelected(this.index);

  final int index;

  @override
  List<Object?> get props => <Object?>[index];
}

/// Full name changed.
class EditProfileNameChanged extends EditProfileEvent {
  const EditProfileNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => <Object?>[name];
}

/// Gender changed.
class EditProfileGenderChanged extends EditProfileEvent {
  const EditProfileGenderChanged(this.gender);

  final String gender;

  @override
  List<Object?> get props => <Object?>[gender];
}

/// Birth date changed.
class EditProfileBirthDateChanged extends EditProfileEvent {
  const EditProfileBirthDateChanged(this.birthDate);

  final String birthDate;

  @override
  List<Object?> get props => <Object?>[birthDate];
}

/// Phone number changed.
class EditProfilePhoneNumberChanged extends EditProfileEvent {
  const EditProfilePhoneNumberChanged(this.phoneNumber);

  final String phoneNumber;

  @override
  List<Object?> get props => <Object?>[phoneNumber];
}
