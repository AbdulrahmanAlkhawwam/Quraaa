import 'package:equatable/equatable.dart';

enum BookFormat { audio, ebook, free, used }

class Book extends Equatable {
  const Book({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.format,
    required this.coverAsset,
  });

  final String id;
  final String title;
  final String subtitle;
  final String price;
  final BookFormat format;
  final String coverAsset;

  @override
  List<Object> get props => <Object>[id, title, subtitle, price, format, coverAsset];
}
