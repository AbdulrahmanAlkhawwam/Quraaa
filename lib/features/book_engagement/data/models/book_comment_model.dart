import '../../domain/entities/book_comment.dart';

class BookCommentModel extends BookComment {
  const BookCommentModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.content,
    required super.score,
    required super.createdAt,
  });

  factory BookCommentModel.fromJson(Map<String, dynamic> json) {
    return BookCommentModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['userName']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      score: parseInt(json['score']),
      createdAt: DateTime.tryParse(json['creationTimeUtc']?.toString() ?? ''),
    );
  }

  /// Lenient integer parsing: the backend sends numbers as ints, doubles or
  /// strings depending on the endpoint.
  static int parseInt(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
}
