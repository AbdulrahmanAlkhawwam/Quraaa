import 'package:flutter/material.dart';

/// Base class for all Edit Profile events.
abstract class EditProfileEvent {
  const EditProfileEvent();
}

/// Background color for the avatar preview was selected.
class EditProfileBackgroundColorSelected extends EditProfileEvent {
  const EditProfileBackgroundColorSelected(this.color);

  final Color color;
}

/// Customization tab was selected.
class EditProfileTabSelected extends EditProfileEvent {
  const EditProfileTabSelected(this.index);

  final int index;
}

/// Full name changed.
class EditProfileNameChanged extends EditProfileEvent {
  const EditProfileNameChanged(this.name);

  final String name;
}

/// Gender changed.
class EditProfileGenderChanged extends EditProfileEvent {
  const EditProfileGenderChanged(this.gender);

  final String gender;
}

/// Birth date changed.
class EditProfileBirthDateChanged extends EditProfileEvent {
  const EditProfileBirthDateChanged(this.birthDate);

  final String birthDate;
}

/// Phone number changed.
class EditProfilePhoneNumberChanged extends EditProfileEvent {
  const EditProfilePhoneNumberChanged(this.phoneNumber);

  final String phoneNumber;
}
