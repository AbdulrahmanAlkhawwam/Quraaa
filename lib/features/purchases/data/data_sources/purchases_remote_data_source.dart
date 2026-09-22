import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/http_helper.dart';
import '../models/purchased_book_model.dart';

abstract class PurchasesRemoteDataSource {
  Future<List<PurchasedBookModel>> getLibrary({String query = ''});
}

class PurchasesRemoteDataSourceImpl implements PurchasesRemoteDataSource {
  const PurchasesRemoteDataSourceImpl(this._http);

  final HttpHelper _http;

  @override
  Future<List<PurchasedBookModel>> getLibrary({String query = ''}) async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.buyHistory,
      queryParameters: <String, dynamic>{
        if (query.trim().isNotEmpty) 'SearchTerm': query.trim(),
        'PageNumber': 1,
        'PageSize': 50,
      },
    );
    final Object? raw = response.data is Map
        ? (response.data as Map)['items']
        : response.data;
    if (raw is! List) return const <PurchasedBookModel>[];
    return raw
        .whereType<Map>()
        .map(
          (Map item) =>
              PurchasedBookModel.fromApiJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }
}
