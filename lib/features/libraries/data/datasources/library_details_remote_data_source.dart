import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/library_book_model.dart';
import '../models/paginated_library_books_response_model.dart';

abstract class LibraryDetailsRemoteDataSource {
  Future<PaginatedLibraryBooksResponseModel> getLibraryBooks({
    required String libraryId,
    required int pageNumber,
    required int pageSize,
    String? searchTerm,
    String? sortBy,
    bool? sortDescending,
  });

  Future<LibraryBookModel> getListingDetails(String listingId);
}

class LibraryDetailsRemoteDataSourceImpl
    implements LibraryDetailsRemoteDataSource {
  const LibraryDetailsRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<PaginatedLibraryBooksResponseModel> getLibraryBooks({
    required String libraryId,
    required int pageNumber,
    required int pageSize,
    String? searchTerm,
    String? sortBy,
    bool? sortDescending,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.libraryBooks(libraryId),
        queryParameters: <String, dynamic>{
          'PageNumber': pageNumber,
          'PageSize': pageSize,
          if (searchTerm?.isNotEmpty ?? false) 'SearchTerm': searchTerm,
          if (sortBy?.isNotEmpty ?? false) 'SortBy': sortBy,
          if (sortDescending != null) 'SortDescending': sortDescending,
        },
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return PaginatedLibraryBooksResponseModel.fromJson(data);
      }

      throw const UnknownException(message: 'Invalid library books response.');
    } on DioException catch (error) {
      throw _mapDioException(error, 'Unable to load library books.');
    }
  }

  @override
  Future<LibraryBookModel> getListingDetails(String listingId) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.listingDetails(listingId),
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return LibraryBookModel.fromJson(data);
      }

      throw const UnknownException(
          message: 'Invalid listing details response.');
    } on DioException catch (error) {
      throw _mapDioException(error, 'Unable to load listing details.');
    }
  }

  AppException _mapDioException(DioException error, String fallbackMessage) {
    final Object? underlying = error.error;
    if (underlying is AppException) {
      return underlying;
    }

    final dynamic payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(payload),
      );
    }

    return UnknownException(
      message: error.message ?? fallbackMessage,
    );
  }
}
