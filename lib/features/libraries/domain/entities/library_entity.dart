import 'package:equatable/equatable.dart';

/// A library (bookstore) listing returned by the `/Libraries` endpoint.
class LibraryEntity extends Equatable {
  const LibraryEntity({
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

  @override
  List<Object?> get props => <Object?>[
        id,
        libraryName,
        location,
        libraryImage,
        headerImage,
        email,
        description,
        rating,
        reviewCount,
      ];
}
