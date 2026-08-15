class BookSummaryModel {
  const BookSummaryModel({required this.summary});

  final String summary;

  factory BookSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookSummaryModel(summary: json['summary'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'summary': summary};
}
