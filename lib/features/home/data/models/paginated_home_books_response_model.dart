import 'home_book_model.dart';

class PaginatedHomeBooksResponseModel {
  const PaginatedHomeBooksResponseModel({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<HomeBookModel> items;
  final String pageNumber;
  final String pageSize;
  final String totalCount;
  final String totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory PaginatedHomeBooksResponseModel.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    final List<HomeBookModel> items = rawItems is List<dynamic>
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(HomeBookModel.fromJson)
              .toList(growable: false)
        : const <HomeBookModel>[];

    return PaginatedHomeBooksResponseModel(
      items: items,
      pageNumber: _asString(json['pageNumber']),
      pageSize: _asString(json['pageSize']),
      totalCount: _asString(json['totalCount']),
      totalPages: _asString(json['totalPages']),
      hasNextPage: _asBool(json['hasNextPage']),
      hasPreviousPage: _asBool(json['hasPreviousPage']),
    );
  }

  static String _asString(Object? value) => value?.toString() ?? '0';

  static bool _asBool(Object? value) {
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'true';
  }
}
