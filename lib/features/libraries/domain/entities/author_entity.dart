import 'package:equatable/equatable.dart';

class AuthorEntity extends Equatable {
  const AuthorEntity({
    required this.id,
    required this.name,
    this.bio,
    this.photoUrl,
    this.birthDate,
  });

  final String id;
  final String name;
  final String? bio;
  final String? photoUrl;
  final DateTime? birthDate;

  @override
  List<Object?> get props => <Object?>[id, name, bio, photoUrl, birthDate];
}

class AuthorBookEntity extends Equatable {
  const AuthorBookEntity({
    required this.listingId,
    required this.title,
    required this.authorName,
    required this.coverImageUrl,
    required this.format,
    required this.startingPrice,
    required this.isFree,
    required this.sellersCount,
    required this.ratingsCount,
    this.categoryNameAr = '',
    this.categoryNameEn = '',
    this.averageRating,
  });

  final String listingId;
  final String title;
  final String authorName;
  final String coverImageUrl;
  final String format;
  final double startingPrice;
  final bool isFree;
  final int sellersCount;
  final String categoryNameAr;
  final String categoryNameEn;
  final double? averageRating;
  final int ratingsCount;

  @override
  List<Object?> get props => <Object?>[
        listingId,
        title,
        authorName,
        coverImageUrl,
        format,
        startingPrice,
        isFree,
        sellersCount,
        categoryNameAr,
        categoryNameEn,
        averageRating,
        ratingsCount,
      ];
}

class AuthorSearchResult extends Equatable {
  const AuthorSearchResult({
    required this.id,
    required this.name,
    required this.totalBooksCount,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final int totalBooksCount;

  @override
  List<Object?> get props => <Object?>[id, name, photoUrl, totalBooksCount];
}
