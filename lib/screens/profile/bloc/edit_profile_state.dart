import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Immutable state for the Edit Profile screen.
class EditProfileState extends Equatable {
  const EditProfileState({
    this.selectedBackgroundColor = AppColors.editProfileBackground,
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

  @override
  List<Object?> get props => <Object?>[
        selectedBackgroundColor,
        selectedTab,
        name,
        gender,
        birthDate,
        phoneNumber,
      ];
}
