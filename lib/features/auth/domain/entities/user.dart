import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/location.dart';

/// {@template user}
/// Core user entity representing the locally persisted user profile.
///
/// Credentials and session tokens are deliberately absent: they live in the
/// data layer (`UserModel`, session storage) and never reach the UI.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    this.id,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.country,
    this.interests,
    this.birthday,
    this.gender,
    this.location,
    this.language,
    this.deviceAndroidVersion,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? country;
  final List<String>? interests;
  final String? birthday;
  final String? gender;
  final Location? location;
  final String? language;
  final String? deviceAndroidVersion;

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? '';
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? country,
    List<String>? interests,
    String? birthday,
    String? gender,
    Location? location,
    String? language,
    String? deviceAndroidVersion,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      interests: interests ?? this.interests,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      language: language ?? this.language,
      deviceAndroidVersion: deviceAndroidVersion ?? this.deviceAndroidVersion,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    phoneNumber,
    country,
    interests,
    birthday,
    gender,
    location,
    language,
    deviceAndroidVersion,
  ];
}
