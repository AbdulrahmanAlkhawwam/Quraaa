import '../../domain/entities/library_profile.dart';

class LibraryProfileModel extends LibraryProfile {
  const LibraryProfileModel({
    required super.libraryName,
    required super.location,
    required super.libraryImage,
    required super.headerImage,
    required super.email,
  });

  factory LibraryProfileModel.fromJson(Map<String, dynamic> json) {
    return LibraryProfileModel(
      libraryName: json['libraryName']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      libraryImage: json['libraryImage']?.toString() ?? '',
      headerImage: json['headerImage']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
