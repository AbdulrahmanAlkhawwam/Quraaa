import 'package:equatable/equatable.dart';

/// {@template location}
/// Global location value object used across the entire application.
///
/// Represents a geographic point with latitude and longitude.
/// This entity is feature-agnostic and can be used by any module
/// (user profile, prayer times, mosques, events, etc.).
/// {@endtemplate}
class Location extends Equatable {
  /// {@macro location}
  const Location({
    required this.latitude,
    required this.longitude,
  });

  /// Geographic latitude (-90.0 to 90.0).
  final double latitude;

  /// Geographic longitude (-180.0 to 180.0).
  final double longitude;

  /// Creates a [Location] from a JSON map.
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Serialises this location to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  List<Object?> get props => [latitude, longitude];
}
