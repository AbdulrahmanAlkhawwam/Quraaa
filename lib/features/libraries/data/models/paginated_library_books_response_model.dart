import 'library_book_model.dart';

class PaginatedLibraryBooksResponseModel {
  const PaginatedLibraryBooksResponseModel({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<LibraryBookModel> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory PaginatedLibraryBooksResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> itemsJson =
        json['items'] as List<dynamic>? ?? <dynamic>[];

    return PaginatedLibraryBooksResponseModel(
      items: itemsJson
          .map(
            (dynamic item) =>
                LibraryBookModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      pageNumber: _parseInt(json['pageNumber']),
      pageSize: _parseInt(json['pageSize']),
      totalCount: _parseInt(json['totalCount']),
      totalPages: _parseInt(json['totalPages']),
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((LibraryBookModel item) => item.toJson()).toList(),
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}
