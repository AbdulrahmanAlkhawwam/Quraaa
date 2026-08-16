import 'package:equatable/equatable.dart';

import '../../../core/architecture/result.dart';

class BookComment extends Equatable {
  const BookComment({
    required this.id,
    required this.userId,
    required this.name,
    required this.content,
    required this.score,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String content;
  final int score;
  final DateTime? createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    userId,
    name,
    content,
    score,
    createdAt,
  ];
}

class BookRatingSummary extends Equatable {
  const BookRatingSummary({required this.average, required this.count});

  final double average;
  final int count;

  @override
  List<Object?> get props => <Object?>[average, count];
}

class BookReportReason extends Equatable {
  const BookReportReason({
    required this.value,
    required this.nameEn,
    required this.nameAr,
    required this.requiresDetails,
  });

  final int value;
  final String nameEn;
  final String nameAr;
  final bool requiresDetails;

  @override
  List<Object?> get props => <Object?>[value, nameEn, nameAr, requiresDetails];
}

abstract class BookEngagementRepository {
  Future<Result<List<BookComment>>> getComments(String bookId);
  Future<Result<BookRatingSummary>> getRating(String bookId);
  Future<Result<void>> addReview(String bookId, int score, String content);
  Future<Result<void>> updateReview(String bookId, int score, String content);
  Future<Result<void>> deleteReview(String bookId);
  Future<Result<List<BookReportReason>>> getReportReasons();
  Future<Result<void>> report(String bookId, int reason, String? details);
}
