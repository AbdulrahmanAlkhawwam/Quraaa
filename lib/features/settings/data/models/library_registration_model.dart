import '../../domain/entities/library_registration.dart';

class LibraryRegistrationModel {
  const LibraryRegistrationModel({
    required this.registrationUrl,
    required this.expiresAtUtc,
  });

  final String registrationUrl;
  final DateTime? expiresAtUtc;

  factory LibraryRegistrationModel.fromJson(Map<String, dynamic> json) {
    return LibraryRegistrationModel(
      registrationUrl: json['registrationUrl']?.toString().trim() ?? '',
      expiresAtUtc: DateTime.tryParse(
        json['expiresAtUtc']?.toString() ?? '',
      )?.toUtc(),
    );
  }

  LibraryRegistration toEntity() => LibraryRegistration(
        registrationUrl: registrationUrl,
        expiresAtUtc: expiresAtUtc!,
      );
}
