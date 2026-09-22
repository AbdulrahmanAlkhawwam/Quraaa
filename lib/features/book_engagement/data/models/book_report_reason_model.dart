import '../../domain/entities/book_report_reason.dart';
import 'book_comment_model.dart';

class BookReportReasonModel extends BookReportReason {
  const BookReportReasonModel({
    required super.value,
    required super.nameEn,
    required super.nameAr,
    required super.requiresDetails,
  });

  factory BookReportReasonModel.fromJson(Map<String, dynamic> json) {
    return BookReportReasonModel(
      value: BookCommentModel.parseInt(json['reason']),
      nameEn: json['nameEn']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      requiresDetails: json['requiresDetails'] == true,
    );
  }
}
