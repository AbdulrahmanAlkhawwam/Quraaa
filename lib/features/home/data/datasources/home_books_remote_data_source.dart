import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/paginated_home_books_response_model.dart';

abstract class HomeBooksRemoteDataSource {
  Future<PaginatedHomeBooksResponseModel> getRecommendedBooks();

  Future<PaginatedHomeBooksResponseModel> getMostPopularBooks();
}

class HomeBooksRemoteDataSourceImpl implements HomeBooksRemoteDataSource {
  const HomeBooksRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<PaginatedHomeBooksResponseModel> getRecommendedBooks() {
    return _getBooks(ApiEndpoints.recommendedBooks);
  }

  @override
  Future<PaginatedHomeBooksResponseModel> getMostPopularBooks() {
    return _getBooks(ApiEndpoints.mostPopularBooks);
  }

  Future<PaginatedHomeBooksResponseModel> _getBooks(String endpoint) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(endpoint);
      final Object? data = response.data;
      if (data is Map<String, dynamic>) {
        return PaginatedHomeBooksResponseModel.fromJson(data);
      }

      throw const UnknownException(message: 'Invalid home books response.');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    final Object? underlying = error.error;
    if (underlying is AppException) {
      return underlying;
    }

    final Object? payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(payload),
      );
    }

    return UnknownException(
      message: error.message ?? 'Unable to load home books.',
    );
  }
}
