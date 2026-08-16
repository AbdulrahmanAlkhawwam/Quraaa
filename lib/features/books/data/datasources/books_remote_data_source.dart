import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../../domain/entities/book_catalog_filter.dart';
import '../models/home_catalog_book_model.dart';

abstract interface class BooksRemoteDataSource {
  Future<List<HomeCatalogBookModel>> fetchHomeCatalog({
    BookCatalogFilter filter,
    String query,
  });
}

class BooksRemoteDataSourceImpl implements BooksRemoteDataSource {
  const BooksRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<List<HomeCatalogBookModel>> fetchHomeCatalog({
    BookCatalogFilter filter = const BookCatalogFilter(),
    String query = '',
  }) async {
    if (!filter.hasValidPriceRange) {
      throw ArgumentError.value(filter, 'filter', 'Invalid price range.');
    }
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.homeCatalog,
        queryParameters: <String, dynamic>{
          if (query.trim().isNotEmpty) 'SearchTerm': query.trim(),
          'PageNumber': 1,
          'PageSize': 40,
          if (filter.categoryId?.isNotEmpty ?? false)
            'CategoryId': filter.categoryId,
          if (filter.libraryId?.isNotEmpty ?? false)
            'LibraryId': filter.libraryId,
          if (filter.format != null) 'Format': filter.format!.apiValue,
          if (filter.sellerType != null)
            'SellerType': filter.sellerType!.apiValue,
          if (filter.condition != null) 'Condition': filter.condition!.apiValue,
          if (filter.minPrice != null) 'MinPrice': filter.minPrice,
          if (filter.maxPrice != null) 'MaxPrice': filter.maxPrice,
        },
      );
      final List<dynamic>? items = _extractItems(response.data);
      if (items == null) {
        throw const UnknownException(
          message: 'Invalid home catalogue response.',
        );
      }

      return items
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(HomeCatalogBookModel.fromJson)
          .where((HomeCatalogBookModel book) => book.id.isNotEmpty)
          .toList(growable: false);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  List<dynamic>? _extractItems(Object? payload) {
    if (payload is List<dynamic>) return payload;
    final Map<String, dynamic>? map = _asMap(payload);
    if (map == null) return null;

    for (final String key in <String>[
      'items',
      'books',
      'listings',
      'catalog',
    ]) {
      final Object? value = map[key];
      if (value is List<dynamic>) return value;
    }

    for (final String key in <String>['data', 'result', 'value']) {
      final Object? nested = map[key];
      if (nested is List<dynamic>) return nested;
      final List<dynamic>? items = _extractItems(nested);
      if (items != null) return items;
    }

    return null;
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (Object? key, Object? item) =>
            MapEntry<String, dynamic>(key.toString(), item),
      );
    }
    return null;
  }

  AppException _mapDioException(DioException error) {
    final Object? underlying = error.error;
    if (underlying is AppException) return underlying;

    final Object? payload = error.response?.data;
    final Map<String, dynamic>? errorMap = _asMap(payload);
    if (errorMap != null) {
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(errorMap),
      );
    }

    return UnknownException(
      message: error.message ?? 'Unable to load the book catalogue.',
    );
  }
}
