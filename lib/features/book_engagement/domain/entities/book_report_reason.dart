import 'package:equatable/equatable.dart';

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
