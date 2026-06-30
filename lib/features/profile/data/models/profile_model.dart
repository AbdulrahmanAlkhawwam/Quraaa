import 'package:equatable/equatable.dart';

/// Strongly typed model for the `/api/Profile/me` response.
class ProfileModel extends Equatable {
  const ProfileModel({
    this.userId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.gender,
    this.role,
    this.dateOfBirth,
    this.profileImageUrl,
    this.interests,
    this.lastLoginDate,
    this.previousLoginDate,
    this.creationTime,
    this.lastModificationTime,
  });

  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final int? gender;
  final int? role;
  final String? dateOfBirth;
  final String? profileImageUrl;
  final List<String>? interests;
  final String? lastLoginDate;
  final String? previousLoginDate;
  final String? creationTime;
  final String? lastModificationTime;

  /// Returns the full name when both parts are available.
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? '';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: json['gender'] as int?,
      role: json['role'] as int?,
      dateOfBirth: json['dateOfBirth'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      lastLoginDate: json['lastLoginDate'] as String?,
      previousLoginDate: json['previousLoginDate'] as String?,
      creationTime: json['creationTime'] as String?,
      lastModificationTime: json['lastModificationTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'role': role,
      'dateOfBirth': dateOfBirth,
      'profileImageUrl': profileImageUrl,
      'interests': interests,
      'lastLoginDate': lastLoginDate,
      'previousLoginDate': previousLoginDate,
      'creationTime': creationTime,
      'lastModificationTime': lastModificationTime,
    };
  }

  ProfileModel copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    int? gender,
    int? role,
    String? dateOfBirth,
    String? profileImageUrl,
    List<String>? interests,
    String? lastLoginDate,
    String? previousLoginDate,
    String? creationTime,
    String? lastModificationTime,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      previousLoginDate: previousLoginDate ?? this.previousLoginDate,
      creationTime: creationTime ?? this.creationTime,
      lastModificationTime: lastModificationTime ?? this.lastModificationTime,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        userId,
        firstName,
        lastName,
        phoneNumber,
        gender,
        role,
        dateOfBirth,
        profileImageUrl,
        interests,
        lastLoginDate,
        previousLoginDate,
        creationTime,
        lastModificationTime,
      ];
}
