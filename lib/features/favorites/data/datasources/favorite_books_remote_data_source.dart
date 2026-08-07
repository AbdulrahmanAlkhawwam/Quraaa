import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/favorite_book_model.dart';

abstract class FavoriteBooksRemoteDataSource {
  Future<FavoriteBooksPageModel> getFavoriteBooks({
    required int pageNumber,
    required int pageSize,
    required String searchTerm,
  });

  Future<FavoriteBookModel> addFavorite(String bookId);
  Future<void> removeFavorite(String bookId);
}

class FavoriteBooksRemoteDataSourceImpl
    implements FavoriteBooksRemoteDataSource {
  const FavoriteBooksRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<FavoriteBooksPageModel> getFavoriteBooks({
    required int pageNumber,
    required int pageSize,
    required String searchTerm,
  }) async {
    final Response<dynamic> response = await _request(
      () => _httpHelper.get(
        ApiEndpoints.favoriteBooks,
        queryParameters: <String, Object?>{
          'PageNumber': pageNumber,
          'PageSize': pageSize,
          if (searchTerm.trim().isNotEmpty) 'SearchTerm': searchTerm.trim(),
        },
      ),
    );
    return FavoriteBooksPageModel.fromJson(_map(response.data));
  }

  @override
  Future<FavoriteBookModel> addFavorite(String bookId) async {
    final Response<dynamic> response = await _request(
      () => _httpHelper.post(ApiEndpoints.favoriteBook(bookId)),
    );
    return FavoriteBookModel.fromJson(_map(response.data));
  }

  @override
  Future<void> removeFavorite(String bookId) async {
    await _request(() => _httpHelper.delete(ApiEndpoints.favoriteBook(bookId)));
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      final Object? underlying = error.error;
      if (underlying is AppException) throw underlying;
      final Object? payload = error.response?.data;
      if (payload is Map) {
        throw ErrorMapper.mapResponseToException(
          ErrorResponseModel.fromJson(
            Map<String, dynamic>.from(payload),
            statusCode: error.response?.statusCode,
          ),
        );
      }
      throw UnknownException(
        message: error.message ?? 'Unable to update favorite books.',
      );
    }
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const UnknownException(message: 'Invalid favorite books response.');
  }
}
