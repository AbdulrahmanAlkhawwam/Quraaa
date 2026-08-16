import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/library_registration_model.dart';

abstract class LibraryRegistrationRemoteDataSource {
  Future<LibraryRegistrationModel> requestRegistration();
}

class LibraryRegistrationRemoteDataSourceImpl
    implements LibraryRegistrationRemoteDataSource {
  const LibraryRegistrationRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<LibraryRegistrationModel> requestRegistration() async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.libraryRegistration,
        data: null,
      );
      final Object? data = response.data;
      if (data is Map) {
        final LibraryRegistrationModel model =
            LibraryRegistrationModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        final Uri? uri = Uri.tryParse(model.registrationUrl);
        final bool isWebUrl =
            uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
        if (isWebUrl && model.expiresAtUtc != null) {
          return model;
        }
      }
      throw const UnknownException(
        message: 'Invalid library registration response.',
      );
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
      message: error.message ?? 'Unable to start library registration.',
    );
  }
}
