import 'package:equatable/equatable.dart';

class AssistantBook extends Equatable {
  const AssistantBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
  });

  final String id;
  final String title;
  final String author;
  final String coverUrl;

  @override
  List<Object?> get props => <Object?>[id, title, author, coverUrl];
}

