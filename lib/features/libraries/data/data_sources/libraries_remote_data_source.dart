import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/paginated_libraries_response_model.dart';
import '../models/paginated_library_search_response_model.dart';

abstract class LibrariesRemoteDataSource {
  Future<PaginatedLibrariesResponseModel> getLibraries({
    required String searchTerm,
    required int pageNumber,
    required int pageSize,
  });

  Future<PaginatedLibrarySearchResponseModel> searchLibraries({
    required String searchTerm,
    required int pageNumber,
    required int pageSize,
  });
}

class LibrariesRemoteDataSourceImpl implements LibrariesRemoteDataSource {
  const LibrariesRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<PaginatedLibrariesResponseModel> getLibraries({
    required String searchTerm,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.libraries,
        queryParameters: <String, dynamic>{
          'SearchTerm': searchTerm,
          'PageNumber': pageNumber,
          'PageSize': pageSize,
        },
      );
      if (response.data is Map) {
        return PaginatedLibrariesResponseModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const UnknownException(message: 'Invalid libraries response.');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<PaginatedLibrarySearchResponseModel> searchLibraries({
    required String searchTerm,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.librarySearch,
        queryParameters: <String, dynamic>{
          'SearchTerm': searchTerm.trim(),
          'PageNumber': pageNumber,
          'PageSize': pageSize,
        },
      );
      if (response.data is Map) {
        return PaginatedLibrarySearchResponseModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const UnknownException(message: 'Invalid library search response.');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    final Object? underlying = error.error;
    if (underlying is AppException) return underlying;
    final Object? payload = error.response?.data;
    if (payload is Map) {
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(
          Map<String, dynamic>.from(payload),
          statusCode: error.response?.statusCode,
        ),
      );
    }
    return UnknownException(
      message: error.message ?? 'Unable to load libraries.',
    );
  }
}
