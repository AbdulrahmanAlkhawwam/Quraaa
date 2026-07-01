import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/location.dart';

/// {@template user}
/// Core user entity representing the locally persisted user profile.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    this.id,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.country,
    this.password,
    this.interests,
    this.birthday,
    this.gender,
    this.location,
    this.language,
    this.deviceAndroidVersion,
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiration,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? country;
  final String? password;
  final List<String>? interests;
  final String? birthday;
  final String? gender;
  final Location? location;
  final String? language;
  final String? deviceAndroidVersion;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? accessTokenExpiration;

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? '';
  }

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  bool get isTokenExpired {
    if (accessTokenExpiration == null) return true;
    return DateTime.now().isAfter(accessTokenExpiration!);
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? country,
    String? password,
    List<String>? interests,
    String? birthday,
    String? gender,
    Location? location,
    String? language,
    String? deviceAndroidVersion,
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiration,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      password: password ?? this.password,
      interests: interests ?? this.interests,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      language: language ?? this.language,
      deviceAndroidVersion: deviceAndroidVersion ?? this.deviceAndroidVersion,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiration:
          accessTokenExpiration ?? this.accessTokenExpiration,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    phoneNumber,
    country,
    password,
    interests,
    birthday,
    gender,
    location,
    language,
    deviceAndroidVersion,
    accessToken,
    refreshToken,
    accessTokenExpiration,
  ];
}
