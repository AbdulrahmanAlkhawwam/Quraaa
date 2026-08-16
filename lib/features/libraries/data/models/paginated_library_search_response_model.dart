import '../../domain/entities/library_search_entity.dart';

class PaginatedLibrarySearchResponseModel {
  const PaginatedLibrarySearchResponseModel({
    required this.items,
    required this.totalCount,
    required this.hasNextPage,
  });

  final List<LibrarySearchEntity> items;
  final int totalCount;
  final bool hasNextPage;

  factory PaginatedLibrarySearchResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final Object? rawItems = json['items'];
    return PaginatedLibrarySearchResponseModel(
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((Map item) {
                final Map<String, dynamic> value =
                    Map<String, dynamic>.from(item);
                return LibrarySearchEntity(
                  id: _text(value['id']),
                  name: _text(value['name']),
                  logoUrl: _nullableText(value['logoUrl']),
                  location: _nullableText(value['location']),
                  totalActiveListingsCount:
                      _integer(value['totalActiveListingsCount']),
                );
              })
              .where((LibrarySearchEntity item) => item.id.isNotEmpty)
              .toList(
                growable: false,
              )
          : const <LibrarySearchEntity>[],
      totalCount: _integer(json['totalCount']),
      hasNextPage: json['hasNextPage'] == true,
    );
  }

  static String _text(Object? value) => value?.toString().trim() ?? '';
  static String? _nullableText(Object? value) {
    final String result = _text(value);
    return result.isEmpty ? null : result;
  }

  static int _integer(Object? value) =>
      value is num ? value.toInt() : int.tryParse(_text(value)) ?? 0;
}
