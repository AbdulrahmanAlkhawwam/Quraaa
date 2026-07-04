import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/category_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  const OnboardingRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.categories,
      );
      final dynamic data = response.data;
      if (data is List<dynamic>) {
        return data
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw const UnknownException(message: 'Invalid categories response.');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    final Object? underlying = error.error;
    if (underlying is AppException) {
      return underlying;
    }

    final dynamic payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      return ErrorMapper.mapResponseToException(ErrorResponseModel.fromJson(payload));
    }

    return UnknownException(
      message: error.message ?? 'Unable to load categories.',
    );
  }
}
