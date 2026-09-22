import 'package:equatable/equatable.dart';

/// A reader's review of a book: a 1–5 score plus optional text.
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
