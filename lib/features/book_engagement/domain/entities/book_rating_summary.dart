import 'package:equatable/equatable.dart';

class BookRatingSummary extends Equatable {
  const BookRatingSummary({required this.average, required this.count});

  static const BookRatingSummary empty = BookRatingSummary(average: 0, count: 0);

  final double average;
  final int count;

  @override
  List<Object?> get props => <Object?>[average, count];
}
