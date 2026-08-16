import '../../domain/entities/profile.dart';

/// Data model returned by the profile locations endpoint.
class ProfileLocationModel extends ProfileLocation {
  const ProfileLocationModel({
    required super.latitude,
    required super.longitude,
    super.id,
    super.name,
    super.address,
    super.isDefault,
    super.creationTime,
    super.lastModificationTime,
  });

  factory ProfileLocationModel.fromJson(Map<String, dynamic> json) {
    final double? latitude = _asDouble(json['latitude']);
    final double? longitude = _asDouble(json['longitude']);
    if (latitude == null || longitude == null) {
      throw const FormatException('Invalid profile location coordinates.');
    }

    return ProfileLocationModel(
      id: json['id']?.toString(),
      name: (json['name'] ?? json['label'])?.toString(),
      address: json['address']?.toString(),
      latitude: latitude,
      longitude: longitude,
      isDefault: json['isDefault'] == true,
      creationTime: json['creationTime']?.toString(),
      lastModificationTime: json['lastModificationTime']?.toString(),
    );
  }

  static List<ProfileLocationModel> listFromJson(Object? json) {
    if (json is! List<dynamic>) {
      throw const FormatException('Invalid profile locations response.');
    }

    return json.map((dynamic item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid profile location item.');
      }
      return ProfileLocationModel.fromJson(item);
    }).toList(growable: false);
  }

  Map<String, dynamic> toRequestJson() => <String, dynamic>{
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
