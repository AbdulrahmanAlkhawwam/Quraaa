import 'package:flutter/material.dart';

/// Immutable state for the Edit Profile screen.
@immutable
class EditProfileState {
  const EditProfileState({
    this.selectedBackgroundColor = const Color(0xFFDCE9D4),
    this.selectedTab = 0,
    this.name = 'Abdulrahman Alkhawwam',
    this.gender = 'Male',
    this.birthDate = '',
    this.phoneNumber = '0500 000 000',
  });

  final Color selectedBackgroundColor;
  final int selectedTab;
  final String name;
  final String gender;
  final String birthDate;
  final String phoneNumber;

  EditProfileState copyWith({
    Color? selectedBackgroundColor,
    int? selectedTab,
    String? name,
    String? gender,
    String? birthDate,
    String? phoneNumber,
  }) {
    return EditProfileState(
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      selectedTab: selectedTab ?? this.selectedTab,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
