import 'package:equatable/equatable.dart';

class LibraryProfile extends Equatable {
  const LibraryProfile({
    required this.libraryName,
    required this.location,
    required this.libraryImage,
    required this.headerImage,
    required this.email,
  });

  final String libraryName;
  final String location;
  final String libraryImage;
  final String headerImage;
  final String email;

  @override
  List<Object?> get props => <Object?>[
        libraryName,
        location,
        libraryImage,
        headerImage,
        email,
      ];
}
