import 'package:equatable/equatable.dart';

abstract class ProfileGenderValue {
  ProfileGenderValue._();

  static const int male = 1;
  static const int female = 2;

  static bool isSupported(int? value) => value == male || value == female;

  static int normalize(int? value) => isSupported(value) ? value! : male;
}

class ProfileInterest extends Equatable {
  const ProfileInterest({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  final String id;
  final String nameAr;
  final String nameEn;

  @override
  List<Object?> get props => <Object?>[id, nameAr, nameEn];
}

class ProfileLocation extends Equatable {
  const ProfileLocation({
    required this.latitude,
    required this.longitude,
    this.id,
    String? name,
    String? label,
    this.address,
    this.isDefault = false,
    this.creationTime,
    this.lastModificationTime,
  }) : name = name ?? label;

  final String? id;
  final String? name;
  final String? address;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String? creationTime;
  final String? lastModificationTime;

  /// Backwards-compatible alias for older profile payloads and UI call sites.
  String? get label => name;

  ProfileLocation copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? creationTime,
    String? lastModificationTime,
  }) {
    return ProfileLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      creationTime: creationTime ?? this.creationTime,
      lastModificationTime: lastModificationTime ?? this.lastModificationTime,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        address,
        latitude,
        longitude,
        isDefault,
        creationTime,
        lastModificationTime,
      ];
}

class Profile extends Equatable {
  const Profile({
    this.userId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.gender,
    this.role,
    this.dateOfBirth,
    this.profileImageUrl,
    this.interests = const <ProfileInterest>[],
    this.location,
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
  final List<ProfileInterest> interests;
  final ProfileLocation? location;
  final String? lastLoginDate;
  final String? previousLoginDate;
  final String? creationTime;
  final String? lastModificationTime;

  String get fullName => <String>[
        firstName?.trim() ?? '',
        lastName?.trim() ?? '',
      ].where((String part) => part.isNotEmpty).join(' ');

  Profile copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    int? gender,
    int? role,
    String? dateOfBirth,
    String? profileImageUrl,
    List<ProfileInterest>? interests,
    ProfileLocation? location,
    bool clearLocation = false,
    String? lastLoginDate,
    String? previousLoginDate,
    String? creationTime,
    String? lastModificationTime,
  }) {
    return Profile(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      location: clearLocation ? null : location ?? this.location,
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
        location,
        lastLoginDate,
        previousLoginDate,
        creationTime,
        lastModificationTime,
      ];
}
