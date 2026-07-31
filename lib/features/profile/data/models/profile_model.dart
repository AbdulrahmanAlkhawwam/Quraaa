import '../../domain/entities/profile.dart';

/// Data model for the `/profile/me` response and local cache payload.
class ProfileModel extends Profile {
  const ProfileModel({
    super.userId,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.gender,
    super.role,
    super.dateOfBirth,
    super.profileImageUrl,
    super.interests,
    super.location,
    super.lastLoginDate,
    super.previousLoginDate,
    super.creationTime,
    super.lastModificationTime,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: _asInt(json['gender']),
      role: _asInt(json['role']),
      dateOfBirth: json['dateOfBirth'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      interests: _parseInterests(json['interests']),
      location: _parseLocation(json['location']),
      lastLoginDate: json['lastLoginDate'] as String?,
      previousLoginDate: json['previousLoginDate'] as String?,
      creationTime: json['creationTime'] as String?,
      lastModificationTime: json['lastModificationTime'] as String?,
    );
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      userId: profile.userId,
      firstName: profile.firstName,
      lastName: profile.lastName,
      phoneNumber: profile.phoneNumber,
      gender: profile.gender,
      role: profile.role,
      dateOfBirth: profile.dateOfBirth,
      profileImageUrl: profile.profileImageUrl,
      interests: profile.interests,
      location: profile.location,
      lastLoginDate: profile.lastLoginDate,
      previousLoginDate: profile.previousLoginDate,
      creationTime: profile.creationTime,
      lastModificationTime: profile.lastModificationTime,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'phoneNumber': phoneNumber,
    'gender': gender,
    'role': role,
    'dateOfBirth': dateOfBirth,
    'profileImageUrl': profileImageUrl,
    'interests': interests
        .map(
          (ProfileInterest interest) => <String, dynamic>{
            'id': interest.id,
            'nameAr': interest.nameAr,
            'nameEn': interest.nameEn,
          },
        )
        .toList(growable: false),
    'location': location == null
        ? null
        : <String, dynamic>{
            'latitude': location!.latitude,
            'longitude': location!.longitude,
          },
    'lastLoginDate': lastLoginDate,
    'previousLoginDate': previousLoginDate,
    'creationTime': creationTime,
    'lastModificationTime': lastModificationTime,
  };

  static List<ProfileInterest> _parseInterests(Object? raw) {
    if (raw is! List<dynamic>) {
      return const <ProfileInterest>[];
    }
    return raw
        .map((dynamic item) {
          if (item is Map<String, dynamic>) {
            return ProfileInterest(
              id: item['id']?.toString() ?? '',
              nameAr: item['nameAr']?.toString() ?? '',
              nameEn: item['nameEn']?.toString() ?? '',
            );
          }
          return ProfileInterest(id: item.toString(), nameAr: '', nameEn: '');
        })
        .where((ProfileInterest item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  static ProfileLocation? _parseLocation(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final double? latitude = _asDouble(raw['latitude']);
    final double? longitude = _asDouble(raw['longitude']);
    if (latitude == null || longitude == null) {
      return null;
    }
    return ProfileLocation(latitude: latitude, longitude: longitude);
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
