import 'dart:convert';

import '../../../../core/domain/entities/location.dart';
import '../../domain/entities/user.dart';

/// Wire and cache shape of [User]. Carries the session tokens the backend
/// returns on sign-in, which the entity intentionally does not expose.
class UserModel extends User {
  const UserModel({
    super.id,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.country,
    super.interests,
    super.birthday,
    super.gender,
    super.location,
    super.language,
    super.deviceAndroidVersion,
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiration,
  });

  final String? accessToken;
  final String? refreshToken;
  final DateTime? accessTokenExpiration;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['userId'] as String?,
      firstName: json['firstName'] as String? ?? json['name'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      country: json['country'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      birthday: json['birthday'] as String? ?? json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      language: json['language'] as String?,
      deviceAndroidVersion: json['deviceAndroidVersion'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      accessTokenExpiration: json['accessTokenExpiration'] != null
          ? DateTime.tryParse(json['accessTokenExpiration'] as String)
          : null,
    );
  }

  /// Plain entity with the session tokens stripped, for everything above the
  /// data layer.
  User toEntity() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      country: country,
      interests: interests,
      birthday: birthday,
      gender: gender,
      location: location,
      language: language,
      deviceAndroidVersion: deviceAndroidVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'country': country,
      'interests': interests,
      'birthday': birthday,
      'gender': gender,
      'location': location?.toJson(),
      'language': language,
      'deviceAndroidVersion': deviceAndroidVersion,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiration': accessTokenExpiration?.toIso8601String(),
    };
  }

  String toRawJson() => jsonEncode(toJson());

  factory UserModel.fromRawJson(String raw) {
    final Map<String, dynamic> decoded =
        jsonDecode(raw) as Map<String, dynamic>;
    return UserModel.fromJson(decoded);
  }

  @override
  UserModel copyWith({
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
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiration,
  }) {
    return UserModel(
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
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiration:
          accessTokenExpiration ?? this.accessTokenExpiration,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    ...super.props,
    accessToken,
    refreshToken,
    accessTokenExpiration,
  ];
}
