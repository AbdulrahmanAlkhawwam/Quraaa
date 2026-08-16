import 'package:equatable/equatable.dart';

class LibrarySearchEntity extends Equatable {
  const LibrarySearchEntity({
    required this.id,
    required this.name,
    required this.totalActiveListingsCount,
    this.logoUrl,
    this.location,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? location;
  final int totalActiveListingsCount;

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        logoUrl,
        location,
        totalActiveListingsCount,
      ];
}
