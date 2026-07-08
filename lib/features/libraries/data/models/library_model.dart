import '../../domain/entities/library_entity.dart';

class LibraryModel {
  const LibraryModel({
    required this.id,
    required this.libraryName,
    required this.location,
    required this.libraryImage,
    required this.headerImage,
    required this.email,
    this.description,
    this.rating,
    this.reviewCount,
  });

  final String id;
  final String libraryName;
  final String location;
  final String libraryImage;
  final String headerImage;
  final String email;
  final String? description;
  final double? rating;
  final int? reviewCount;

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    return LibraryModel(
      id: json['id'] as String? ?? '',
      libraryName: json['libraryName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      libraryImage: json['libraryImage'] as String? ?? '',
      headerImage: json['headerImage'] as String? ?? '',
      email: json['email'] as String? ?? '',
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'libraryName': libraryName,
      'location': location,
      'libraryImage': libraryImage,
      'headerImage': headerImage,
      'email': email,
      if (description != null) 'description': description,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'reviewCount': reviewCount,
    };
  }

  LibraryEntity toEntity() {
    return LibraryEntity(
      id: id,
      libraryName: libraryName,
      location: location,
      libraryImage: libraryImage,
      headerImage: headerImage,
      email: email,
      description: description,
      rating: rating,
      reviewCount: reviewCount,
    );
  }
}
