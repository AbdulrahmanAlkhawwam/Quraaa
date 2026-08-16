import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_helper.dart';
import '../domain/purchases.dart';

class PurchasesRemoteDataSource {
  const PurchasesRemoteDataSource(this._http);

  final HttpHelper _http;

  Future<List<PurchasedBook>> getLibrary({String query = ''}) async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.buyHistory,
      queryParameters: <String, dynamic>{
        if (query.trim().isNotEmpty) 'SearchTerm': query.trim(),
        'PageNumber': 1,
        'PageSize': 50,
      },
    );
    final Object? raw =
        response.data is Map ? (response.data as Map)['items'] : response.data;
    if (raw is! List) return const <PurchasedBook>[];
    return raw.whereType<Map>().map((Map item) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(item);
      final Map<String, dynamic> book = json['book'] is Map
          ? Map<String, dynamic>.from(json['book'] as Map)
          : const <String, dynamic>{};
      final Map<String, dynamic> category = book['category'] is Map
          ? Map<String, dynamic>.from(book['category'] as Map)
          : const <String, dynamic>{};
      final String asset = json['purchasedDigitalAssetUrl']?.toString() ?? '';
      return PurchasedBook(
        purchaseId: json['purchaseId']?.toString() ?? '',
        bookId: book['bookId']?.toString() ?? '',
        title: book['title']?.toString() ?? '',
        author: book['author']?.toString() ?? '',
        coverImageUrl: book['coverImageUrl']?.toString() ?? '',
        purchasedAt: DateTime.tryParse(json['purchasedAt']?.toString() ?? ''),
        digital: asset.isNotEmpty,
        description: book['description']?.toString() ?? '',
        language: book['language']?.toString() ?? '',
        isbn: book['isbn']?.toString() ?? '',
        categoryId: category['id']?.toString() ?? '',
      );
    }).toList(growable: false);
  }
}
